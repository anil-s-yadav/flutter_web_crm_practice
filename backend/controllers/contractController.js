const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { generateContractId } = require('../utils/idGenerator');

// @route   GET /api/contracts
// @desc    Get all contracts
// @access  Private
const getContracts = async (req, res) => {
  try {
    const { status, client_id, candidate_id, search, q, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    // Role-based scoping: Sales reps only see contracts for their assigned clients or created by them
    if (req.user && req.user.role === 'sales') {
      whereClause += ' AND (c.created_by = ? OR c.client_id IN (SELECT id FROM clients WHERE assigned_sales_id = ?))';
      params.push(req.user.id, req.user.id);
    }

    if (status) {
      whereClause += ' AND c.status = ?';
      params.push(status);
    }
    if (client_id) {
      whereClause += ' AND c.client_id = ?';
      params.push(client_id);
    }
    if (candidate_id) {
      whereClause += ' AND c.candidate_id = ?';
      params.push(candidate_id);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (c.id LIKE ? OR c.client_id LIKE ? OR c.candidate_id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM contracts c${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT c.*, cl.name as client_name, cd.full_name as candidate_name FROM contracts c LEFT JOIN clients cl ON c.client_id = cl.id LEFT JOIN candidates cd ON c.candidate_id = cd.id${whereClause} ORDER BY c.created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [contracts] = await pool.execute(dataSql, params);

      return res.json({
        data: contracts,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [contracts] = await pool.execute(`SELECT c.*, cl.name as client_name, cd.full_name as candidate_name FROM contracts c LEFT JOIN clients cl ON c.client_id = cl.id LEFT JOIN candidates cd ON c.candidate_id = cd.id${whereClause} ORDER BY c.created_at DESC`, params);
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

    let createdBy = null;
    const requestedUserId = req.user ? req.user.id : null;
    if (requestedUserId) {
      const [userRows] = await pool.execute('SELECT id FROM users WHERE id = ?', [requestedUserId]);
      if (userRows.length > 0) {
        createdBy = requestedUserId;
      }
    }

    // We should use a transaction to ensure atomic updates
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const contractId = (req.body.id && req.body.id.startsWith('CNT'))
        ? req.body.id
        : await generateContractId(connection);

      const amountPaid = req.body.amount_paid !== undefined ? req.body.amount_paid : (req.body.amountPaid || 0);
      const contractStatus = req.body.status || req.body.contractStatus || 'active';

      // 1. Insert contract
      await connection.execute(
        `INSERT INTO contracts 
        (id, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, amount_paid, status, created_by) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [contractId, client_id, candidate_id, start_date, guarantee_end_date, contract_end_date, total_fee, amountPaid, contractStatus, createdBy]
      );

      // 2. Update client status to converted
      await connection.execute(
        `UPDATE clients SET status = 'converted' WHERE id = ?`,
        [client_id]
      );

      // 3. Update candidate status to pendingDrop
      await connection.execute(
        `UPDATE candidates SET status = 'pendingDrop' WHERE id = ?`,
        [candidate_id]
      );

      await connection.commit();
      connection.release();

      res.status(201).json({ message: 'Contract created successfully', contractId, id: contractId });
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

// @route   PUT /api/contracts/:id
// @desc    Update full contract details (amount_paid, status, etc.)
// @access  Private
const updateContract = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      amount_paid,
      amountPaid,
      status,
      contractStatus,
      total_fee,
      serviceFee
    } = req.body;

    const paid = amount_paid !== undefined ? amount_paid : (amountPaid !== undefined ? amountPaid : null);
    const stat = status || contractStatus || null;
    const fee = total_fee !== undefined ? total_fee : (serviceFee !== undefined ? serviceFee : null);

    const updates = [];
    const params = [];

    if (paid !== null) {
      updates.push('amount_paid = ?');
      params.push(paid);
    }
    if (stat !== null) {
      updates.push('status = ?');
      params.push(stat);
    }
    if (fee !== null) {
      updates.push('total_fee = ?');
      params.push(fee);
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No valid update fields provided' });
    }

    params.push(id);
    await pool.execute(
      `UPDATE contracts SET ${updates.join(', ')} WHERE id = ?`,
      params
    );

    const [rows] = await pool.execute(
      `SELECT c.*, cl.name as client_name, cd.full_name as candidate_name 
       FROM contracts c 
       LEFT JOIN clients cl ON c.client_id = cl.id 
       LEFT JOIN candidates cd ON c.candidate_id = cd.id 
       WHERE c.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Contract not found' });
    }

    if (req.user && req.user.id) {
      await logAction('contract', id, 'updated', `Contract ${id} updated (paid: ${paid}, status: ${stat})`, req.user.id);
    }

    res.json(rows[0]);
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
    await logAction('contract', id, 'paymentLogged', `Logged payment of ${amount}`, req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getContracts,
  createContract,
  updateContract,
  recordPayment
};
