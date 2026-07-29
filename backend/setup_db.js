require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function setupDatabase() {
  try {
    // 1. Connect without database to create the database if it doesn't exist
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      multipleStatements: true // Allow executing multiple queries from a file
    });

    console.log('Connected to MySQL server.');

    const sqlScriptPath = path.join(__dirname, 'database_setup.sql');
    const sql = fs.readFileSync(sqlScriptPath, 'utf8');

    console.log('Executing database_setup.sql...');
    await connection.query(sql);

    console.log('Database and tables created successfully!');
    await connection.end();
  } catch (err) {
    console.error('Error setting up the database:', err);
  }
}

setupDatabase();
