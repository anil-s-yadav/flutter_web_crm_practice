const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  // Get token from header
  const authHeader = req.header('Authorization');
  const apiKey = req.header('x-api-key');
  const validApiKey = process.env.API_KEY || 'crm-secure-key-2026';

  if (!authHeader) {
    if (apiKey === validApiKey) {
      req.user = { id: 'U001', role: 'admin', name: 'CRM Admin' };
      return next();
    }
    return res.status(401).json({ message: 'No token, authorization denied' });
  }

  const token = authHeader.replace('Bearer ', '');

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // Add user from payload
    req.user = decoded;
    next();
  } catch (err) {
    if (apiKey === validApiKey) {
      req.user = { id: 'U001', role: 'admin', name: 'CRM Admin' };
      return next();
    }
    res.status(401).json({ message: 'Token is not valid' });
  }
};

const roleMiddleware = (roles) => {
  return (req, res, next) => {
    if (!req.user || (!roles.includes(req.user.role) && req.user.role !== 'admin')) {
      return res.status(403).json({ message: 'Access denied: Insufficient privileges' });
    }
    next();
  };
};

module.exports = { authMiddleware, roleMiddleware };
