require('dotenv').config();
const mysql = require('mysql2/promise');

async function checkColumns() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  const [tables] = await connection.query('SHOW TABLES');
  const dbName = process.env.DB_NAME || 'verifiedmaids_db';

  for (const t of tables) {
    const tableName = Object.values(t)[0];
    const [cols] = await connection.query(`
      SELECT COLUMN_NAME, ORDINAL_POSITION, DATA_TYPE 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? 
      ORDER BY ORDINAL_POSITION
    `, [dbName, tableName]);
    console.log('=== TABLE:', tableName, '===');
    cols.forEach(c => console.log(`  ${c.ORDINAL_POSITION}. ${c.COLUMN_NAME} (${c.DATA_TYPE})`));
  }

  await connection.end();
}

checkColumns().catch(e => { console.error(e); process.exit(1); });
