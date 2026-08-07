const pool = require('./config/db');

(async () => {
  try {
    const query = "ALTER TABLE contracts MODIFY COLUMN status ENUM('pending', 'active', 'expired', 'rePlaced', 'terminated') DEFAULT 'pending';";
    const [res1] = await pool.execute(query);
    console.log("Successfully altered contracts table status ENUM");
    process.exit(0);
  } catch(e) {
    console.error(e.message);
    process.exit(1);
  }
})();
