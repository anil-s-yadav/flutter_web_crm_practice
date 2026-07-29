const apiKeyMiddleware = (req, res, next) => {
  const providedKey = req.headers['x-api-key'];
  const expectedKey = process.env.API_KEY || 'crm-secure-key-2026';

  // Allow unrestricted access to some endpoints if needed (e.g. /uploads for images)
  if (req.path.startsWith('/uploads')) {
    return next();
  }

  if (!providedKey || providedKey !== expectedKey) {
    return res.status(401).json({ message: 'Unauthorized: Invalid API Key' });
  }

  next();
};

module.exports = apiKeyMiddleware;
