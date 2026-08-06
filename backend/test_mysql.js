const pool = require('./config/db');
(async () => {
  try {
    const candidateId = "VM001test";
    const languages = ["Hindi", "English"];
    await pool.execute(
      `INSERT INTO candidates (id, full_name, phone, languages) VALUES (?, ?, ?, ?)`,
      [candidateId, 'Test', '9999999999', languages]
    );
    console.log("Success");
  } catch (e) {
    console.log("Error:", e.message);
  }
  process.exit();
})();
