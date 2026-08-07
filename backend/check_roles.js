const pool = require('./config/db');

(async () => {
  try {
    const [rows] = await pool.execute("SELECT id, role FROM users");
    console.log(JSON.stringify(rows, null, 2));
    process.exit(0);
  } catch(e) {
    console.error(e.message);
    process.exit(1);
  }
})();
