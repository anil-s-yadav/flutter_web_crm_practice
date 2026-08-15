const pool = require('../config/db');

// @route   GET /api/learnings
// @desc    Get all active learning topics scoped by user role
// @access  Private
const getLearningTopics = async (req, res) => {
  try {
    const { category, search, role_filter } = req.query;
    const userRole = req.user ? req.user.role : 'all';

    let whereClause = ' WHERE is_active = TRUE';
    const params = [];

    // Role-based visibility: Non-admins only see 'all' + their specific role
    if (userRole !== 'admin' && userRole !== 'manager') {
      whereClause += ' AND (target_role = ? OR target_role = "all")';
      params.push(userRole);
    } else if (role_filter && role_filter !== 'all') {
      whereClause += ' AND target_role = ?';
      params.push(role_filter);
    }

    if (category && category !== 'all') {
      whereClause += ' AND category = ?';
      params.push(category);
    }

    if (search && search.trim().length > 0) {
      const q = `%${search.trim()}%`;
      whereClause += ' AND (title LIKE ? OR subtitle LIKE ? OR script_english LIKE ? OR script_hindi LIKE ? OR key_tip LIKE ?)';
      params.push(q, q, q, q, q);
    }

    const sql = `SELECT * FROM learning_topics ${whereClause} ORDER BY order_index ASC, created_at ASC`;
    const [rows] = await pool.execute(sql, params);

    const formatted = rows.map(r => ({
      ...r,
      bullet_points: typeof r.bullet_points === 'string' ? JSON.parse(r.bullet_points || '[]') : (r.bullet_points || []),
      tags: typeof r.tags === 'string' ? JSON.parse(r.tags || '[]') : (r.tags || [])
    }));

    res.json({
      success: true,
      count: formatted.length,
      data: formatted
    });
  } catch (err) {
    console.error('Error fetching learning topics:', err);
    res.status(500).json({ message: 'Server error fetching learning topics' });
  }
};

// @route   POST /api/learnings
// @desc    Create a new learning topic (Admin only)
// @access  Private (Admin)
const createLearningTopic = async (req, res) => {
  try {
    const {
      id,
      category,
      title,
      subtitle,
      target_role,
      script_english,
      script_hindi,
      key_tip,
      bullet_points,
      tags,
      order_index
    } = req.body;

    if (!category || !title || !subtitle) {
      return res.status(400).json({ message: 'Category, title, and subtitle are required' });
    }

    const topicId = id || `LRN${Date.now().toString().slice(-6)}`;
    const bulletsJson = JSON.stringify(bullet_points || []);
    const tagsJson = JSON.stringify(tags || []);

    await pool.execute(
      `INSERT INTO learning_topics 
      (id, category, title, subtitle, target_role, script_english, script_hindi, key_tip, bullet_points, tags, order_index) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        topicId,
        category,
        title,
        subtitle,
        target_role || 'all',
        script_english || '',
        script_hindi || '',
        key_tip || '',
        bulletsJson,
        tagsJson,
        order_index || 0
      ]
    );

    const [created] = await pool.execute('SELECT * FROM learning_topics WHERE id = ?', [topicId]);
    res.status(201).json({
      success: true,
      message: 'Learning topic created successfully',
      data: created[0]
    });
  } catch (err) {
    console.error('Error creating learning topic:', err);
    res.status(500).json({ message: 'Server error creating learning topic' });
  }
};

// @route   PUT /api/learnings/:id
// @desc    Update a learning topic (Admin only)
// @access  Private (Admin)
const updateLearningTopic = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      category,
      title,
      subtitle,
      target_role,
      script_english,
      script_hindi,
      key_tip,
      bullet_points,
      tags,
      order_index,
      is_active
    } = req.body;

    const updates = [];
    const params = [];

    if (category) { updates.push('category = ?'); params.push(category); }
    if (title) { updates.push('title = ?'); params.push(title); }
    if (subtitle) { updates.push('subtitle = ?'); params.push(subtitle); }
    if (target_role) { updates.push('target_role = ?'); params.push(target_role); }
    if (script_english !== undefined) { updates.push('script_english = ?'); params.push(script_english); }
    if (script_hindi !== undefined) { updates.push('script_hindi = ?'); params.push(script_hindi); }
    if (key_tip !== undefined) { updates.push('key_tip = ?'); params.push(key_tip); }
    if (bullet_points !== undefined) { updates.push('bullet_points = ?'); params.push(JSON.stringify(bullet_points)); }
    if (tags !== undefined) { updates.push('tags = ?'); params.push(JSON.stringify(tags)); }
    if (order_index !== undefined) { updates.push('order_index = ?'); params.push(order_index); }
    if (is_active !== undefined) { updates.push('is_active = ?'); params.push(is_active); }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields provided for update' });
    }

    params.push(id);
    await pool.execute(`UPDATE learning_topics SET ${updates.join(', ')} WHERE id = ?`, params);

    const [updated] = await pool.execute('SELECT * FROM learning_topics WHERE id = ?', [id]);
    if (updated.length === 0) {
      return res.status(404).json({ message: 'Learning topic not found' });
    }

    res.json({
      success: true,
      message: 'Learning topic updated successfully',
      data: updated[0]
    });
  } catch (err) {
    console.error('Error updating learning topic:', err);
    res.status(500).json({ message: 'Server error updating learning topic' });
  }
};

// @route   DELETE /api/learnings/:id
// @desc    Soft-delete/deactivate a learning topic (Admin only)
// @access  Private (Admin)
const deleteLearningTopic = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.execute('UPDATE learning_topics SET is_active = FALSE WHERE id = ?', [id]);
    res.json({ success: true, message: 'Learning topic deleted successfully' });
  } catch (err) {
    console.error('Error deleting learning topic:', err);
    res.status(500).json({ message: 'Server error deleting learning topic' });
  }
};

module.exports = {
  getLearningTopics,
  createLearningTopic,
  updateLearningTopic,
  deleteLearningTopic
};
