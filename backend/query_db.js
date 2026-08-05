const pool = require('./config/db');

(async () => {
  try {
    const [rows] = await pool.execute("SELECT COUNT(*) as count FROM candidates WHERE status = 'readyToPlace' AND is_medical_cleared = 1 AND sourced_by_id = 'VMU0003'");
    console.log("With 1:", JSON.stringify(rows, null, 2));

    const [rows2] = await pool.execute("SELECT COUNT(*) as count FROM candidates WHERE status = 'readyToPlace' AND is_medical_cleared = TRUE AND sourced_by_id = 'VMU0003'");
    console.log("With TRUE:", JSON.stringify(rows2, null, 2));
    process.exit(0);
  } catch(e) {
    console.error(e.message);
    process.exit(1);
  }
})();
