const express = require('express');
const router = express.Router();
const { 
  getCandidates, 
  getCandidateById, 
  createCandidate, 
  updateCandidateStatus 
} = require('../controllers/candidateController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.use(authMiddleware);

router.get('/', getCandidates);
router.get('/:id', getCandidateById);
router.post('/', roleMiddleware(['admin', 'sourcing']), upload.single('profile_image'), createCandidate);
router.put('/:id/status', roleMiddleware(['admin', 'sourcing']), updateCandidateStatus);

module.exports = router;
