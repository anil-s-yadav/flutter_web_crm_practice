const express = require('express');
const router = express.Router();
const { getAuditLogs } = require('../controllers/auditLogController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

// Allow all authenticated users, controller will filter by role
router.get('/', getAuditLogs);

module.exports = router;
