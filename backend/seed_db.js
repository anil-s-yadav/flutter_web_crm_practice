const pool = require('./config/db');
const { v4: uuidv4 } = require('uuid');

const clients = Array.from({ length: 10 }).map((_, i) => ({
  id: `CLI-SEED-${uuidv4().substring(0, 8)}`,
  name: `Client Name ${i + 1}`,
  phone: `9876543${i.toString().padStart(3, '0')}`,
  status: 'followUp',
  preferred_category: 'House Maid',
  city: 'Mumbai',
  service_type: '24 Hours Live-in'
}));

const candidates = Array.from({ length: 10 }).map((_, i) => ({
  id: `CAN-SEED-${uuidv4().substring(0, 8)}`,
  full_name: `Candidate Name ${i + 1}`,
  phone: `8765432${i.toString().padStart(3, '0')}`,
  category: 'House Maid',
  status: 'readyToPlace',
  city: 'Mumbai',
  expected_salary: '15000',
  is_police_verified: 1,
  is_medical_cleared: 1
}));

(async () => {
  try {
    for (const client of clients) {
      await pool.execute(
        `INSERT INTO clients (id, name, phone, status, preferred_category, city, service_type) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [client.id, client.name, client.phone, client.status, client.preferred_category, client.city, client.service_type]
      );
    }
    console.log(`Inserted 10 clients.`);

    for (const candidate of candidates) {
      await pool.execute(
        `INSERT INTO candidates (id, full_name, phone, category, status, city, expected_salary, is_police_verified, is_medical_cleared) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [candidate.id, candidate.full_name, candidate.phone, candidate.category, candidate.status, candidate.city, candidate.expected_salary, candidate.is_police_verified, candidate.is_medical_cleared]
      );
    }
    console.log(`Inserted 10 candidates.`);

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
