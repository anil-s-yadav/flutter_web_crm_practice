const pool = require('../config/db');

/**
 * Logs an action to the audit_logs table
 * @param {string} entityType - The type of entity (e.g., 'candidate', 'client', 'contract')
 * @param {string} entityId - The ID of the target entity
 * @param {string} action - The action type (e.g., 'create', 'update', 'statusChange')
 * @param {string} description - A detailed description of the action
 * @param {string} performedBy - The ID of the user performing the action
 */
const logAction = async (entityType, entityId, action, description, performedBy) => {
  try {
    await pool.execute(
      `INSERT INTO audit_logs (entity_type, entity_id, action, description, performed_by)
       VALUES (?, ?, ?, ?, ?)`,
      [entityType, entityId, action, description, performedBy]
    );
  } catch (err) {
    console.error('Failed to log audit action:', err);
  }
};

module.exports = {
  logAction
};
