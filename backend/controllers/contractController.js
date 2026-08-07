const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { generateContractId } = require('../utils/idGenerator');

// @route   GET /api/contracts
// @desc    Get all contracts
// @access  Private
const getContracts = async (req, res) => {
  try {
    const { status, client_id, candidate_id, search, q, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    if (client_id) {
      whereClause += ' AND client_id = ?';
      params.push(client_id);
    }
    if (candidate_id) {
      whereClause += ' AND candidate_id = ?';
      params.push(candidate_id);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (id LIKE ? OR client_id LIKE ? OR candidate_id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM contracts${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT * FROM contracts${whereClause} ORDER BY created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [contracts] = await pool.execute(dataSql, params);

      return res.json({
        data: contracts,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [contracts] = await pool.execute(`SELECT * FROM contracts${whereClause} ORDER BY created_at DESC`, params);
    res.json(contracts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/contracts
// @desc    Create a new contract
// @access  Private (Sales/Admin)
const createContract = async (req, res) => {
  try {
    const { client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee } = req.body;

    if (!client_id || !candidate_id || !start_date || !total_fee) {
      return res.status(400).json({ message: 'Missing required contract fields' });
    }

    let createdBy = null;
    const requestedUserId = req.user ? req.user.id : null;
    if (requestedUserId) {
      const [userRows] = await pool.execute('SELECT id FROM users WHERE id = ?', [requestedUserId]);
      if (userRows.length > 0) {
        createdBy = requestedUserId;
      }
    }

    // We should use a transaction to ensure atomic updates
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const contractId = (req.body.id && req.body.id.startsWith('CNT'))
        ? req.body.id
        : await generateContractId(connection);

      // 1. Insert contract
      await connection.execute(
        `INSERT INTO contracts 
        (id, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, created_by) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [contractId, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, createdBy]
      );

      // 2. Update client status to converted
      await connection.execute(
        `UPDATE clients SET status = 'converted' WHERE id = ?`,
        [client_id]
      );

      // 3. Update candidate status to pendingDrop
      await connection.execute(
        `UPDATE candidates SET status = 'pendingDrop' WHERE id = ?`,
        [candidate_id]
      );

      await connection.commit();
      connection.release();

      res.status(201).json({ message: 'Contract created successfully', contractId, id: contractId });
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

// @route   PUT /api/contracts/:id/payment
// @desc    Update contract payment amount
// @access  Private
const recordPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { amount } = req.body;

    if (!amount) return res.status(400).json({ message: 'Amount is required' });

    await pool.execute(
      'UPDATE contracts SET amount_paid = amount_paid + ? WHERE id = ?',
      [amount, id]
    );

    res.json({ message: 'Payment recorded successfully' });
    await logAction('contract', id, 'paymentLogged', `Logged payment of ${amount}`, req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getContracts,
  createContract,
  recordPayment
};
