const pool = require('../config/db');

/**
 * Checks if a phone number is already used by a user, client, or candidate.
 * Returns true if it exists, false otherwise.
 */
async function isPhoneGloballyUnique(phone, currentEntityId = null) {
  if (!phone) return true;

  // We check if the phone exists in any of the three tables.
  // We use currentEntityId to ignore the row we are currently updating.
  let query = `
    SELECT id, 'user' as type FROM users WHERE phone = ?
    UNION
    SELECT id, 'client' as type FROM clients WHERE phone = ?
    UNION
    SELECT id, 'candidate' as type FROM candidates WHERE phone = ?
  `;

  const [rows] = await pool.execute(query, [phone, phone, phone]);

  if (rows.length === 0) {
    return true; // No matches found
  }

  // If there's a match, and we passed currentEntityId, check if it's the exact same entity.
  // Since IDs should be globally unique, if the matching ID is the same, it's valid.
  if (rows.length === 1 && currentEntityId && rows[0].id === currentEntityId) {
    return true;
  }

  return false;
}

module.exports = {
  isPhoneGloballyUnique
};
