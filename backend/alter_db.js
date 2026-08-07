const pool = require('./config/db');

(async () => {
  try {
    const query = "ALTER TABLE candidates MODIFY COLUMN status ENUM('newlyAdded', 'verificationPending', 'medicalPending', 'readyToPlace', 'pendingDrop', 'placed', 'blacklisted') DEFAULT 'newlyAdded';";
    const [res1] = await pool.execute(query);
    console.log("Successfully altered candidates table status ENUM");
    
    // Also we need to fix database_setup.sql so future resets include pendingDrop!
    process.exit(0);
  } catch(e) {
    console.error(e.message);
    process.exit(1);
  }
})();
