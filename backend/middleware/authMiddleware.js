const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  // Get token from header
  const authHeader = req.header('Authorization');
  if (!authHeader) {
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
    res.status(401).json({ message: 'Token is not valid' });
  }
};

const roleMiddleware = (roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Access denied: Insufficient privileges' });
    }
    next();
  };
};

module.exports = { authMiddleware, roleMiddleware };
