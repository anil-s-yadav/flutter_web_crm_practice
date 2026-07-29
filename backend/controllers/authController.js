const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// @route   POST /api/auth/login
// @desc    Authenticate user & get token
// @access  Public
const login = async (req, res) => {
  try {
    const identifier = req.body.email; // Can be email or phone
    const password = req.body.password;

    if (!identifier || !password) {
      return res.status(400).json({ message: 'Please provide email/mobile and password' });
    }

    const [users] = await pool.execute('SELECT * FROM users WHERE email = ? OR phone = ?', [identifier, identifier]);
    if (users.length === 0) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const user = users[0];

    if (!user.active) {
      return res.status(403).json({ message: 'Account is inactive. Please contact admin.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Create JWT Payload
    const payload = {
      id: user.id,
      name: user.name,
      role: user.role,
    };

    // Sign Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '24h' },
      (err, token) => {
        if (err) throw err;
        res.json({
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            profile_image_url: user.profile_image_url
          }
        });
      }
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/auth/me
// @desc    Get current logged in user
// @access  Private
const getMe = async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT id, name, email, role, phone, alternate_phone, active, profile_image_url, created_at FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(users[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  login,
  getMe
};
