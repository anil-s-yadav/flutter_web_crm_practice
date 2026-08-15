const express = require('express');
const router = express.Router();
const {
  getLearningTopics,
  createLearningTopic,
  updateLearningTopic,
  deleteLearningTopic
} = require('../controllers/learningController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getLearningTopics);
router.post('/', roleMiddleware(['admin']), createLearningTopic);
router.put('/:id', roleMiddleware(['admin']), updateLearningTopic);
router.delete('/:id', roleMiddleware(['admin']), deleteLearningTopic);

module.exports = router;
