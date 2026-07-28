const mysql = require('mysql2/promise');
require('dotenv').config();

// Create a connection pool to the database
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'crm_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test the connection
pool.getConnection()
  .then((connection) => {
    console.log('Successfully connected to the MySQL Database.');
    connection.release();
  })
  .catch((err) => {
    console.error('Error connecting to the database. Make sure XAMPP MySQL is running and the database exists.', err.message);
  });

module.exports = pool;
