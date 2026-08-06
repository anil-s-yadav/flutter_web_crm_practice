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
      whereClause += ' AND c.status = ?';
      params.push(status);
    }
    if (city) {
      whereClause += ' AND c.city = ?';
      params.push(city);
    }
    const searchTerm = search || q;
    if (searchTerm) {
      whereClause += ' AND (c.name LIKE ? OR c.phone LIKE ? OR c.alternate_phone LIKE ? OR c.email LIKE ? OR c.id LIKE ?)';
      const s = `%${searchTerm.trim()}%`;
      params.push(s, s, s, s, s);
    }

    if (page || limit) {
      const pageNum = parseInt(page, 10) || 1;
      const limitNum = parseInt(limit, 10) || 20;
      const offset = (pageNum - 1) * limitNum;

      const countSql = `SELECT COUNT(*) as total FROM clients c${whereClause}`;
      const [[{ total }]] = await pool.execute(countSql, params);

      const dataSql = `SELECT c.*, u.name AS assigned_sales_name FROM clients c LEFT JOIN users u ON c.assigned_sales_id = u.id${whereClause} ORDER BY c.created_at DESC LIMIT ${limitNum} OFFSET ${offset}`;
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

    const [clients] = await pool.execute(
      `SELECT c.*, u.name AS assigned_sales_name FROM clients c LEFT JOIN users u ON c.assigned_sales_id = u.id${whereClause} ORDER BY c.created_at DESC`,
      params
    );
    res.json(clients);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/clients
// @desc    Create a new client (lead / followUp)
// @access  Private (Sales/Admin)
const createClient = async (req, res) => {
  try {
    const name = req.body.name || req.body.fullName || req.body.full_name;
    const phone = req.body.phone;
    const email = req.body.email || null;
    const alternatePhone = req.body.alternate_phone || req.body.altPhone || null;
    const address = req.body.address || null;
    const city = req.body.city || null;
    const state = req.body.state || null;
    const status = req.body.status || 'followUp';

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
    const requestedSalesId = (req.user && req.user.role === 'sales') ? req.user.id : (req.body.assigned_sales_id || req.body.assignedEmployeeId || null);
    if (requestedSalesId) {
      const [userRows] = await pool.execute('SELECT id FROM users WHERE id = ?', [requestedSalesId]);
      if (userRows.length > 0) {
        assignedSalesId = requestedSalesId;
      }
    }

    const preferredCategory = req.body.preferred_category || req.body.preferredCandidateCategory || 'House Maid';
    const locality = req.body.locality || null;
    const houseType = req.body.house_type || req.body.houseType || 'Apartment';
    const familySize = req.body.family_size !== undefined ? req.body.family_size : (req.body.familySize !== undefined ? req.body.familySize : 4);
    const hasPets = req.body.has_pets !== undefined ? req.body.has_pets : (req.body.hasPets !== undefined ? req.body.hasPets : false);
    const petDetails = req.body.pet_details || req.body.petDetails || null;
    const hasElderlyMembers = req.body.has_elderly_members !== undefined ? req.body.has_elderly_members : (req.body.hasElderlyMembers !== undefined ? req.body.hasElderlyMembers : false);
    const hasChildren = req.body.has_children !== undefined ? req.body.has_children : (req.body.hasChildren !== undefined ? req.body.hasChildren : false);
    const childrenCount = req.body.children_count !== undefined ? req.body.children_count : (req.body.childrenCount !== undefined ? req.body.childrenCount : null);
    const requiredSkills = Array.isArray(req.body.requiredSkills) ? req.body.requiredSkills.join(', ') : (req.body.required_skills || null);
    const budgetRange = req.body.budget_range || req.body.budgetRange || null;
    const source = req.body.source || 'Direct / Walk-in';
    const remarks = req.body.remarks || req.body.notes || null;

    const serviceType = req.body.service_type || req.body.serviceType || '24 Hours Live-in';
    const workTimings = req.body.work_timings || req.body.workTimings || '24 Hours';
    const foodPreference = req.body.food_preference || req.body.foodPreference || 'Any / No Preference';
    const genderPreference = req.body.gender_preference || req.body.genderPreference || 'Female';
    const preferredLanguages = Array.isArray(req.body.preferred_languages || req.body.preferredLanguages)
      ? (req.body.preferred_languages || req.body.preferredLanguages).join(', ')
      : (req.body.preferred_languages || req.body.preferredLanguages || 'Hindi');
    const religionPreference = req.body.religion_preference || req.body.religionPreference || 'Any / No Preference';
    const expectedJoining = req.body.expected_joining || req.body.expectedJoining || 'Immediate (Within 1-2 Days)';

    await pool.execute(
      `INSERT INTO clients 
      (id, name, email, phone, alternate_phone, address, city, state, status, assigned_sales_id, 
       preferred_category, locality, house_type, family_size, has_pets, pet_details, 
       has_elderly_members, has_children, children_count, required_skills, budget_range, source, remarks,
       service_type, work_timings, food_preference, gender_preference, preferred_languages, religion_preference, expected_joining) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        clientId, name, email, phone, alternatePhone, address, city, state, status, assignedSalesId,
        preferredCategory, locality, houseType, familySize, hasPets ? 1 : 0, petDetails,
        hasElderlyMembers ? 1 : 0, hasChildren ? 1 : 0, childrenCount, requiredSkills, budgetRange, source, remarks,
        serviceType, workTimings, foodPreference, genderPreference, preferredLanguages, religionPreference, expectedJoining
      ]
    );

    if (remarks) {
      await logAction('client', clientId, 'noteAdded', `Initial note: ${remarks}`, req.user ? req.user.id : null);
    }

    res.status(201).json({ 
      message: 'Client created successfully', 
      clientId, 
      id: clientId,
      name,
      phone,
      status
    });

  } catch (err) {
    console.error('Error in createClient:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

// @route   PUT /api/clients/:id
// @desc    Update client details (including image upload, notes, status transitions)
// @access  Private
const updateClient = async (req, res) => {
  try {
    const { id } = req.params;
    const name = req.body.name || req.body.fullName || req.body.full_name;
    const { 
      email, phone, alternate_phone, altPhone, address, city, state, status, 
      loyalty_points, reason, remarks, notes,
      preferred_category, preferredCandidateCategory,
      locality, house_type, houseType,
      family_size, familySize,
      has_pets, hasPets,
      pet_details, petDetails,
      has_elderly_members, hasElderlyMembers,
      has_children, hasChildren,
      children_count, childrenCount,
      required_skills, requiredSkills,
      budget_range, budgetRange,
      source,
      service_type, serviceType,
      work_timings, workTimings,
      food_preference, foodPreference,
      gender_preference, genderPreference,
      preferred_languages, preferredLanguages,
      religion_preference, religionPreference,
      expected_joining, expectedJoining
    } = req.body;

    const [existing] = await pool.execute('SELECT * FROM clients WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Client not found' });
    }

    const client = existing[0];
    const newName = name || client.name;
    const newEmail = email !== undefined ? email : client.email;
    const newPhone = phone || client.phone;
    const newAlternatePhone = (alternate_phone !== undefined || altPhone !== undefined) 
      ? (alternate_phone || altPhone) 
      : client.alternate_phone;
    const newAddress = address !== undefined ? address : client.address;
    const newCity = city !== undefined ? city : client.city;
    const newState = state !== undefined ? state : client.state;

    if (newPhone && newPhone !== client.phone) {
      const isUnique = await isPhoneGloballyUnique(newPhone, id);
      if (!isUnique) {
        return res.status(409).json({ message: 'Phone number is already registered in the system.' });
      }
    }
    const newStatus = status || client.status;
    const newLoyalty = loyalty_points !== undefined ? loyalty_points : client.loyalty_points;
    const newCategory = (preferred_category || preferredCandidateCategory) || client.preferred_category;
    const newLocality = locality !== undefined ? locality : client.locality;
    const newHouseType = (house_type || houseType) || client.house_type;
    const newFamilySize = (family_size !== undefined ? family_size : familySize) !== undefined 
      ? (family_size !== undefined ? family_size : familySize) 
      : client.family_size;
    const newHasPets = (has_pets !== undefined ? has_pets : hasPets) !== undefined 
      ? (has_pets !== undefined ? has_pets : hasPets) 
      : client.has_pets;
    const newPetDetails = (pet_details !== undefined || petDetails !== undefined) 
      ? (pet_details || petDetails) 
      : client.pet_details;
    const newHasElderly = (has_elderly_members !== undefined ? has_elderly_members : hasElderlyMembers) !== undefined 
      ? (has_elderly_members !== undefined ? has_elderly_members : hasElderlyMembers) 
      : client.has_elderly_members;
    const newHasChildren = (has_children !== undefined ? has_children : hasChildren) !== undefined 
      ? (has_children !== undefined ? has_children : hasChildren) 
      : client.has_children;
    const newChildrenCount = (children_count !== undefined ? children_count : childrenCount) !== undefined 
      ? (children_count !== undefined ? children_count : childrenCount) 
      : client.children_count;
    const newRequiredSkills = required_skills !== undefined 
      ? required_skills 
      : (Array.isArray(requiredSkills) ? requiredSkills.join(', ') : client.required_skills);
    const newBudget = (budget_range || budgetRange) || client.budget_range;
    const newSource = source || client.source;
    const newRemarks = (remarks !== undefined || notes !== undefined) 
      ? (remarks || notes) 
      : client.remarks;

    const newServiceType = (service_type || serviceType) !== undefined ? (service_type || serviceType) : client.service_type;
    const newWorkTimings = (work_timings || workTimings) !== undefined ? (work_timings || workTimings) : client.work_timings;
    const newFoodPreference = (food_preference || foodPreference) !== undefined ? (food_preference || foodPreference) : client.food_preference;
    const newGenderPreference = (gender_preference || genderPreference) !== undefined ? (gender_preference || genderPreference) : client.gender_preference;
    const rawLanguages = (preferred_languages !== undefined || preferredLanguages !== undefined) ? (preferred_languages || preferredLanguages) : client.preferred_languages;
    const newPreferredLanguages = Array.isArray(rawLanguages) ? rawLanguages.join(', ') : rawLanguages;
    const newReligionPreference = (religion_preference || religionPreference) !== undefined ? (religion_preference || religionPreference) : client.religion_preference;
    const newExpectedJoining = (expected_joining || expectedJoining) !== undefined ? (expected_joining || expectedJoining) : client.expected_joining;

    let profileImageUrl = client.profile_image_url;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    }

    await pool.execute(
      `UPDATE clients SET 
        name=?, email=?, phone=?, alternate_phone=?, address=?, city=?, state=?, 
        status=?, loyalty_points=?, profile_image_url=?, preferred_category=?, 
        locality=?, house_type=?, family_size=?, has_pets=?, pet_details=?, 
        has_elderly_members=?, has_children=?, children_count=?, required_skills=?, 
        budget_range=?, source=?, remarks=?,
        service_type=?, work_timings=?, food_preference=?, gender_preference=?, 
        preferred_languages=?, religion_preference=?, expected_joining=?
       WHERE id=?`,
      [
        newName, newEmail, newPhone, newAlternatePhone, newAddress, newCity, newState,
        newStatus, newLoyalty, profileImageUrl, newCategory,
        newLocality, newHouseType, newFamilySize, newHasPets ? 1 : 0, newPetDetails,
        newHasElderly ? 1 : 0, newHasChildren ? 1 : 0, newChildrenCount, newRequiredSkills,
        newBudget, newSource, newRemarks,
        newServiceType, newWorkTimings, newFoodPreference, newGenderPreference,
        newPreferredLanguages, newReligionPreference, newExpectedJoining,
        id
      ]
    );

    if (status && status !== client.status) {
      let logDesc = `Status changed to ${status}`;
      if (reason) logDesc += ` (Reason: ${reason})`;
      await logAction('client', id, 'statusChange', logDesc, req.user ? req.user.id : null);
    } else if (newRemarks && newRemarks !== client.remarks) {
      await logAction('client', id, 'noteAdded', `Remarks updated`, req.user ? req.user.id : null);
    }

    const [updatedRows] = await pool.execute(
      'SELECT c.*, u.name AS assigned_sales_name FROM clients c LEFT JOIN users u ON c.assigned_sales_id = u.id WHERE c.id = ?',
      [id]
    );
    res.json(updatedRows[0]);
  } catch (err) {
    console.error('Error in updateClient:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getClients,
  createClient,
  updateClient
};

