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

    console.log('Connected to Database. Seeding users...');

    const users = [
      { id: 'U_ADMIN_001', name: 'System Admin', email: 'admin@example.com', password: 'password123', role: 'admin' },
      { id: 'U_SALES_001', name: 'Sales Agent', email: 'sales@example.com', password: 'password123', role: 'sales' },
      { id: 'U_SOURCING_001', name: 'Sourcing Agent', email: 'sourcing@example.com', password: 'password123', role: 'sourcing' },
      { id: 'U_EXEC_001', name: 'Executive', email: 'executive@example.com', password: 'password123', role: 'executive' },
    ];

    for (const u of users) {
      const hash = await bcrypt.hash(u.password, 10);
      await connection.execute(
        `INSERT INTO users (id, name, email, password_hash, role) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, role=?, password_hash=?`,
        [u.id, u.name, u.email, hash, u.role, u.name, u.role, hash]
      );
      console.log(`Inserted user: ${u.email} / ${u.password}`);
    }

    console.log('Seeding complete!');
    await connection.end();
  } catch (err) {
    console.error('Error seeding users:', err);
  }
}

seedUsers();
