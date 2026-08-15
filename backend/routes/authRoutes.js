const express = require('express');
const router = express.Router();
const { login, getMe } = require('../controllers/authController');
const { authMiddleware } = require('../middleware/authMiddleware');
const rateLimit = require('express-rate-limit');

// Rate limiting for login (bypassed in development mode, max 5 attempts per 15 mins in production)
const isProduction = process.env.NODE_ENV === 'production';

const loginLimiter = isProduction
  ? rateLimit({
      windowMs: 15 * 60 * 1000, 
      max: 5, 
      message: { message: 'Too many login attempts, please try again after 15 minutes' },
      standardHeaders: true,
      legacyHeaders: false,
    })
  : (req, res, next) => next();

router.post('/login', loginLimiter, login);
router.get('/me', authMiddleware, getMe);

module.exports = router;
