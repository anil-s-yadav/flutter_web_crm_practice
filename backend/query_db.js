const pool = require('./config/db');

(async () => {
  try {
    const [res1] = await pool.execute("UPDATE candidates SET category = 'House Maid' WHERE category = 'House Candidate'");
    console.log("Updated House Candidate:", res1.affectedRows);
    
    const [res2] = await pool.execute("UPDATE candidates SET category = 'Japa Maid' WHERE category = 'Japa Candidate'");
    console.log("Updated Japa Candidate:", res2.affectedRows);

    process.exit(0);
  } catch(e) {
    console.error(e.message);
    process.exit(1);
  }
})();
