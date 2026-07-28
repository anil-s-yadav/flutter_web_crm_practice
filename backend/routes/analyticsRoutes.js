const express = require('express');
const router = express.Router();
const { 
  getAdminAnalytics, 
  getSalesAnalytics, 
  getSourcingAnalytics, 
  getExecutiveAnalytics 
} = require('../controllers/analyticsController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/admin', roleMiddleware(['admin']), getAdminAnalytics);
router.get('/sales', roleMiddleware(['admin', 'sales']), getSalesAnalytics);
router.get('/sourcing', roleMiddleware(['admin', 'sourcing']), getSourcingAnalytics);
router.get('/executive', roleMiddleware(['admin', 'executive']), getExecutiveAnalytics);

module.exports = router;
