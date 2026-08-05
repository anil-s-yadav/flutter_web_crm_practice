const pool = require('../config/db');

// Helper: compute date boundaries for this month and previous month
function getDateBoundaries() {
  const now = new Date();
  const thisMonthStart = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;
  const prevMonthDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const prevMonthStart = `${prevMonthDate.getFullYear()}-${String(prevMonthDate.getMonth() + 1).padStart(2, '0')}-01`;
  const prevMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);
  const prevMonthEndStr = `${prevMonthEnd.getFullYear()}-${String(prevMonthEnd.getMonth() + 1).padStart(2, '0')}-${String(prevMonthEnd.getDate()).padStart(2, '0')}`;
  return { thisMonthStart, prevMonthStart, prevMonthEndStr };
}

// @route   GET /api/analytics/admin
// @desc    Get top-level KPIs for Admin Dashboard
// @access  Private (Admin)
const getAdminAnalytics = async (req, res) => {
  try {
    const { thisMonthStart, prevMonthStart, prevMonthEndStr } = getDateBoundaries();

    // --- Pipeline: candidates by status ---
    const [pipelineRows] = await pool.execute(
      'SELECT status, COUNT(*) as count FROM candidates GROUP BY status'
    );
    const pipeline = {
      newlyAdded: 0, verificationPending: 0, medicalPending: 0,
      readyToPlace: 0, placed: 0, blacklisted: 0, total: 0, thisMonth: 0, prevMonth: 0
    };
    let totalCandidates = 0;
    for (const row of pipelineRows) {
      if (pipeline.hasOwnProperty(row.status)) pipeline[row.status] = Number(row.count);
      totalCandidates += Number(row.count);
    }
    pipeline.total = totalCandidates;

    // Candidates added this month / prev month
    const [candThisMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM candidates WHERE created_at >= ?', [thisMonthStart]
    );
    const [candPrevMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM candidates WHERE created_at >= ? AND created_at <= ?',
      [prevMonthStart, prevMonthEndStr + ' 23:59:59']
    );
    pipeline.thisMonth = Number(candThisMonth[0].count);
    pipeline.prevMonth = Number(candPrevMonth[0].count);

    // --- Clients ---
    const [clientsTotal] = await pool.execute('SELECT COUNT(*) as count FROM clients');
    const [clientsLead] = await pool.execute("SELECT COUNT(*) as count FROM clients WHERE status = 'lead'");
    const [clientsFollowUp] = await pool.execute("SELECT COUNT(*) as count FROM clients WHERE status = 'followUp'");
    const [clientsConverted] = await pool.execute("SELECT COUNT(*) as count FROM clients WHERE status = 'converted'");
    const [clientsThisMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM clients WHERE created_at >= ?', [thisMonthStart]
    );
    const [clientsPrevMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM clients WHERE created_at >= ? AND created_at <= ?',
      [prevMonthStart, prevMonthEndStr + ' 23:59:59']
    );

    // --- Revenue ---
    const [revenueAll] = await pool.execute(
      'SELECT COALESCE(SUM(total_fee), 0) as total_fee, COALESCE(SUM(amount_paid), 0) as collected FROM contracts'
    );
    const [revenueThisMonth] = await pool.execute(
      'SELECT COALESCE(SUM(amount_paid), 0) as collected FROM contracts WHERE created_at >= ?', [thisMonthStart]
    );
    const [revenuePrevMonth] = await pool.execute(
      'SELECT COALESCE(SUM(amount_paid), 0) as collected FROM contracts WHERE created_at >= ? AND created_at <= ?',
      [prevMonthStart, prevMonthEndStr + ' 23:59:59']
    );
    const totalFee = Number(revenueAll[0].total_fee);
    const totalCollected = Number(revenueAll[0].collected);

    // --- Contracts by status ---
    const [contractsActive] = await pool.execute("SELECT COUNT(*) as count FROM contracts WHERE status = 'active'");
    const [contractsRenewed] = await pool.execute('SELECT COUNT(*) as count FROM contracts WHERE is_renewal = TRUE');
    const [contractsExpired] = await pool.execute("SELECT COUNT(*) as count FROM contracts WHERE status = 'expired'");

    // --- Placements (contracts created) by month ---
    const [placementsThisMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM contracts WHERE created_at >= ?', [thisMonthStart]
    );
    const [placementsPrevMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM contracts WHERE created_at >= ? AND created_at <= ?',
      [prevMonthStart, prevMonthEndStr + ' 23:59:59']
    );
    const [placementsTotal] = await pool.execute('SELECT COUNT(*) as count FROM contracts');

    // --- Replacements ---
    const [replacementsPending] = await pool.execute(
      "SELECT COUNT(*) as count FROM replacement_requests WHERE status != 'resolved'"
    );

    // --- Tasks ---
    const [tasksPending] = await pool.execute(
      "SELECT COUNT(*) as count FROM executive_tasks WHERE status != 'completed'"
    );

    res.json({
      revenue: {
        total: totalCollected,
        collected: totalCollected,
        pending: totalFee - totalCollected,
        thisMonth: Number(revenueThisMonth[0].collected),
        prevMonth: Number(revenuePrevMonth[0].collected),
      },
      contracts: {
        active: Number(contractsActive[0].count),
        renewed: Number(contractsRenewed[0].count),
        expired: Number(contractsExpired[0].count),
      },
      clients: {
        active: Number(clientsConverted[0].count),
        leads: Number(clientsLead[0].count),
        followUps: Number(clientsFollowUp[0].count),
        thisMonth: Number(clientsThisMonth[0].count),
        prevMonth: Number(clientsPrevMonth[0].count),
        total: Number(clientsTotal[0].count),
      },
      replacements: {
        pending: Number(replacementsPending[0].count),
      },
      pipeline: pipeline,
      tasks: {
        pending: Number(tasksPending[0].count),
      },
      placements: {
        thisMonth: Number(placementsThisMonth[0].count),
        prevMonth: Number(placementsPrevMonth[0].count),
        total: Number(placementsTotal[0].count),
      },
    });
  } catch (err) {
    console.error('getAdminAnalytics error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

// @route   GET /api/analytics/sales
// @desc    Get KPIs for Sales Dashboard (scoped to current user)
// @access  Private (Sales/Admin)
const getSalesAnalytics = async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin';
    const salesId = req.user.id;
    const { thisMonthStart, prevMonthStart, prevMonthEndStr } = getDateBoundaries();

    // Build WHERE clause: admin sees all, sales user sees only assigned
    const salesFilter = isAdmin ? '' : ' AND assigned_sales_id = ?';
    const salesParams = isAdmin ? [] : [salesId];
    const salesJoinFilter = isAdmin ? '' : ' AND cl.assigned_sales_id = ?';

    // Client counts by status
    const [followUpRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE status = 'followUp'${salesFilter}`, salesParams
    );
    const [interestedRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE status = 'lead'${salesFilter}`, salesParams
    );
    const [notInterestedRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE status = 'inactive'${salesFilter}`, salesParams
    );
    const [convertedRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE status = 'converted'${salesFilter}`, salesParams
    );

    const followUps = Number(followUpRes[0].count);
    const interested = Number(interestedRes[0].count);
    const notInterested = Number(notInterestedRes[0].count);
    const converted = Number(convertedRes[0].count);

    // Revenue this month / last month
    const [revenueThisMonth] = await pool.execute(`
      SELECT COALESCE(SUM(c.amount_paid), 0) as collected
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE c.created_at >= ?${salesJoinFilter}
    `, [thisMonthStart, ...salesParams]);
    const [revenueLastMonth] = await pool.execute(`
      SELECT COALESCE(SUM(c.amount_paid), 0) as collected
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE c.created_at >= ? AND c.created_at <= ?${salesJoinFilter}
    `, [prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]);

    // Contract counts this month / last month
    const [contractsThisMonth] = await pool.execute(`
      SELECT COUNT(*) as count
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE c.created_at >= ?${salesJoinFilter}
    `, [thisMonthStart, ...salesParams]);
    const [contractsLastMonth] = await pool.execute(`
      SELECT COUNT(*) as count
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE c.created_at >= ? AND c.created_at <= ?${salesJoinFilter}
    `, [prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]);

    // Inquiries (clients created) this month / last month
    const [inquiriesThisMonth] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE created_at >= ?${salesFilter}`,
      [thisMonthStart, ...salesParams]
    );
    const [inquiriesLastMonth] = await pool.execute(
      `SELECT COUNT(*) as count FROM clients WHERE created_at >= ? AND created_at <= ?${salesFilter}`,
      [prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]
    );

    res.json({
      clients: {
        followUps: followUps,
        interested: interested,
        notInterested: notInterested,
        converted: converted,
        totalPipeline: followUps + interested + notInterested + converted,
      },
      revenue: {
        currentMonth: Number(revenueThisMonth[0].collected),
        lastMonth: Number(revenueLastMonth[0].collected),
      },
      contracts: {
        currentMonthClosed: Number(contractsThisMonth[0].count),
        lastMonthClosed: Number(contractsLastMonth[0].count),
      },
      slaCountdowns: 0,
      inquiries: {
        currentMonth: Number(inquiriesThisMonth[0].count),
        lastMonth: Number(inquiriesLastMonth[0].count),
      },
      recent: {
        followUpClients: [],
        topWins: [],
      },
      categories: [],
    });
  } catch (err) {
    console.error('getSalesAnalytics error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

// @route   GET /api/analytics/sourcing
// @desc    Get KPIs for Sourcing Dashboard (scoped to current user)
// @access  Private (Sourcing/Admin)
const getSourcingAnalytics = async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin';
    const sourcingId = req.user.id;
    const { thisMonthStart, prevMonthStart, prevMonthEndStr } = getDateBoundaries();

    // Build WHERE clause: admin sees all, sourcing user sees only theirs
    const ownerFilter = isAdmin ? '' : ' WHERE sourced_by_id = ?';
    const ownerFilterAnd = isAdmin ? '' : ' AND sourced_by_id = ?';
    const ownerParams = isAdmin ? [] : [sourcingId];

    // Total candidates
    const [myCandidatesRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM candidates${ownerFilter}`, ownerParams
    );

    // Pipeline breakdown by status
    const [pipelineRows] = await pool.execute(
      `SELECT status, COUNT(*) as count FROM candidates${ownerFilter} GROUP BY status`, ownerParams
    );
    const pipeline = {
      newlyAdded: 0, verificationPending: 0, medicalPending: 0,
      readyToPlace: 0, placed: 0, blacklisted: 0
    };
    let activePipeline = 0;
    for (const row of pipelineRows) {
      if (pipeline.hasOwnProperty(row.status)) pipeline[row.status] = Number(row.count);
      if (['verificationPending', 'medicalPending', 'readyToPlace'].includes(row.status)) {
        activePipeline += Number(row.count);
      }
    }

    // Urgent replacements
    const [replacementsRes] = await pool.execute(
      "SELECT COUNT(*) as count FROM replacement_requests WHERE status = 'pending'"
    );

    // Placements this month
    const placementQuery = isAdmin
      ? 'SELECT COUNT(*) as count FROM contracts WHERE created_at >= ?'
      : `SELECT COUNT(*) as count FROM contracts c JOIN candidates cand ON c.candidate_id = cand.id WHERE cand.sourced_by_id = ? AND c.created_at >= ?`;
    const placementParams = isAdmin ? [thisMonthStart] : [sourcingId, thisMonthStart];
    const [placementsThisMonth] = await pool.execute(placementQuery, placementParams);

    // Replacements this month
    const [replacementsThisMonth] = await pool.execute(
      'SELECT COUNT(*) as count FROM replacement_requests WHERE created_at >= ?', [thisMonthStart]
    );

    // Candidates added this month
    const [addedThisMonth] = await pool.execute(
      `SELECT COUNT(*) as count FROM candidates WHERE created_at >= ?${ownerFilterAnd}`,
      [thisMonthStart, ...ownerParams]
    );
    // Candidates added last month
    const [addedLastMonth] = await pool.execute(
      `SELECT COUNT(*) as count FROM candidates WHERE created_at >= ? AND created_at <= ?${ownerFilterAnd}`,
      [prevMonthStart, prevMonthEndStr + ' 23:59:59', ...ownerParams]
    );

    const placementsCount = Number(placementsThisMonth[0].count);
    const replacementsCount = Number(replacementsThisMonth[0].count);
    const successRate = placementsCount > 0
      ? Math.round(((placementsCount - replacementsCount) / placementsCount) * 100)
      : 0;

    // Breakdown for Ready to Place candidates based on medical status
    const [readyMedicalRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM candidates WHERE status = 'readyToPlace' AND is_medical_cleared = TRUE${ownerFilterAnd}`, ownerParams
    );
    const [readyNoMedicalRes] = await pool.execute(
      `SELECT COUNT(*) as count FROM candidates WHERE status = 'readyToPlace' AND is_medical_cleared = FALSE${ownerFilterAnd}`, ownerParams
    );

    res.json({
      myCandidates: Number(myCandidatesRes[0].count),
      activePipeline: activePipeline,
      urgentReplacements: Number(replacementsRes[0].count),
      addedThisMonth: Number(addedThisMonth[0].count),
      addedLastMonth: Number(addedLastMonth[0].count),
      readyNoMedical: Number(readyNoMedicalRes[0].count),
      readyMedicalVerified: Number(readyMedicalRes[0].count),
      pipeline: pipeline,
      quality: {
        placementsThisMonth: placementsCount,
        replacementsThisMonth: replacementsCount,
        successRate: successRate,
      },
      urgent: {
        totalPending: Number(replacementsRes[0].count),
        highPriority: 0,
        dueToday: 0,
      },
      recent: {
        urgentRequests: [],
        newCandidates: [],
      },
    });
  } catch (err) {
    console.error('getSourcingAnalytics error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

// @route   GET /api/analytics/executive
// @desc    Get KPIs for Executive Dashboard (scoped to current user)
// @access  Private (Executive/Admin)
const getExecutiveAnalytics = async (req, res) => {
  try {
    const execId = req.user.id;
    const [pendingRes] = await pool.execute(
      'SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_executive_id = ? AND status = "pending"',
      [execId]
    );
    const [inProgressRes] = await pool.execute(
      'SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_executive_id = ? AND status = "inProgress"',
      [execId]
    );
    const [completedRes] = await pool.execute(
      'SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_executive_id = ? AND status = "completed" AND DATE(completed_date) = CURDATE()',
      [execId]
    );
    const [clientsRes] = await pool.execute('SELECT COUNT(*) as count FROM clients');

    res.json({
      pendingTasks: Number(pendingRes[0].count),
      activeClients: Number(clientsRes[0].count),
      tasks: {
        pending: Number(pendingRes[0].count),
        inProgress: Number(inProgressRes[0].count),
        completedToday: Number(completedRes[0].count),
      },
      clients: {
        followUps: 0,
        escalated: 0,
      },
      recent: {
        tasks: [],
      },
    });
  } catch (err) {
    console.error('getExecutiveAnalytics error:', err);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

module.exports = {
  getAdminAnalytics,
  getSalesAnalytics,
  getSourcingAnalytics,
  getExecutiveAnalytics,
};
