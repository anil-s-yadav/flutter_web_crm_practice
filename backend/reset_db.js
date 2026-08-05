require('dotenv').config();
const mysql = require('mysql2/promise');
const seedUsers = require('./seed_users');

async function resetDb() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    console.log('Disabling foreign key checks to safely truncate tables...');
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

    for (const table of tables) {
      try {
        await connection.query(`TRUNCATE TABLE \`${table}\``);
        console.log(`Truncated table: ${table}`);
      } catch (err) {
        console.warn(`Could not truncate ${table}:`, err.message);
      }
    }

    await connection.query('SET FOREIGN_KEY_CHECKS = 1;');
    console.log('Re-enabled foreign key checks.');
    await connection.end();

    console.log('Seeding fresh users...');
    await seedUsers();

    console.log('✅ Database reset and seeded successfully!');
  } catch (err) {
    console.error('Error resetting database:', err);
    if (connection) await connection.end();
  }
}

if (require.main === module) {
  resetDb();
}

module.exports = resetDb;
