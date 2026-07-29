const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { isPhoneGloballyUnique } = require('../utils/phoneValidator');

// @route   GET /api/candidates
// @desc    Get all candidates (with optional status filter)
// @access  Private
const getCandidates = async (req, res) => {
  try {
    const { status, search, q, category, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    if (category) {
      whereClause += ' AND category = ?';
      params.push(category);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (full_name LIKE ? OR phone LIKE ? OR alternate_phone LIKE ? OR id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM candidates${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT * FROM candidates${whereClause} ORDER BY created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
      const [candidates] = await pool.execute(dataSql, params);

      return res.json({
        data: candidates,
        pagination: {
          total: Number(total),
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    }

    const [candidates] = await pool.execute(`SELECT * FROM candidates${whereClause} ORDER BY created_at DESC`, params);
    res.json(candidates);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/candidates/:id
// @desc    Get candidate by ID
// @access  Private
const getCandidateById = async (req, res) => {
  try {
    const [candidates] = await pool.execute('SELECT * FROM candidates WHERE id = ?', [req.params.id]);
    if (candidates.length === 0) {
      return res.status(404).json({ message: 'Candidate not found' });
    }
    res.json(candidates[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/candidates
// @desc    Create a new candidate
// @access  Private (Sourcing/Admin)
const createCandidate = async (req, res) => {
  try {
    const { full_name, phone, alternate_phone, category, expected_salary } = req.body;

    if (!full_name || !phone) {
      return res.status(400).json({ message: 'Name and phone are required' });
    }

    const isUnique = await isPhoneGloballyUnique(phone);
    if (!isUnique) {
      return res.status(409).json({ message: 'Phone number is already registered in the system.' });
    }

    const candidateId = `C_${Date.now().toString().slice(-6)}`;
    const profileImageUrl = req.file ? `/uploads/${req.file.filename}` : null;
    const sourcedById = req.user.id; // From authMiddleware

    await pool.execute(
      `INSERT INTO candidates 
      (id, full_name, phone, alternate_phone, category, expected_salary, sourced_by_id, profile_image_url) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [candidateId, full_name, phone, alternate_phone || null, category || null, expected_salary || null, sourcedById, profileImageUrl]
    );

    res.status(201).json({ message: 'Candidate created successfully', candidateId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/candidates/:id/status
// @desc    Update candidate status and verification flags
// @access  Private
const updateCandidateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, is_police_verified, is_aadhaar_verified, is_medical_cleared, reason } = req.body;

    const [existing] = await pool.execute('SELECT * FROM candidates WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Candidate not found' });
    }
    
    const candidate = existing[0];
    const newStatus = status || candidate.status;
    const police = is_police_verified !== undefined ? is_police_verified : candidate.is_police_verified;
    const aadhaar = is_aadhaar_verified !== undefined ? is_aadhaar_verified : candidate.is_aadhaar_verified;
    const medical = is_medical_cleared !== undefined ? is_medical_cleared : candidate.is_medical_cleared;

    await pool.execute(
      'UPDATE candidates SET status = ?, is_police_verified = ?, is_aadhaar_verified = ?, is_medical_cleared = ? WHERE id = ?',
      [newStatus, police, aadhaar, medical, id]
    );

    res.json({ message: 'Candidate status updated' });
    let logDesc = `Status updated to ${newStatus}`;
    if (reason) {
      logDesc += ` (Reason: ${reason})`;
    }
    await logAction('candidate', id, 'statusChange', logDesc, req.user.id);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/candidates/:id
// @desc    Update candidate details
// @access  Private
const updateCandidate = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, phone, alternate_phone, category, expected_salary, experience_years, age, location, status, reason } = req.body;

    const [existing] = await pool.execute('SELECT * FROM candidates WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Candidate not found' });
    }

    const candidate = existing[0];
    const newName = full_name || candidate.full_name;
    const newPhone = phone || candidate.phone;
    const newAlternatePhone = alternate_phone !== undefined ? alternate_phone : candidate.alternate_phone;
    const newCategory = category !== undefined ? category : candidate.category;
    const newSalary = expected_salary !== undefined ? expected_salary : candidate.expected_salary;
    const newExp = experience_years !== undefined ? experience_years : candidate.experience_years;
    const newAge = age !== undefined ? age : candidate.age;
    const newLoc = location !== undefined ? location : candidate.location;

    if (newPhone && newPhone !== candidate.phone) {
      const isUnique = await isPhoneGloballyUnique(newPhone, id);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }

    await pool.execute(
      'UPDATE candidates SET full_name = ?, phone = ?, alternate_phone = ?, category = ?, expected_salary = ?, experience_years = ?, age = ?, location = ? WHERE id = ?',
      [newName, newPhone, newAlternatePhone, newCategory, newSalary, newExp, newAge, newLoc, id]
    );

    res.json({ message: 'Candidate updated' });
    
    if (status && status !== existing[0].status) {
      let logDesc = `Status changed to ${status}`;
      if (reason) logDesc += ` (Reason: ${reason})`;
      await logAction('candidate', id, 'statusChange', logDesc, req.user.id);
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  getCandidates,
  getCandidateById,
  createCandidate,
  updateCandidateStatus,
  updateCandidate
};
