/**
 * Centralized ID Sequence Generator for Verified Maids CRM
 * 
 * Standards:
 * - Candidates: CN00000001 (CN + 8 digits)
 * - Clients:    VM00000001 (VM + 8 digits)
 * - Contracts:  CNT00000001 (CNT + 8 digits)
 * - Tickets:    TCK-1, TCK-2, ... (TCK- + sequential int)
 * - Users:      VMU0001, VMU0002, ... (VMU + 4 digits)
 * - Internal:   1, 2, 3, ... (Sequential numeric strings/integers)
 */

async function generateCandidateId(db) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) AS max_num 
     FROM candidates 
     WHERE id REGEXP '^CN[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return `CN${String(nextNum).padStart(8, '0')}`;
}

async function generateClientId(db) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) AS max_num 
     FROM clients 
     WHERE id REGEXP '^VM[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return `VM${String(nextNum).padStart(8, '0')}`;
}

async function generateContractId(db) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(SUBSTRING(id, 4) AS UNSIGNED)) AS max_num 
     FROM contracts 
     WHERE id REGEXP '^CNT[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return `CNT${String(nextNum).padStart(8, '0')}`;
}

async function generateTicketId(db) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(SUBSTRING(id, 5) AS UNSIGNED)) AS max_num 
     FROM tickets 
     WHERE id REGEXP '^TCK-[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return `TCK-${nextNum}`;
}

async function generateUserId(db) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(SUBSTRING(id, 4) AS UNSIGNED)) AS max_num 
     FROM users 
     WHERE id REGEXP '^VMU[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return `VMU${String(nextNum).padStart(4, '0')}`;
}

async function generateInternalId(db, tableName) {
  const [rows] = await db.query(
    `SELECT MAX(CAST(id AS UNSIGNED)) AS max_num 
     FROM \`${tableName}\` 
     WHERE id REGEXP '^[0-9]+$'`
  );
  const nextNum = (rows[0]?.max_num || 0) + 1;
  return String(nextNum);
}

module.exports = {
  generateCandidateId,
  generateClientId,
  generateContractId,
  generateTicketId,
  generateUserId,
  generateInternalId
};
