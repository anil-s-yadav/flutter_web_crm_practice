const pool = require('../config/db');

// @route   GET /api/candidates
// @desc    Get all candidates (with optional status filter)
// @access  Private
const getCandidates = async (req, res) => {
  try {
    const { status } = req.query;
    let query = 'SELECT * FROM candidates';
    const params = [];

    if (status) {
      query += ' WHERE status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY created_at DESC';

    const [candidates] = await pool.execute(query, params);
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
    const { full_name, phone, category, expected_salary } = req.body;

    if (!full_name || !phone) {
      return res.status(400).json({ message: 'Name and phone are required' });
    }

    const candidateId = `C_${Date.now().toString().slice(-6)}`;
    const profileImageUrl = req.file ? `/uploads/${req.file.filename}` : null;
    const sourcedById = req.user.id; // From authMiddleware

    await pool.execute(
      `INSERT INTO candidates 
      (id, full_name, phone, category, expected_salary, sourced_by_id, profile_image_url) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [candidateId, full_name, phone, category || null, expected_salary || null, sourcedById, profileImageUrl]
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
    const { status, is_police_verified, is_aadhaar_verified, is_medical_cleared } = req.body;

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
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getCandidates,
  getCandidateById,
  createCandidate,
  updateCandidateStatus
};
