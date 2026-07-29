const express = require('express');
const router = express.Router();
const { globalSearch } = require('../controllers/searchController');
const { authMiddleware } = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', globalSearch);

module.exports = router;
