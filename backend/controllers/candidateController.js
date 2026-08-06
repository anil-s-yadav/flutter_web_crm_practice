const pool = require('../config/db');
const { logAction } = require('../services/auditService');
const { isPhoneGloballyUnique } = require('../utils/phoneValidator');
const { generateCandidateId } = require('../utils/idGenerator');

// @route   GET /api/candidates
// @desc    Get all candidates (with optional status filter)
// @access  Private
const getCandidates = async (req, res) => {
  try {
    const { status, search, q, category, page, limit } = req.query;

    let whereClause = ' WHERE 1=1';
    const params = [];

    if (status) {
      whereClause += ' AND c.status = ?';
      params.push(status);
    }
    if (category) {
      whereClause += ' AND c.category = ?';
      params.push(category);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (c.full_name LIKE ? OR c.phone LIKE ? OR c.alternate_phone LIKE ? OR c.id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM candidates c${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT c.*, u.name AS sourced_by_name, u.phone AS sourced_by_phone FROM candidates c LEFT JOIN users u ON c.sourced_by_id = u.id${whereClause} ORDER BY c.created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
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

    const [candidates] = await pool.execute(
      `SELECT c.*, u.name AS sourced_by_name, u.phone AS sourced_by_phone FROM candidates c LEFT JOIN users u ON c.sourced_by_id = u.id${whereClause} ORDER BY c.created_at DESC`,
      params
    );
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
    const [candidates] = await pool.execute(
      'SELECT c.*, u.name AS sourced_by_name, u.phone AS sourced_by_phone FROM candidates c LEFT JOIN users u ON c.sourced_by_id = u.id WHERE c.id = ?',
      [req.params.id]
    );
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
    const fullName = req.body.full_name || req.body.fullName;
    const phone = req.body.phone;
    const altPhone = req.body.alternate_phone || req.body.altPhone;
    const category = req.body.category;
    const expectedSalary = req.body.expected_salary || req.body.expectedSalary;
    const age = req.body.age || null;
    const address = req.body.address || null;
    const city = req.body.city || null;
    const state = req.body.state || null;
    const religion = req.body.religion || null;
    const education = req.body.education || null;
    const experienceYears = req.body.experience_years !== undefined ? req.body.experience_years : (req.body.experienceYears !== undefined ? req.body.experienceYears : null);
    const languages = req.body.languages ? (Array.isArray(req.body.languages) ? req.body.languages.join(',') : req.body.languages) : null;
    const status = req.body.status || 'newlyAdded';
    const isPoliceVerified = req.body.isPoliceVerified || req.body.is_police_verified || false;
    const isMedicalCleared = req.body.isMedicalCleared || req.body.is_medical_cleared || false;
    const source = req.body.source || 'Direct / Walk-in';

    if (!fullName || !phone) {
      return res.status(400).json({ message: 'Name and phone are required' });
    }

    const isUnique = await isPhoneGloballyUnique(phone);
    if (!isUnique) {
      return res.status(409).json({ message: 'Phone number is already registered in the system.' });
    }

    const candidateId = (req.body.id && req.body.id.startsWith('CN'))
      ? req.body.id 
      : await generateCandidateId(pool);
    const profileImageUrl = req.file
      ? `/uploads/${req.file.filename}`
      : (req.body.photoUrl || req.body.profile_image_url || null);
    let sourcedById = null;
    const requestedSourcedId = req.body.sourcedById || req.body.sourced_by_id || (req.user ? req.user.id : null);
    if (requestedSourcedId) {
      const [userRows] = await pool.execute('SELECT id FROM users WHERE id = ?', [requestedSourcedId]);
      if (userRows.length > 0) {
        sourcedById = requestedSourcedId;
      }
    }

    const aadhaarDocUrl = req.body.aadhaar_doc_url || req.body.aadhaarDocUrl || null;
    const panDocUrl = req.body.pan_doc_url || req.body.panDocUrl || null;
    const passportDocUrl = req.body.passport_doc_url || req.body.passportDocUrl || null;
    const policeVerificationDocUrl = req.body.police_verification_doc_url || req.body.policeVerificationDocUrl || null;
    const medicalClearanceDocUrl = req.body.medical_clearance_doc_url || req.body.medicalClearanceDocUrl || null;

    try {
      await pool.execute(
        `INSERT INTO candidates 
        (id, full_name, phone, alternate_phone, category, expected_salary, 
         age, address, city, state, religion, education, experience_years, languages,
         status, is_police_verified, is_medical_cleared,
         aadhaar_doc_url, pan_doc_url, passport_doc_url, police_verification_doc_url, medical_clearance_doc_url,
         sourced_by_id, profile_image_url, source) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [candidateId, fullName, phone, altPhone || null, category || null, expectedSalary || null,
         age, address, city, state, religion, education, experienceYears, languages,
         status, isPoliceVerified ? 1 : 0, isMedicalCleared ? 1 : 0,
         aadhaarDocUrl, panDocUrl, passportDocUrl, policeVerificationDocUrl, medicalClearanceDocUrl,
         sourcedById, profileImageUrl, source]
      );
    } catch (sqlErr) {
      console.warn('Full doc-enabled INSERT failed, trying standard INSERT:', sqlErr.message);
      try {
        await pool.execute(
          `INSERT INTO candidates 
          (id, full_name, phone, alternate_phone, category, expected_salary, 
           age, address, city, state, religion, education, experience_years, languages,
           status, is_police_verified, is_medical_cleared,
           sourced_by_id, profile_image_url, source) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [candidateId, fullName, phone, altPhone || null, category || null, expectedSalary || null,
           age, address, city, state, religion, education, experienceYears, languages,
           status, isPoliceVerified ? 1 : 0, isMedicalCleared ? 1 : 0,
           sourcedById, profileImageUrl, source]
        );
      } catch (fallbackErr) {
        console.warn('Standard INSERT failed, executing fallback core INSERT:', fallbackErr.message);
        await pool.execute(
          `INSERT INTO candidates 
          (id, full_name, phone, alternate_phone, category, expected_salary, sourced_by_id, profile_image_url, source) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [candidateId, fullName, phone, altPhone || null, category || null, expectedSalary || null, sourcedById, profileImageUrl, source]
        );
      }
    }

    res.status(201).json({ message: 'Candidate created successfully', candidateId, id: candidateId });

  } catch (err) {
    console.error('createCandidate error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

const hasDocValue = (val) => {
  return val && typeof val === 'string' && val.trim().length > 0 && val.trim() !== 'null';
};

// @route   PUT /api/candidates/:id/status
// @desc    Update candidate status and verification flags
// @access  Private
const updateCandidateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, is_police_verified, is_medical_cleared, reason } = req.body;

    const [existing] = await pool.execute('SELECT * FROM candidates WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Candidate not found' });
    }
    
    const candidate = existing[0];
    const newStatus = status || candidate.status;
    const police = is_police_verified !== undefined ? is_police_verified : candidate.is_police_verified;
    const medical = is_medical_cleared !== undefined ? is_medical_cleared : candidate.is_medical_cleared;

    // Pipeline Progression Validation:
    if (candidate.status === 'verificationPending' && (newStatus === 'medicalPending' || newStatus === 'readyToPlace')) {
      if (!hasDocValue(candidate.police_verification_doc_url)) {
        return res.status(400).json({ message: 'Police verification certificate must be uploaded before promoting from verification' });
      }
    }

    if (candidate.status === 'medicalPending' && newStatus === 'readyToPlace') {
      if (!hasDocValue(candidate.medical_clearance_doc_url)) {
        return res.status(400).json({ message: 'Medical clearance certificate must be uploaded before promoting to ready to place' });
      }
    }

    await pool.execute(
      'UPDATE candidates SET status = ?, is_police_verified = ?, is_medical_cleared = ? WHERE id = ?',
      [newStatus, police, medical, id]
    );

    res.json({ message: 'Candidate status updated' });
    let logDesc = '';
    if (newStatus === 'newlyAdded' && candidate.status === 'verificationPending') {
      logDesc = 'Candidate rolled back from Verification to Newly Added (Profile unlocked)';
    } else if (newStatus === 'newlyAdded') {
      logDesc = 'Candidate rolled back to Newly Added (Profile unlocked)';
    } else {
      logDesc = `Status updated to ${newStatus}`;
    }
    if (reason) {
      logDesc += ` (Reason: ${reason})`;
    }
    await logAction('candidate', id, 'statusChange', logDesc, req.user?.id || 'system');
  } catch (err) {
    console.error('updateCandidateStatus error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

// @route   PUT /api/candidates/:id
// @desc    Update candidate details
// @access  Private
const updateCandidate = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, reason } = req.body;

    const [existing] = await pool.execute('SELECT * FROM candidates WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Candidate not found' });
    }

    const candidate = existing[0];
    const newName = req.body.full_name || req.body.fullName || candidate.full_name;
    const newPhone = req.body.phone || candidate.phone;
    const newAlternatePhone = req.body.alternate_phone !== undefined ? req.body.alternate_phone : (req.body.altPhone !== undefined ? req.body.altPhone : candidate.alternate_phone);
    const newCategory = req.body.category !== undefined ? req.body.category : candidate.category;
    const newSalary = req.body.expected_salary || req.body.expectedSalary || candidate.expected_salary;
    const newExp = req.body.experience_years !== undefined ? req.body.experience_years : (req.body.experienceYears !== undefined ? req.body.experienceYears : candidate.experience_years);
    const newAge = req.body.age !== undefined ? req.body.age : candidate.age;
    const newAddress = req.body.address !== undefined ? req.body.address : candidate.address;
    const newCity = req.body.city !== undefined ? req.body.city : candidate.city;
    const newState = req.body.state !== undefined ? req.body.state : candidate.state;
    const newReligion = req.body.religion !== undefined ? req.body.religion : candidate.religion;
    const newEducation = req.body.education !== undefined ? req.body.education : candidate.education;
    const newLanguages = req.body.languages ? (Array.isArray(req.body.languages) ? req.body.languages.join(',') : req.body.languages) : candidate.languages;
    const newStatus = req.body.status !== undefined ? req.body.status : candidate.status;
    const newPoliceVerified = req.body.is_police_verified !== undefined ? (req.body.is_police_verified ? 1 : 0) : (req.body.isPoliceVerified !== undefined ? (req.body.isPoliceVerified ? 1 : 0) : candidate.is_police_verified);
    const newMedicalCleared = req.body.is_medical_cleared !== undefined ? (req.body.is_medical_cleared ? 1 : 0) : (req.body.isMedicalCleared !== undefined ? (req.body.isMedicalCleared ? 1 : 0) : candidate.is_medical_cleared);

    const newAadhaarDocUrl = req.body.aadhaar_doc_url !== undefined ? req.body.aadhaar_doc_url : (req.body.aadhaarDocUrl !== undefined ? req.body.aadhaarDocUrl : candidate.aadhaar_doc_url);
    const panDocUrl = req.body.pan_doc_url !== undefined ? req.body.pan_doc_url : (req.body.panDocUrl !== undefined ? req.body.panDocUrl : candidate.pan_doc_url);
    const newPassportDocUrl = req.body.passport_doc_url !== undefined ? req.body.passport_doc_url : (req.body.passportDocUrl !== undefined ? req.body.passportDocUrl : candidate.passport_doc_url);
    const newPoliceDocUrl = req.body.police_verification_doc_url !== undefined ? req.body.police_verification_doc_url : (req.body.policeVerificationDocUrl !== undefined ? req.body.policeVerificationDocUrl : candidate.police_verification_doc_url);
    const newMedicalDocUrl = req.body.medical_clearance_doc_url !== undefined ? req.body.medical_clearance_doc_url : (req.body.medicalClearanceDocUrl !== undefined ? req.body.medicalClearanceDocUrl : candidate.medical_clearance_doc_url);
    const newProfileImageUrl = req.body.photoUrl || req.body.profile_image_url || candidate.profile_image_url;
    const newSource = req.body.source !== undefined ? req.body.source : (candidate.source || 'Direct / Walk-in');

    // Pipeline Progression Validation:
    if (candidate.status === 'verificationPending' && (newStatus === 'medicalPending' || newStatus === 'readyToPlace')) {
      if (!hasDocValue(newPoliceDocUrl)) {
        return res.status(400).json({ message: 'Police verification certificate must be uploaded before promoting from verification' });
      }
    }

    if (candidate.status === 'medicalPending' && newStatus === 'readyToPlace') {
      if (!hasDocValue(newMedicalDocUrl)) {
        return res.status(400).json({ message: 'Medical clearance certificate must be uploaded before promoting to ready to place' });
      }
    }

    if (newPhone && newPhone !== candidate.phone) {
      const isUnique = await isPhoneGloballyUnique(newPhone, id);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }

    await pool.execute(
      `UPDATE candidates SET 
        full_name = ?, phone = ?, alternate_phone = ?, category = ?, expected_salary = ?, 
        age = ?, address = ?, city = ?, state = ?, religion = ?, education = ?, experience_years = ?, languages = ?,
        status = ?, is_police_verified = ?, is_medical_cleared = ?,
        aadhaar_doc_url = ?, pan_doc_url = ?, passport_doc_url = ?, police_verification_doc_url = ?, medical_clearance_doc_url = ?,
        profile_image_url = ?, source = ? 
      WHERE id = ?`,
      [
        newName, newPhone, newAlternatePhone, newCategory, newSalary,
        newAge, newAddress, newCity, newState, newReligion, newEducation, newExp, newLanguages,
        newStatus, newPoliceVerified, newMedicalCleared,
        newAadhaarDocUrl, panDocUrl, newPassportDocUrl, newPoliceDocUrl, newMedicalDocUrl,
        newProfileImageUrl, newSource, id
      ]
    );

    const [updated] = await pool.execute(
      'SELECT c.*, u.name AS sourced_by_name, u.phone AS sourced_by_phone FROM candidates c LEFT JOIN users u ON c.sourced_by_id = u.id WHERE c.id = ?',
      [id]
    );
    res.json(updated[0]);
    
    if (newStatus && newStatus !== candidate.status) {
      let logDesc = '';
      if (newStatus === 'newlyAdded' && candidate.status === 'verificationPending') {
        logDesc = 'Candidate rolled back from Verification to Newly Added (Profile unlocked)';
      } else if (newStatus === 'newlyAdded') {
        logDesc = 'Candidate rolled back to Newly Added (Profile unlocked)';
      } else {
        logDesc = `Status changed to ${newStatus}`;
      }
      if (reason) logDesc += ` (Reason: ${reason})`;
      await logAction('candidate', id, 'statusChange', logDesc, req.user?.id || 'system');
    }
  } catch (err) {
    console.error('updateCandidate error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

module.exports = {
  getCandidates,
  getCandidateById,
  createCandidate,
  updateCandidateStatus,
  updateCandidate
};
