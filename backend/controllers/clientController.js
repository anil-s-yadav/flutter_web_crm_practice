const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { isPhoneGloballyUnique } = require('../utils/phoneValidator');
const { generateClientId } = require('../utils/idGenerator');

// @route   GET /api/clients
// @desc    Get all clients (leads and converted)
// @access  Private
const getClients = async (req, res) => {
  try {
    const { status, search, q, city, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    if (city) {
      whereClause += ' AND city = ?';
      params.push(city);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (name LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR email LIKE ? OR id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM clients${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT * FROM clients${whereClause} ORDER BY created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [clients] = await pool.execute(dataSql, params);

      return res.json({
        data: clients,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [clients] = await pool.execute(`SELECT * FROM clients${whereClause} ORDER BY created_at DESC`, params);
    res.json(clients);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/clients
// @desc    Create a new client (lead)
// @access  Private (Sales/Admin)
const createClient = async (req, res) => {
  try {
    const { name, company_name, email, phone, alternate_phone, address } = req.body;

    if (!name || !phone) {
      return res.status(400).json({ message: 'Name and phone are required' });
    }

    const isUnique = await isPhoneGloballyUnique(phone);
    if (!isUnique) {
      return res.status(409).json({ message: 'Phone number is already registered in the system.' });
    }

    const clientId = (req.body.id && req.body.id.startsWith('VM'))
      ? req.body.id 
      : await generateClientId(pool);
    let assignedSalesId = null;
    const requestedSalesId = (req.user && req.user.role === 'sales') ? req.user.id : (req.body.assigned_sales_id || null);
    if (requestedSalesId) {
      const [userRows] = await pool.execute('SELECT id FROM users WHERE id = ?', [requestedSalesId]);
      if (userRows.length > 0) {
        assignedSalesId = requestedSalesId;
      }
    }

    await pool.execute(
      `INSERT INTO clients 
      (id, name, company_name, email, phone, alternate_phone, address, assigned_sales_id) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [clientId, name, company_name || null, email || null, phone, alternate_phone || null, address || null, assignedSalesId]
    );

    res.status(201).json({ message: 'Client created successfully', clientId, id: clientId });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/clients/:id
// @desc    Update client details (including image upload for converted clients)
// @access  Private
const updateClient = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, company_name, email, phone, alternate_phone, address, status, loyalty_points, reason } = req.body;

    const [existing] = await pool.execute('SELECT * FROM clients WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Client not found' });
    }

    const client = existing[0];
    const newName = name || client.name;
    const newCompany = company_name !== undefined ? company_name : client.company_name;
    const newEmail = email !== undefined ? email : client.email;
    const newPhone = phone || client.phone;
    const newAlternatePhone = alternate_phone !== undefined ? alternate_phone : client.alternate_phone;
    const newAddress = address !== undefined ? address : client.address;

    if (newPhone && newPhone !== client.phone) {
      const isUnique = await isPhoneGloballyUnique(newPhone, id);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }
    const newStatus = status || client.status;
    const newLoyalty = loyalty_points !== undefined ? loyalty_points : client.loyalty_points;

    let profileImageUrl = client.profile_image_url;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    }

    await pool.execute(
      'UPDATE clients SET name=?, company_name=?, email=?, phone=?, alternate_phone=?, address=?, status=?, loyalty_points=?, profile_image_url=? WHERE id=?',
      [newName, newCompany, newEmail, newPhone, newAlternatePhone, newAddress, newStatus, newLoyalty, profileImageUrl, id]
    );

    res.json({ message: 'Client updated successfully' });
    
    if (status && status !== client.status) {
      let logDesc = `Status changed to ${status}`;
      if (reason) logDesc += ` (Reason: ${reason})`;
      await logAction('client', id, 'statusChange', logDesc, req.user.id);
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getClients,
  createClient,
  updateClient
};
