const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// Create a connection pool to the database
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'verifiedmaids_db',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test the connection
pool.getConnection()
  .then(async (connection) => {
    console.log('Successfully connected to the MySQL Database.');
    connection.release();
  })

  .catch((err) => {
    console.error('Error connecting to the database. Make sure XAMPP MySQL is running and the database exists.', err.message);
  });

module.exports = pool;
