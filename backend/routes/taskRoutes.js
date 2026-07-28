const express = require('express');
const router = express.Router();
const { getTasks, createTask, updateTaskStatus } = require('../controllers/taskController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getTasks);
router.post('/', roleMiddleware(['admin', 'sales']), createTask);
router.put('/:id/status', updateTaskStatus);

module.exports = router;
