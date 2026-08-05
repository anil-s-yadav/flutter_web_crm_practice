const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { sendPushToUser } = require('../services/notificationService');
const { generateInternalId } = require('../utils/idGenerator');

// @route   GET /api/tasks
// @desc    Get executive tasks
// @access  Private
const getTasks = async (req, res) => {
  try {
    const { status, search, q, page, limit } = req.query;
    let whereClause = ' WHERE 1=1';
    const params = [];

    // If user is executive, only show their tasks
    if (req.user.role === 'executive') {
      whereClause += ' AND assigned_executive_id = ?';
      params.push(req.user.id);
    }
    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (id LIKE ? OR task_type LIKE ? OR client_name LIKE ? OR address LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM executive_tasks${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT * FROM executive_tasks${whereClause} ORDER BY due_date ASC LIMIT ${limitNum} OFFSET ${offset}`;
      const [tasks] = await pool.execute(dataSql, params);

      return res.json({
        data: tasks,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [tasks] = await pool.execute(`SELECT * FROM executive_tasks${whereClause} ORDER BY due_date ASC`, params);
    res.json(tasks);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/tasks
// @desc    Create a new task (manual dispatch)
// @access  Private (Sales/Admin)
const createTask = async (req, res) => {
  try {
    const { title, type, assigned_executive_id, contract_id, due_date, notes } = req.body;

    if (!title || !type || !assigned_executive_id || !due_date) {
      return res.status(400).json({ message: 'Missing required task fields' });
    }

    const taskId = await generateInternalId(pool, 'executive_tasks');

    await pool.execute(
      `INSERT INTO executive_tasks 
      (id, title, type, assigned_executive_id, contract_id, due_date, notes) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [taskId, title, type, assigned_executive_id, contract_id || null, due_date, notes || null]
    );

    // Send push notification to assigned executive
    await sendPushToUser(
      assigned_executive_id, 
      'New Task Assigned', 
      `You have been assigned a new task: ${title}`
    );

    res.status(201).json({ message: 'Task created successfully', taskId, id: taskId });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/tasks/:id/status
// @desc    Update task status
// @access  Private
const updateTaskStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    const [existing] = await pool.execute('SELECT * FROM executive_tasks WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Task not found' });
    }
    
    const task = existing[0];

    // Executive can only update their own tasks
    if (req.user.role === 'executive' && task.assigned_executive_id !== req.user.id) {
      return res.status(403).json({ message: 'Access denied to this task' });
    }

    const newStatus = status || task.status;
    const newNotes = notes !== undefined ? notes : task.notes;
    const completedDate = newStatus === 'completed' ? new Date() : null;

    await pool.execute(
      'UPDATE executive_tasks SET status = ?, notes = ?, completed_date = ? WHERE id = ?',
      [newStatus, newNotes, completedDate, id]
    );

    res.json({ message: 'Task status updated' });
    await logAction('task', id, 'statusChange', `Status updated to ${newStatus}`, req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getTasks,
  createTask,
  updateTaskStatus
};
