const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { generateUrgentHireId } = require('../utils/idGenerator');

// @route   GET /api/urgent-hires
// @desc    Get all urgent hiring requests
// @access  Private
const getUrgentHires = async (req, res) => {
  try {
    const { status, category, search, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status && status !== 'all') {
      whereClause += ' AND uh.status = ?';
      params.push(status);
    }

    if (category) {
      whereClause += ' AND uh.category = ?';
      params.push(category);
    }

    if (search) {
      whereClause += ' AND (uh.client_name LIKE ? OR uh.client_phone LIKE ? OR uh.category LIKE ? OR uh.id LIKE ? OR uh.requested_by_name LIKE ?)';
      const s = `%${search.trim()}%`;
      params.push(s, s, s, s, s);
    }

    const pageNum = parseInt(page, 10) || 1;
    const limitNum = parseInt(limit, 10) || 50;
    const offset = (pageNum - 1) * limitNum;

    const countSql = `SELECT COUNT(*) as total FROM urgent_hires uh${whereClause}`;
    const [[{ total }]] = await pool.execute(countSql, params);

    const dataSql = `
      SELECT 
        uh.*,
        c.city AS live_client_city,
        c.phone AS live_client_phone,
        cand.full_name AS fulfilled_candidate_name,
        cand.category AS fulfilled_candidate_category,
        cand.phone AS fulfilled_candidate_phone
      FROM urgent_hires uh
      LEFT JOIN clients c ON uh.client_id = c.id
      LEFT JOIN candidates cand ON uh.fulfilled_candidate_id = cand.id
      ${whereClause}
      ORDER BY 
        CASE WHEN uh.status = 'pending' THEN 1 WHEN uh.status = 'in_progress' THEN 2 ELSE 3 END,
        uh.created_at DESC
      LIMIT ${limitNum} OFFSET ${offset}
    `;
    const [urgentHires] = await pool.execute(dataSql, params);

    return res.json({
      success: true,
      data: urgentHires,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum)
      }
    });
  } catch (error) {
    console.error('Error in getUrgentHires:', error);
    return res.status(500).json({ success: false, message: 'Server error while fetching urgent hire requests' });
  }
};

// @route   GET /api/urgent-hires/:id
// @desc    Get urgent hire request by ID
// @access  Private
const getUrgentHireById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute('SELECT * FROM urgent_hires WHERE id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Urgent hire request not found' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (error) {
    console.error('Error in getUrgentHireById:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching urgent hire request' });
  }
};

// @route   POST /api/urgent-hires
// @desc    Create new urgent hire request
// @access  Private
const createUrgentHire = async (req, res) => {
  try {
    const {
      client_id,
      client_name,
      client_phone,
      client_city,
      category,
      service_type,
      work_timings,
      budget_range,
      food_preference,
      gender_preference,
      preferred_languages,
      religion_preference,
      expected_joining,
      notes,
      priority
    } = req.body;

    if (!client_id || !category) {
      return res.status(400).json({ success: false, message: 'client_id and category are required' });
    }

    const urgentHireId = await generateUrgentHireId(pool);
    const requestedById = req.user?.id || null;
    const requestedByName = req.user?.name || 'Sales Representative';

    const insertSql = `
      INSERT INTO urgent_hires (
        id, client_id, client_name, client_phone, client_city,
        requested_by_id, requested_by_name,
        category, service_type, work_timings, budget_range,
        food_preference, gender_preference, preferred_languages,
        religion_preference, expected_joining, notes,
        status, priority
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?)
    `;

    await pool.execute(insertSql, [
      urgentHireId,
      client_id,
      client_name || '',
      client_phone || '',
      client_city || '',
      requestedById,
      requestedByName,
      category,
      service_type || '24 Hours Live-in',
      work_timings || '24 Hours',
      budget_range || '',
      food_preference || 'Any / No Preference',
      gender_preference || 'Female',
      preferred_languages || 'Hindi',
      religion_preference || 'Any / No Preference',
      expected_joining || 'Immediate (Within 1-2 Days)',
      notes || '',
      priority || 'urgent'
    ]);

    // Log to Audit Logs
    await logAction(
      'urgent_hire',
      urgentHireId,
      'create',
      `Urgent Hiring Request created for ${client_name} (${category}, ${service_type || '24 Hours'}). Priority: ${priority || 'urgent'}`,
      requestedById
    );

    const [created] = await pool.execute('SELECT * FROM urgent_hires WHERE id = ?', [urgentHireId]);

    return res.status(201).json({
      success: true,
      message: 'Urgent hiring request submitted to Sourcing team successfully',
      data: created[0]
    });
  } catch (error) {
    console.error('Error in createUrgentHire:', error);
    return res.status(500).json({ success: false, message: 'Failed to create urgent hire request' });
  }
};

// @route   PUT /api/urgent-hires/:id/status
// @desc    Update urgent hire status (in_progress, fulfilled, cancelled)
// @access  Private
const updateUrgentHireStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, fulfilled_candidate_id, notes } = req.body;

    if (!status) {
      return res.status(400).json({ success: false, message: 'Status is required' });
    }

    const [rows] = await pool.execute('SELECT * FROM urgent_hires WHERE id = ?', [id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Urgent hire request not found' });
    }

    const current = rows[0];
    let updateSql = 'UPDATE urgent_hires SET status = ?';
    const params = [status];

    if (fulfilled_candidate_id !== undefined) {
      updateSql += ', fulfilled_candidate_id = ?';
      params.push(fulfilled_candidate_id);
    }
    if (notes !== undefined) {
      updateSql += ', notes = ?';
      params.push(notes);
    }

    updateSql += ' WHERE id = ?';
    params.push(id);

    await pool.execute(updateSql, params);

    // Audit log
    await logAction(
      'urgent_hire',
      id,
      'update',
      `Urgent hiring request status updated to "${status}" for ${current.client_name}`,
      req.user?.id || null
    );

    const [updated] = await pool.execute('SELECT * FROM urgent_hires WHERE id = ?', [id]);

    return res.json({
      success: true,
      message: `Urgent hiring request marked as ${status}`,
      data: updated[0]
    });
  } catch (error) {
    console.error('Error in updateUrgentHireStatus:', error);
    return res.status(500).json({ success: false, message: 'Failed to update urgent hire status' });
  }
};

module.exports = {
  getUrgentHires,
  getUrgentHireById,
  createUrgentHire,
  updateUrgentHireStatus
};
