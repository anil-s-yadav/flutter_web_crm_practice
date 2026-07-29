require('dotenv').config();
const mysql = require('mysql2/promise');

async function runMigration() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    console.log('Connected. Running migrations...');

    // Users
    try {
      await connection.execute('ALTER TABLE users ADD COLUMN alternate_phone VARCHAR(20)');
      console.log('Added alternate_phone to users');
    } catch (e) { console.log('users.alternate_phone might already exist or error: ', e.message); }
    try {
      await connection.execute('ALTER TABLE users ADD CONSTRAINT unique_phone_users UNIQUE(phone)');
      console.log('Added unique constraint to users.phone');
    } catch (e) { console.log('users.phone unique constraint might already exist or error: ', e.message); }

    // Clients
    try {
      await connection.execute('ALTER TABLE clients ADD COLUMN alternate_phone VARCHAR(20)');
      console.log('Added alternate_phone to clients');
    } catch (e) { console.log('clients.alternate_phone might already exist or error: ', e.message); }
    try {
      await connection.execute('ALTER TABLE clients ADD CONSTRAINT unique_phone_clients UNIQUE(phone)');
      console.log('Added unique constraint to clients.phone');
    } catch (e) { console.log('clients.phone unique constraint might already exist or error: ', e.message); }

    // Candidates
    try {
      await connection.execute('ALTER TABLE candidates ADD COLUMN alternate_phone VARCHAR(20)');
      console.log('Added alternate_phone to candidates');
    } catch (e) { console.log('candidates.alternate_phone might already exist or error: ', e.message); }
    try {
      await connection.execute('ALTER TABLE candidates ADD CONSTRAINT unique_phone_candidates UNIQUE(phone)');
      console.log('Added unique constraint to candidates.phone');
    } catch (e) { console.log('candidates.phone unique constraint might already exist or error: ', e.message); }

    console.log('Migration complete!');
    await connection.end();
  } catch (err) {
    console.error('Migration failed:', err);
  }
}

runMigration();
