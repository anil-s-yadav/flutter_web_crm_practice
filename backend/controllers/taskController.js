const pool = require('../config/db');
const { sendPushToUser } = require('../services/notificationService');

// @route   GET /api/tasks
// @desc    Get executive tasks
// @access  Private
const getTasks = async (req, res) => {
  try {
    let query = 'SELECT * FROM executive_tasks';
    const params = [];

    // If user is executive, only show their tasks
    if (req.user.role === 'executive') {
      query += ' WHERE assigned_executive_id = ?';
      params.push(req.user.id);
    }
    
    query += ' ORDER BY due_date ASC';

    const [tasks] = await pool.execute(query, params);
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

    const taskId = `TSK_${Date.now().toString().slice(-6)}`;

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

    res.status(201).json({ message: 'Task created successfully', taskId });
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
