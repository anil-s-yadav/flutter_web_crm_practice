const pool = require('../config/db');

async function migrate() {
  try {
    // Check if aadhaar_number already exists
    const [cols] = await pool.execute("SHOW COLUMNS FROM candidates LIKE 'aadhaar_number'");
    if (cols.length === 0) {
      await pool.execute(`
        ALTER TABLE candidates 
        ADD COLUMN aadhaar_number VARCHAR(20) DEFAULT NULL AFTER alternate_phone
      `);
      console.log('Added aadhaar_number column');
    }

    // Populate existing candidates with unique Aadhaar numbers if null
    const [candidates] = await pool.execute("SELECT id FROM candidates WHERE aadhaar_number IS NULL OR aadhaar_number = '' ORDER BY id ASC");
    let seedNum = 543210980000;
    for (const c of candidates) {
      seedNum++;
      const formatted = String(seedNum);
      await pool.execute('UPDATE candidates SET aadhaar_number = ? WHERE id = ?', [formatted, c.id]);
    }
    console.log(`Populated ${candidates.length} candidates with initial Aadhaar numbers`);

    // Ensure UNIQUE index exists
    const [indexes] = await pool.execute("SHOW INDEX FROM candidates WHERE Key_name = 'aadhaar_number'");
    if (indexes.length === 0) {
      await pool.execute('ALTER TABLE candidates ADD UNIQUE INDEX (aadhaar_number)');
      console.log('Added UNIQUE index on aadhaar_number');
    }

    console.log('Aadhaar migration completed successfully');
  } catch (err) {
    console.error('Migration error:', err);
  } finally {
    process.exit(0);
  }
}

migrate();
