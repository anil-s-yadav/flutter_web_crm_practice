const pool = require('../config/db');

// @route   GET /api/contracts
// @desc    Get all contracts
// @access  Private
const getContracts = async (req, res) => {
  try {
    const [contracts] = await pool.execute('SELECT * FROM contracts ORDER BY created_at DESC');
    res.json(contracts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/contracts
// @desc    Create a new contract
// @access  Private (Sales/Admin)
const createContract = async (req, res) => {
  try {
    const { client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee } = req.body;

    if (!client_id || !candidate_id || !start_date || !total_fee) {
      return res.status(400).json({ message: 'Missing required contract fields' });
    }

    const contractId = `CON_${Date.now().toString().slice(-6)}`;
    const createdBy = req.user.id;

    // We should use a transaction to ensure atomic updates
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 1. Insert contract
      await connection.execute(
        `INSERT INTO contracts 
        (id, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, created_by) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [contractId, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, createdBy]
      );

      // 2. Update client status to converted
      await connection.execute(
        `UPDATE clients SET status = 'converted' WHERE id = ?`,
        [client_id]
      );

      // 3. Update candidate status to placed
      await connection.execute(
        `UPDATE candidates SET status = 'placed' WHERE id = ?`,
        [candidate_id]
      );

      await connection.commit();
      connection.release();

      res.status(201).json({ message: 'Contract created successfully', contractId });
    } catch (dbErr) {
      await connection.rollback();
      connection.release();
      throw dbErr;
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/contracts/:id/payment
// @desc    Update contract payment amount
// @access  Private
const recordPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { amount } = req.body;

    if (!amount) return res.status(400).json({ message: 'Amount is required' });

    await pool.execute(
      'UPDATE contracts SET amount_paid = amount_paid + ? WHERE id = ?',
      [amount, id]
    );

    res.json({ message: 'Payment recorded successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getContracts,
  createContract,
  recordPayment
};
