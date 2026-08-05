const pool = require('./config/db');

async function createTables() {
  try {
    const createTicketsTable = `
      CREATE TABLE IF NOT EXISTS tickets (
        id VARCHAR(50) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        priority ENUM('critical', 'urgent', 'standard') DEFAULT 'standard',
        status ENUM('open', 'inProgress', 'resolved', 'closed') DEFAULT 'open',
        client_id VARCHAR(50),
        candidate_id VARCHAR(50),
        contract_id VARCHAR(50),
        assigned_to VARCHAR(50),
        resolved_at TIMESTAMP NULL,
        sla_deadline TIMESTAMP NULL,
        resolution TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL,
        FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE SET NULL,
        FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
      );
    `;

    const createNotificationsTable = `
      CREATE TABLE IF NOT EXISTS notifications (
        id VARCHAR(50) PRIMARY KEY,
        user_id VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT,
        type ENUM('info', 'warning', 'success', 'urgent') DEFAULT 'info',
        is_read BOOLEAN DEFAULT FALSE,
        link_route VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    `;

    console.log('Creating tickets table...');
    await pool.query(createTicketsTable);
    console.log('Tickets table created/verified.');

    console.log('Creating notifications table...');
    await pool.query(createNotificationsTable);
    console.log('Notifications table created/verified.');

  } catch (error) {
    console.error('Error creating tables:', error);
  } finally {
    process.exit();
  }
}

if (require.main === module) {
  createTables();
}

module.exports = createTables;
