const express = require('express');
const router = express.Router();
const { getAuditLogs } = require('../controllers/auditLogController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

// Only admins can view audit logs
router.get('/', roleMiddleware(['admin']), getAuditLogs);

module.exports = router;
