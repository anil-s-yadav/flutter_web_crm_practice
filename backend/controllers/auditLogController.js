const pool = require('../config/db');

// @route   GET /api/audit-logs
// @desc    Get all audit logs
// @access  Private (Admin)
const getAuditLogs = async (req, res) => {
  try {
    const { search, q, page, limit } = req.query;
    let whereClause = ' WHERE 1=1';
    const params = [];

    // Filter for non-admin users to only see their own activity
    if (req.user.role !== 'admin') {
      whereClause += ' AND a.performed_by = ?';
      params.push(req.user.id);
    }

    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (a.description LIKE ? OR a.action LIKE ? OR u.name LIKE ? OR a.entity_id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM audit_logs a LEFT JOIN users u ON a.performed_by = u.id${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `
        SELECT a.id, a.timestamp, a.action as actionType, a.entity_id as targetId, a.description,
               u.id as userId, u.name as userName, u.role as userRole
        FROM audit_logs a
        LEFT JOIN users u ON a.performed_by = u.id
        ${whereClause}
        ORDER BY a.timestamp DESC
        LIMIT ${limitNum} OFFSET ${offset}
      `;
      const [logs] = await pool.execute(dataSql, params);

      const mappedLogs = logs.map(log => ({
        id: log.id.toString(),
        timestamp: log.timestamp,
        userId: log.userId,
        userName: log.userName || 'System',
        userRole: log.userRole || 'admin',
        actionType: log.actionType,
        targetId: log.targetId,
        description: log.description,
      }));

      return res.json({
        data: mappedLogs,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const query = `
      SELECT a.id, a.timestamp, a.action as actionType, a.entity_id as targetId, a.description,
             u.id as userId, u.name as userName, u.role as userRole
      FROM audit_logs a
      LEFT JOIN users u ON a.performed_by = u.id
      ${whereClause}
      ORDER BY a.timestamp DESC
      LIMIT 100
    `;
    const [logs] = await pool.execute(query, params);
    
    // Map to match Flutter's AuditLogModel
    const mappedLogs = logs.map(log => ({
      id: log.id.toString(),
      timestamp: log.timestamp,
      userId: log.userId,
      userName: log.userName || 'System',
      userRole: log.userRole || 'admin',
      actionType: log.actionType,
      targetId: log.targetId,
      description: log.description
    }));

    res.json(mappedLogs);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error fetching audit logs' });
  }
};

// @route   POST /api/audit-logs
// @desc    Create a new audit log entry
// @access  Private
const createAuditLog = async (req, res) => {
  try {
    const { entityType, entityId, targetId, action, actionType, description } = req.body;
    const finalEntity = entityType || 'candidate';
    const finalTargetId = targetId || entityId;
    const finalAction = actionType || action || 'statusChange';
    const performedBy = req.user?.id || 'system';

    if (!finalTargetId || !description) {
      return res.status(400).json({ message: 'Target ID and description are required' });
    }

    const { logAction } = require('../services/auditService');
    await logAction(finalEntity, finalTargetId, finalAction, description, performedBy);

    res.status(201).json({ message: 'Audit log created successfully' });
  } catch (err) {
    console.error('createAuditLog error:', err);
    res.status(500).json({ message: 'Server error creating audit log' });
  }
};

module.exports = {
  getAuditLogs,
  createAuditLog
};
