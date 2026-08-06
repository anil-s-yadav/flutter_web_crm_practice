const pool = require('../config/db');

// @route   GET /api/search
// @desc    Global search across candidates, clients, contracts, and team users
// @access  Private
const globalSearch = async (req, res) => {
  try {
    const q = req.query.q ? req.query.q.trim() : '';

    if (!q || q.length === 0) {
      return res.json({
        candidates: [],
        clients: [],
        contracts: [],
        users: []
      });
    }

    const searchTerm = `%${q}%`;

    // 1. Search Candidates by full_name, phone, alternate_phone, id, category
    const candidatesQuery = `
      SELECT id, full_name, phone, alternate_phone, category, status 
      FROM candidates 
      WHERE full_name LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR id LIKE ? OR category LIKE ?
      LIMIT 10
    `;

    // 2. Search Clients by name, phone, alternate_phone, email, id
    const clientsQuery = `
      SELECT id, name, phone, alternate_phone, email, status 
      FROM clients 
      WHERE name LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR email LIKE ? OR id LIKE ?
      LIMIT 10
    `;

    // 3. Search Contracts by id, client_id, candidate_id
    const contractsQuery = `
      SELECT c.id, c.client_id, c.candidate_id, c.status, cl.name as client_name, cd.full_name as candidate_name
      FROM contracts c
      LEFT JOIN clients cl ON c.client_id = cl.id
      LEFT JOIN candidates cd ON c.candidate_id = cd.id
      WHERE c.id LIKE ? OR cl.name LIKE ? OR cd.full_name LIKE ?
      LIMIT 10
    `;

    // 4. Search Team Users by name, email, phone, alternate_phone, role, id
    const usersQuery = `
      SELECT id, name, email, phone, alternate_phone, role, active 
      FROM users 
      WHERE name LIKE ? OR email LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR id LIKE ? OR role LIKE ?
      LIMIT 10
    `;
    const usersValues = [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm];

    // 5. Search Tickets
    const ticketsQuery = `
      SELECT id, title, description, priority, status
      FROM tickets
      WHERE title LIKE ? OR description LIKE ? OR id LIKE ?
      LIMIT 10
    `;
    const ticketsValues = [searchTerm, searchTerm, searchTerm];

    const [
      [candidates],
      [clients],
      [contracts],
      [users],
      [tickets]
    ] = await Promise.all([
      pool.execute(candidatesQuery, [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm]),
      pool.execute(clientsQuery, [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm]),
      pool.execute(contractsQuery, [searchTerm, searchTerm, searchTerm]),
      pool.execute(usersQuery, usersValues),
      pool.execute(ticketsQuery, ticketsValues)
    ]);

    res.json({
      candidates,
      clients,
      contracts,
      users,
      tickets
    });
  } catch (err) {
    console.error('Global search error:', err);
    res.status(500).json({ message: 'Error performing search', details: err.message });
  }
};

module.exports = {
  globalSearch
};
