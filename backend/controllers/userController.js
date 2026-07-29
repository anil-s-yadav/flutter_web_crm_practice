const pool = require('../config/db');
const bcrypt = require('bcrypt');
const { isPhoneGloballyUnique } = require('../utils/phoneValidator');

// @route   GET /api/users
// @desc    Get all users (Admin only)
// @access  Private/Admin
const getUsers = async (req, res) => {
  try {
    const { role, active, search, q, page, limit } = req.query;
    let whereClause = ' WHERE 1=1';
    const queryParams = [];

    if (role) {
      whereClause += ' AND role = ?';
      queryParams.push(role);
    }
    if (active !== undefined) {
      whereClause += ' AND active = ?';
      queryParams.push(active === 'true' || active === '1');
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (name LIKE ? OR email LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      queryParams.push(s, s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM users${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, queryParams);

      const dataSql = `SELECT id, name, email, role, phone, alternate_phone, active, profile_image_url, created_at FROM users${whereClause} ORDER BY created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [users] = await pool.execute(dataSql, queryParams);

      return res.json({
        data: users,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [users] = await pool.execute(`SELECT id, name, email, role, phone, alternate_phone, active, profile_image_url, created_at FROM users${whereClause} ORDER BY created_at DESC`, queryParams);
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
    const { name, email, password, role, phone, alternate_phone } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Check if user exists
    const [existing] = await pool.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }

    if (phone) {
      const isUnique = await isPhoneGloballyUnique(phone);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate ID e.g., U_1698765432
    const userId = `U_${Date.now().toString().slice(-6)}`;

    // Handle Image Upload if present
    const profileImageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    await pool.execute(
      'INSERT INTO users (id, name, email, password_hash, role, phone, alternate_phone, profile_image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [userId, name, email, hashedPassword, role, phone || null, alternate_phone || null, profileImageUrl]
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
    const { name, email, phone, alternate_phone, role, active } = req.body;

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
    const newAlternatePhone = alternate_phone !== undefined ? alternate_phone : user.alternate_phone;
    const newRole = (req.user.role === 'admin' && role) ? role : user.role;
    const newActive = (req.user.role === 'admin' && active !== undefined) ? (active === 'true' || active === true || active === 1) : user.active;

    let newPasswordHash = user.password_hash;
    if (password && password.trim().length > 0) {
      const salt = await bcrypt.genSalt(10);
      newPasswordHash = await bcrypt.hash(password.trim(), salt);
    }

    if (newPhone && newPhone !== user.phone) {
      const isUnique = await isPhoneGloballyUnique(newPhone, id);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }
    
    let profileImageUrl = user.profile_image_url;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    }

    await pool.execute(
      'UPDATE users SET name = ?, email = ?, password_hash = ?, phone = ?, alternate_phone = ?, role = ?, active = ?, profile_image_url = ? WHERE id = ?',
      [newName, newEmail, newPasswordHash, newPhone, newAlternatePhone, newRole, newActive, profileImageUrl, id]
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
