const pool = require('../config/db');

// @route   GET /api/clients
// @desc    Get all clients (leads and converted)
// @access  Private
const getClients = async (req, res) => {
  try {
    const { status } = req.query;
    let query = 'SELECT * FROM clients';
    const params = [];

    if (status) {
      query += ' WHERE status = ?';
      params.push(status);
    }

    query += ' ORDER BY created_at DESC';

    const [clients] = await pool.execute(query, params);
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
    const { name, company_name, email, phone, address } = req.body;

    if (!name || !phone) {
      return res.status(400).json({ message: 'Name and phone are required' });
    }

    const clientId = `CL_${Date.now().toString().slice(-6)}`;
    const assignedSalesId = req.user.role === 'sales' ? req.user.id : null;

    await pool.execute(
      `INSERT INTO clients 
      (id, name, company_name, email, phone, address, assigned_sales_id) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [clientId, name, company_name || null, email || null, phone, address || null, assignedSalesId]
    );

    res.status(201).json({ message: 'Client created successfully', clientId });
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
    const { name, company_name, email, phone, address, status, loyalty_points } = req.body;

    const [existing] = await pool.execute('SELECT * FROM clients WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Client not found' });
    }

    const client = existing[0];
    const newName = name || client.name;
    const newCompany = company_name !== undefined ? company_name : client.company_name;
    const newEmail = email !== undefined ? email : client.email;
    const newPhone = phone || client.phone;
    const newAddress = address !== undefined ? address : client.address;
    const newStatus = status || client.status;
    const newLoyalty = loyalty_points !== undefined ? loyalty_points : client.loyalty_points;

    let profileImageUrl = client.profile_image_url;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    }

    await pool.execute(
      'UPDATE clients SET name=?, company_name=?, email=?, phone=?, address=?, status=?, loyalty_points=?, profile_image_url=? WHERE id=?',
      [newName, newCompany, newEmail, newPhone, newAddress, newStatus, newLoyalty, profileImageUrl, id]
    );

    res.json({ message: 'Client updated successfully' });
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
