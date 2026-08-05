require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

async function seedUsers() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    console.log('Connected to Database. Seeding clean users with VMU format...');

    const users = [
      { id: 'VMU0001', name: 'System Admin', email: 'admin@example.com', password: 'password123', role: 'admin' },
      { id: 'VMU0002', name: 'Ajay Gupta', email: 'sales@example.com', password: 'password123', role: 'sales' },
      { id: 'VMU0003', name: 'Anil Shah', email: 'sourcing@example.com', password: 'password123', role: 'sourcing' },
      { id: 'VMU0004', name: 'Deepak Laale', email: 'executive@example.com', password: 'password123', role: 'executive' },
    ];

    for (const u of users) {
      const hash = await bcrypt.hash(u.password, 10);
      await connection.execute(
        `INSERT INTO users (id, name, email, password_hash, role) 
         VALUES (?, ?, ?, ?, ?) 
         ON DUPLICATE KEY UPDATE name=?, role=?, password_hash=?`,
        [u.id, u.name, u.email, hash, u.role, u.name, u.role, hash]
      );
      console.log(`Configured user: ${u.id} - ${u.name} (${u.role}) - ${u.email}`);
    }

    console.log('User seeding complete!');
    await connection.end();
  } catch (err) {
    console.error('Error seeding users:', err);
  }
}

if (require.main === module) {
  seedUsers();
}

module.exports = seedUsers;
