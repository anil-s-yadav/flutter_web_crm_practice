const pool = require('./config/db');
(async () => {
  try {
    await pool.execute('ALTER TABLE clients DROP COLUMN company_name');
    console.log("Successfully dropped company_name column");
  } catch(e) {
    console.error(e.message);
  }
  process.exit();
})();
