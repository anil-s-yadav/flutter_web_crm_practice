const express = require('express');
const router = express.Router();
const { getContracts, createContract, recordPayment } = require('../controllers/contractController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getContracts);
router.post('/', roleMiddleware(['admin', 'sales']), createContract);
router.put('/:id/payment', roleMiddleware(['admin', 'sales']), recordPayment);

module.exports = router;
