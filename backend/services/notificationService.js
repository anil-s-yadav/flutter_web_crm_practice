const admin = require('firebase-admin');
const pool = require('../config/db');

// The path to your service account key will be provided by the user manually
const serviceAccountPath = require('path').resolve(__dirname, '../serviceAccountKey.json');

let isInitialized = false;

try {
  // We only initialize if the user has downloaded the key
  if (require('fs').existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    isInitialized = true;
    console.log('Firebase Admin initialized successfully.');
  } else {
    console.warn('Firebase Admin NOT initialized. serviceAccountKey.json is missing.');
  }
} catch (err) {
  console.error('Failed to initialize Firebase Admin:', err);
}

/**
 * Sends a push notification to a specific user
 * @param {string} userId - The ID of the user to send the notification to
 * @param {string} title - The notification title
 * @param {string} body - The notification body
 */
const sendPushToUser = async (userId, title, body) => {
  if (!isInitialized) {
    console.log(`[SIMULATED PUSH] To User ${userId}: ${title} - ${body}`);
    return;
  }

  try {
    const [rows] = await pool.execute('SELECT fcm_token FROM users WHERE id = ?', [userId]);
    
    if (rows.length === 0 || !rows[0].fcm_token) {
      console.log(`User ${userId} has no FCM token registered. Push not sent.`);
      return;
    }

    const token = rows[0].fcm_token;

    const message = {
      notification: {
        title,
        body
      },
      token
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
  } catch (err) {
    console.error('Error sending push notification:', err);
  }
};

module.exports = {
  sendPushToUser
};
