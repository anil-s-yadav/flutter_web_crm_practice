const express = require('express');
const router = express.Router();
const { 
  getReplacements, 
  createReplacement, 
  escalateReplacement, 
  suggestCandidates, 
  resolveReplacement 
} = require('../controllers/replacementController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getReplacements);
router.post('/', roleMiddleware(['admin', 'sales']), createReplacement);
router.put('/:id/escalate', roleMiddleware(['admin', 'sales']), escalateReplacement);
router.put('/:id/suggest', roleMiddleware(['admin', 'sourcing']), suggestCandidates);
router.put('/:id/resolve', roleMiddleware(['admin', 'sales']), resolveReplacement);

module.exports = router;
