const pool = require('../config/db');

async function migrate() {
  try {
    console.log('Starting clients schema migration...');

    // 1. Modify status column to include interested, notInterested
    await pool.execute(`
      ALTER TABLE clients 
      MODIFY COLUMN status ENUM('lead', 'followUp', 'interested', 'notInterested', 'converted', 'inactive') DEFAULT 'followUp'
    `);
    console.log('✓ Modified status column enum');

    // Function to check if a column exists
    const [existingCols] = await pool.execute('SHOW COLUMNS FROM clients');
    const colNames = existingCols.map(c => c.Field);

    const colsToAdd = [
      { name: 'preferred_category', def: "VARCHAR(100) DEFAULT 'House Maid' AFTER profile_image_url" },
      { name: 'locality', def: "VARCHAR(100) AFTER preferred_category" },
      { name: 'house_type', def: "VARCHAR(100) DEFAULT 'Apartment' AFTER locality" },
      { name: 'family_size', def: "INT DEFAULT 4 AFTER house_type" },
      { name: 'has_pets', def: "BOOLEAN DEFAULT FALSE AFTER family_size" },
      { name: 'pet_details', def: "VARCHAR(255) AFTER has_pets" },
      { name: 'has_elderly_members', def: "BOOLEAN DEFAULT FALSE AFTER pet_details" },
      { name: 'has_children', def: "BOOLEAN DEFAULT FALSE AFTER has_elderly_members" },
      { name: 'children_count', def: "INT DEFAULT NULL AFTER has_children" },
      { name: 'required_skills', def: "TEXT AFTER children_count" },
      { name: 'budget_range', def: "VARCHAR(100) AFTER required_skills" },
      { name: 'source', def: "VARCHAR(100) DEFAULT 'Direct Entry' AFTER budget_range" },
      { name: 'inquiry_date', def: "TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER source" },
      { name: 'renewal_count', def: "INT DEFAULT 0 AFTER inquiry_date" },
      { name: 'remarks', def: "TEXT AFTER renewal_count" },
    ];

    for (const col of colsToAdd) {
      if (!colNames.includes(col.name)) {
        await pool.execute(`ALTER TABLE clients ADD COLUMN ${col.name} ${col.def}`);
        console.log(`✓ Added column: ${col.name}`);
      } else {
        console.log(`- Column already exists: ${col.name}`);
      }
    }

    // Ensure created_at and updated_at are at the end
    await pool.execute(`
      ALTER TABLE clients 
      MODIFY COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER remarks,
      MODIFY COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at
    `);
    console.log('✓ Ensured created_at and updated_at are the last columns');

    console.log('Migration completed successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
