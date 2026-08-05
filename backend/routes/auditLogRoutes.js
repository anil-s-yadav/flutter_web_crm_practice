const express = require('express');
const router = express.Router();
const { getAuditLogs, createAuditLog } = require('../controllers/auditLogController');
const { authMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

// Allow all authenticated users, controller will filter by role
router.get('/', getAuditLogs);
router.post('/', createAuditLog);

module.exports = router;
