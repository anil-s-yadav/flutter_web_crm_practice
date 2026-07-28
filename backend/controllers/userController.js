const pool = require('../config/db');
const bcrypt = require('bcrypt');

// @route   GET /api/users
// @desc    Get all users (Admin only)
// @access  Private/Admin
const getUsers = async (req, res) => {
  try {
    const { role } = req.query;
    let query = 'SELECT id, name, email, role, phone, active, profile_image_url, created_at FROM users';
    const queryParams = [];

    if (role) {
      query += ' WHERE role = ?';
      queryParams.push(role);
    }

    const [users] = await pool.execute(query, queryParams);
    res.json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/users
// @desc    Create a new user (Admin only)
// @access  Private/Admin
const createUser = async (req, res) => {
  try {
    const { name, email, password, role, phone } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Check if user exists
    const [existing] = await pool.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate ID e.g., U_1698765432
    const userId = `U_${Date.now().toString().slice(-6)}`;

    // Handle Image Upload if present
    const profileImageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    await pool.execute(
      'INSERT INTO users (id, name, email, password_hash, role, phone, profile_image_url) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, name, email, hashedPassword, role, phone || null, profileImageUrl]
    );

    res.status(201).json({ message: 'User created successfully', userId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/users/:id
// @desc    Update user details
// @access  Private/Admin (or self)
const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone, role, active } = req.body;

    // Check permissions
    if (req.user.role !== 'admin' && req.user.id !== id) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if user exists
    const [users] = await pool.execute('SELECT * FROM users WHERE id = ?', [id]);
    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = users[0];

    // Determine fields to update
    const newName = name || user.name;
    const newEmail = email || user.email;
    const newPhone = phone !== undefined ? phone : user.phone;
    const newRole = (req.user.role === 'admin' && role) ? role : user.role;
    const newActive = (req.user.role === 'admin' && active !== undefined) ? active === 'true' || active === true : user.active;
    
    let profileImageUrl = user.profile_image_url;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    }

    await pool.execute(
      'UPDATE users SET name = ?, email = ?, phone = ?, role = ?, active = ?, profile_image_url = ? WHERE id = ?',
      [newName, newEmail, newPhone, newRole, newActive, profileImageUrl, id]
    );

    res.json({ message: 'User updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/users/fcm-token
// @desc    Update user's FCM token for push notifications
// @access  Private
const updateFcmToken = async (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({ message: 'FCM token is required' });
    }

    await pool.execute('UPDATE users SET fcm_token = ? WHERE id = ?', [token, req.user.id]);

    res.json({ message: 'FCM token updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getUsers,
  createUser,
  updateUser,
  updateFcmToken
};
