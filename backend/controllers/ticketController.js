const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { generateTicketId, generateInternalId } = require('../utils/idGenerator');

// @desc    Create a new ticket
// @route   POST /api/tickets
// @access  Private
const createTicket = async (req, res) => {
  try {
    const { id, title, description, priority, status, clientId, candidateId, contractId, assignedTo } = req.body;
    
    // Generate TCK-1, TCK-2, ...
    const ticketId = (id && id.startsWith('TCK-'))
      ? id 
      : await generateTicketId(pool);
    const tPriority = priority || 'standard';
    const tStatus = status || 'open';

    const query = `
      INSERT INTO tickets 
        (id, title, description, priority, status, client_id, candidate_id, contract_id, assigned_to)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    await pool.query(query, [
      ticketId, 
      title, 
      description, 
      tPriority, 
      tStatus, 
      clientId || null, 
      candidateId || null, 
      contractId || null, 
      assignedTo || null
    ]);

    // Send notification to the assigned user
    if (assignedTo) {
      const notifId = await generateInternalId(pool, 'notifications');
      const notifQuery = `
        INSERT INTO notifications (id, user_id, title, message, type, link_route)
        VALUES (?, ?, ?, ?, ?, ?)
      `;
      await pool.query(notifQuery, [
        notifId,
        assignedTo,
        'New Ticket Assigned',
        `You have been assigned a new ticket: ${title}`,
        'info',
        `/tickets/${ticketId}`
      ]);
    }

    res.status(201).json({ message: 'Ticket created successfully', id: ticketId, ticketId });

  } catch (error) {
    console.error('Error creating ticket:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get all tickets with pagination and filtering
// @route   GET /api/tickets
// @access  Private
const getTickets = async (req, res) => {
  try {
    const { page, limit, q, status, priority, clientId, assignedTo } = req.query;

    let query = `
      SELECT t.*, 
        c.name as clientName, 
        cand.full_name as candidateName
      FROM tickets t
      LEFT JOIN clients c ON t.client_id = c.id
      LEFT JOIN candidates cand ON t.candidate_id = cand.id
      WHERE 1=1
    `;
    const queryParams = [];

    if (q) {
      query += ` AND (t.id LIKE ? OR t.title LIKE ? OR t.description LIKE ?)`;
      queryParams.push(`%${q}%`, `%${q}%`, `%${q}%`);
    }
    if (status) {
      query += ` AND t.status = ?`;
      queryParams.push(status);
    }
    if (priority) {
      query += ` AND t.priority = ?`;
      queryParams.push(priority);
    }
    if (clientId) {
      query += ` AND t.client_id = ?`;
      queryParams.push(clientId);
    }
    if (assignedTo) {
      query += ` AND t.assigned_to = ?`;
      queryParams.push(assignedTo);
    }

    query += ` ORDER BY t.created_at DESC`;

    // Execute full query if no pagination
    if (!page || !limit) {
      const [rows] = await pool.query(query, queryParams);
      return res.json(rows);
    }

    // With Pagination
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    // Count Total
    const countQuery = `SELECT COUNT(*) as total FROM (${query}) as sub`;
    const [countResult] = await pool.query(countQuery, queryParams);
    const total = countResult[0].total;

    // Fetch Page
    const pagedQuery = `${query} LIMIT ? OFFSET ?`;
    queryParams.push(limitNum, offset);
    const [rows] = await pool.query(pagedQuery, queryParams);

    res.json({
      data: rows,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum)
      }
    });

  } catch (error) {
    console.error('Error fetching tickets:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get single ticket by ID
// @route   GET /api/tickets/:id
// @access  Private
const getTicketById = async (req, res) => {
  try {
    const { id } = req.params;
    const query = `
      SELECT t.*, 
        c.name as clientName, 
        cand.full_name as candidateName
      FROM tickets t
      LEFT JOIN clients c ON t.client_id = c.id
      LEFT JOIN candidates cand ON t.candidate_id = cand.id
      WHERE t.id = ?
    `;
    const [rows] = await pool.query(query, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Ticket not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching ticket by ID:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Update a ticket
// @route   PUT /api/tickets/:id
// @access  Private
const updateTicket = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, resolution, assignedTo } = req.body;

    const [existing] = await pool.query(`SELECT * FROM tickets WHERE id = ?`, [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Ticket not found' });
    }

    let query = `UPDATE tickets SET `;
    const updates = [];
    const values = [];

    if (status) {
      updates.push(`status = ?`);
      values.push(status);
      if (status === 'resolved' || status === 'closed') {
        updates.push(`resolved_at = CURRENT_TIMESTAMP`);
      }
    }
    if (resolution !== undefined) {
      updates.push(`resolution = ?`);
      values.push(resolution);
    }
    if (assignedTo !== undefined) {
      updates.push(`assigned_to = ?`);
      values.push(assignedTo);
    }

    if (updates.length === 0) {
      return res.json({ message: 'No changes provided' });
    }

    query += updates.join(', ') + ` WHERE id = ?`;
    values.push(id);

    await pool.query(query, values);

    // Send notification if assignedTo changed
    if (assignedTo && existing[0].assigned_to !== assignedTo) {
      const notifId = `N${Date.now()}`;
      const notifQuery = `
        INSERT INTO notifications (id, user_id, title, message, type, link_route)
        VALUES (?, ?, ?, ?, ?, ?)
      `;
      await pool.query(notifQuery, [
        notifId,
        assignedTo,
        'Ticket Assigned to You',
        `Ticket ${existing[0].title} has been assigned to you.`,
        'info',
        `/tickets/${id}`
      ]);
    }

    res.json({ message: 'Ticket updated successfully' });
    
    // Create a meaningful description based on what changed
    let updateDesc = 'Updated ticket details';
    if (status && status !== existing[0].status) {
      updateDesc = `Status changed to ${status}`;
    } else if (resolution !== undefined && resolution !== existing[0].resolution) {
      updateDesc = 'Added/Updated resolution notes';
    } else if (assignedTo && assignedTo !== existing[0].assigned_to) {
      updateDesc = `Reassigned ticket`;
    }
    
    await logAction('ticket', id, 'update', updateDesc, req.user.id);
  } catch (error) {
    console.error('Error updating ticket:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Delete a ticket
// @route   DELETE /api/tickets/:id
// @access  Private
const deleteTicket = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM tickets WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Ticket not found' });
    }
    
    res.json({ message: 'Ticket deleted successfully' });
  } catch (error) {
    console.error('Error deleting ticket:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  createTicket,
  getTickets,
  getTicketById,
  updateTicket,
  deleteTicket
};
