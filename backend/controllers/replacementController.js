const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { sendPushToUser } = require('../services/notificationService');
const { generateInternalId } = require('../utils/idGenerator');

// @route   GET /api/replacements
// @desc    Get all replacement requests
// @access  Private
const getReplacements = async (req, res) => {
  try {
    const { status, escalated, search, q, page, limit } = req.query;
    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    if (escalated === 'true') {
      whereClause += ' AND is_escalated_to_sourcing = TRUE';
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (id LIKE ? OR client_name LIKE ? OR original_candidate_name LIKE ? OR reason LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM replacement_requests${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT * FROM replacement_requests${whereClause} ORDER BY request_date DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [requests] = await pool.execute(dataSql, params);

      for (let reqObj of requests) {
        const [suggestions] = await pool.execute(
          `SELECT c.* FROM candidates c 
           JOIN replacement_suggestions rs ON c.id = rs.candidate_id 
           WHERE rs.replacement_request_id = ?`,
          [reqObj.id]
        );
        reqObj.suggestedCandidates = suggestions;
      }

      return res.json({
        data: requests,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [requests] = await pool.execute(`SELECT * FROM replacement_requests${whereClause} ORDER BY request_date DESC`, params);

    // Fetch suggested candidates for each request
    for (let req of requests) {
      const [suggestions] = await pool.execute(
        `SELECT c.* FROM candidates c 
         JOIN replacement_suggestions rs ON c.id = rs.candidate_id 
         WHERE rs.request_id = ?`,
        [req.id]
      );
      req.suggestedCandidates = suggestions;
    }

    res.json(requests);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/replacements
// @desc    Create a new replacement request
// @access  Private (Sales/Admin)
const createReplacement = async (req, res) => {
  try {
    const { contract_id, reason } = req.body;

    if (!contract_id || !reason) {
      return res.status(400).json({ message: 'Contract ID and reason are required' });
    }

    const createdBy = req.user.id;

    // Use transaction to update contract status and insert request
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const requestId = await generateInternalId(connection, 'replacement_requests');

      await connection.execute(
        `UPDATE contracts SET status = 'rePlaced', replacements_used = replacements_used + 1 WHERE id = ?`,
        [contract_id]
      );

      await connection.execute(
        `INSERT INTO replacement_requests (id, contract_id, reason, created_by) VALUES (?, ?, ?, ?)`,
        [requestId, contract_id, reason, createdBy]
      );

      await connection.commit();
      connection.release();

      res.status(201).json({ message: 'Replacement request created successfully', requestId, id: requestId });
    } catch (dbErr) {
      await connection.rollback();
      connection.release();
      throw dbErr;
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/replacements/:id/escalate
// @desc    Escalate replacement to Sourcing
// @access  Private (Sales/Admin)
const escalateReplacement = async (req, res) => {
  try {
    const { id } = req.params;
    const { criteria } = req.body;

    await pool.execute(
      'UPDATE replacement_requests SET is_escalated_to_sourcing = TRUE, required_criteria = ? WHERE id = ?',
      [criteria || null, id]
    );

    // Notify Sourcing Team
    const [sourcingUsers] = await pool.execute('SELECT id FROM users WHERE role = "sourcing"');
    for (const sUser of sourcingUsers) {
      await sendPushToUser(
        sUser.id,
        'Urgent Replacement Escalated!',
        `A replacement request for contract ${id} requires urgent sourcing.`
      );
    }

    res.json({ message: 'Replacement escalated to Sourcing' });
    await logAction('replacement', id, 'update', 'Escalated to Sourcing Team', req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/replacements/:id/suggest
// @desc    Sourcing adds candidate suggestions
// @access  Private (Sourcing/Admin)
const suggestCandidates = async (req, res) => {
  try {
    const { id } = req.params;
    const { candidateIds } = req.body; // Array of IDs

    if (!candidateIds || !Array.isArray(candidateIds) || candidateIds.length === 0) {
      return res.status(400).json({ message: 'Provide at least one candidate ID' });
    }

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Insert suggestions
      for (let candId of candidateIds) {
        await connection.execute(
          'INSERT IGNORE INTO replacement_suggestions (request_id, candidate_id) VALUES (?, ?)',
          [id, candId]
        );
      }

      // De-escalate and move status to inProgress
      await connection.execute(
        'UPDATE replacement_requests SET is_escalated_to_sourcing = FALSE, status = "inProgress" WHERE id = ?',
        [id]
      );

      await connection.commit();
      connection.release();

      res.json({ message: 'Suggestions added successfully' });
    } catch (dbErr) {
      await connection.rollback();
      connection.release();
      throw dbErr;
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/replacements/:id/resolve
// @desc    Resolve replacement by assigning new candidate
// @access  Private (Sales/Admin)
const resolveReplacement = async (req, res) => {
  try {
    const { id } = req.params;
    const { new_candidate_id } = req.body;

    if (!new_candidate_id) {
      return res.status(400).json({ message: 'New candidate ID is required to resolve' });
    }

    await pool.execute(
      'UPDATE replacement_requests SET status = "resolved", new_candidate_id = ?, resolved_date = NOW() WHERE id = ?',
      [new_candidate_id, id]
    );

    res.json({ message: 'Replacement resolved successfully' });
    await logAction('replacement', id, 'statusChange', `Resolved with candidate ${new_candidate_id}`, req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getReplacements,
  createReplacement,
  escalateReplacement,
  suggestCandidates,
  resolveReplacement
};
