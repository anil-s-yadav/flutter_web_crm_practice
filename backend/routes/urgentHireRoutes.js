const express = require('express');
const router = express.Router();
const {
  getUrgentHires,
  getUrgentHireById,
  createUrgentHire,
  updateUrgentHireStatus
} = require('../controllers/urgentHireController');
const { authMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.route('/')
  .get(getUrgentHires)
  .post(createUrgentHire);

router.route('/:id')
  .get(getUrgentHireById);

router.route('/:id/status')
  .put(updateUrgentHireStatus);

module.exports = router;
