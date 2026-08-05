require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
const seedUsers = require('./seed_users');

async function rebuild() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  });

  try {
    const dbName = process.env.DB_NAME || 'verifiedmaids_db';
    console.log(`Rebuilding database: ${dbName}...`);

    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    await connection.query(`USE \`${dbName}\`;`);

    // Disable FK checks and drop all existing tables
    await connection.query('SET FOREIGN_KEY_CHECKS = 0;');
    const tables = [
      'audit_logs',
      'replacement_suggestions',
      'replacement_requests',
      'executive_tasks',
      'tickets',
      'notifications',
      'contracts',
      'candidates',
      'clients',
      'users'
    ];

    for (const t of tables) {
      await connection.query(`DROP TABLE IF EXISTS \`${t}\`;`);
      console.log(`Dropped table: ${t}`);
    }
    await connection.query('SET FOREIGN_KEY_CHECKS = 1;');

    // Read and execute database_setup.sql
    const sqlPath = path.join(__dirname, 'database_setup.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    await connection.query(sql);
    console.log('Executed database_setup.sql successfully.');

    await connection.end();

    // Seed clean VMU users
    console.log('Seeding initial users...');
    await seedUsers();

    console.log('✅ All tables successfully rebuilt with created_at and updated_at as last columns!');
  } catch (err) {
    console.error('Error rebuilding tables:', err);
    await connection.end();
    process.exit(1);
  }
}

if (require.main === module) {
  rebuild();
}

module.exports = rebuild;
