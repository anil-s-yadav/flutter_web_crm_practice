const pool = require('../config/db');

async function testWorkflow() {
  try {
    console.log('Testing client workflow backend...');
    const testId = 'TEST_CLI_' + Date.now();
    const testPhone = '9' + Math.floor(100000000 + Math.random() * 900000000);

    // 1. Insert test client
    await pool.execute(
      `INSERT INTO clients 
      (id, name, phone, email, address, city, status, preferred_category, budget_range, remarks) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [testId, 'Test Workflow Client', testPhone, 'test@workflow.com', '101 Test Road', 'Mumbai', 'followUp', 'House Maid', '₹15,000 - ₹25,000', '[06 Aug 2026, 12:00] Initial inquiry received']
    );
    console.log('✓ Created test client with followUp status and initial remark');

    // 2. Add call note / update remark
    const updatedRemark = '[06 Aug 2026, 12:00] Initial inquiry received\n\n[06 Aug 2026, 12:15] Sales: Called client. Client requested to call back in 3 days after discussion with spouse.';
    await pool.execute(
      'UPDATE clients SET remarks = ? WHERE id = ?',
      [updatedRemark, testId]
    );
    console.log('✓ Updated remarks with call log');

    // 3. Move to interested
    const interestedRemark = updatedRemark + '\n\n[06 Aug 2026, 12:30] Status changed to Interested: Client liked maid profiles, searching for matching staff.';
    await pool.execute(
      'UPDATE clients SET status = ?, remarks = ? WHERE id = ?',
      ['interested', interestedRemark, testId]
    );
    console.log('✓ Moved client to interested status');

    // 4. Move to notInterested with mandatory note
    const notInterestedRemark = interestedRemark + '\n\n[06 Aug 2026, 12:45] Status changed to Not Interested: Client hired relative maid.';
    await pool.execute(
      'UPDATE clients SET status = ?, remarks = ? WHERE id = ?',
      ['notInterested', notInterestedRemark, testId]
    );
    console.log('✓ Moved client to notInterested status with mandatory note');

    // 5. Query and verify final row
    const [rows] = await pool.execute('SELECT * FROM clients WHERE id = ?', [testId]);
    console.log('Final client record:');
    console.log({
      id: rows[0].id,
      name: rows[0].name,
      status: rows[0].status,
      preferred_category: rows[0].preferred_category,
      remarks: rows[0].remarks
    });

    // Cleanup test record
    await pool.execute('DELETE FROM clients WHERE id = ?', [testId]);
    console.log('✓ Cleaned up test record');
    console.log('ALL BACKEND WORKFLOW TESTS PASSED!');
    process.exit(0);
  } catch (err) {
    console.error('Test failed:', err);
    process.exit(1);
  }
}

testWorkflow();
