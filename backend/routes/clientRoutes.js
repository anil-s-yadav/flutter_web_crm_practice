const express = require('express');
const router = express.Router();
const { getClients, createClient, updateClient } = require('../controllers/clientController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.use(authMiddleware);

router.get('/', getClients);
router.post('/', roleMiddleware(['admin', 'sales']), createClient);
router.put('/:id', roleMiddleware(['admin', 'sales']), upload.single('profile_image'), updateClient);

module.exports = router;
