const express = require('express');
const router = express.Router();
const { getUsers, createUser, updateUser, updateFcmToken } = require('../controllers/userController');
const { authMiddleware, roleMiddleware } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

// All user routes require authentication
router.use(authMiddleware);

// Admin only routes
router.get('/', roleMiddleware(['admin']), getUsers);
router.post('/', roleMiddleware(['admin']), upload.single('profile_image'), createUser);

// Update user (admin can update anyone, users can update themselves)
// We use upload.single('profile_image') to handle multipart/form-data for image uploads
router.put('/:id', upload.single('profile_image'), updateUser);

// Update FCM Token for current logged-in user
router.put('/fcm-token/update', updateFcmToken);

module.exports = router;
