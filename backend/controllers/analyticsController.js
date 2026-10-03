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
    const [clientStats] = await pool.execute(`
      SELECT 
        COUNT(*) as count_total,
        COUNT(CASE WHEN status = 'lead' THEN 1 END) as count_lead,
        COUNT(CASE WHEN status = 'followUp' THEN 1 END) as count_followUp,
        COUNT(CASE WHEN status = 'converted' THEN 1 END) as count_converted,
        COUNT(CASE WHEN created_at >= ? THEN 1 END) as count_this_month,
        COUNT(CASE WHEN created_at >= ? AND created_at <= ? THEN 1 END) as count_prev_month
      FROM clients
    `, [thisMonthStart, prevMonthStart, prevMonthEndStr + ' 23:59:59']);
    
    const clientsTotal = [{ count: clientStats[0].count_total }];
    const clientsLead = [{ count: clientStats[0].count_lead }];
    const clientsFollowUp = [{ count: clientStats[0].count_followUp }];
    const clientsConverted = [{ count: clientStats[0].count_converted }];
    const clientsThisMonth = [{ count: clientStats[0].count_this_month }];
    const clientsPrevMonth = [{ count: clientStats[0].count_prev_month }];

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

    // --- Contracts by status & Placements (contracts created) by month ---
    const [contractStats] = await pool.execute(`
      SELECT 
        COUNT(CASE WHEN status = 'active' THEN 1 END) as active,
        COUNT(CASE WHEN is_renewal = TRUE THEN 1 END) as renewed,
        COUNT(CASE WHEN status = 'expired' THEN 1 END) as expired,
        COUNT(CASE WHEN created_at >= ? THEN 1 END) as this_month,
        COUNT(CASE WHEN created_at >= ? AND created_at <= ? THEN 1 END) as prev_month,
        COUNT(*) as total
      FROM contracts
    `, [thisMonthStart, prevMonthStart, prevMonthEndStr + ' 23:59:59']);

    const contractsActive = [{ count: contractStats[0].active }];
    const contractsRenewed = [{ count: contractStats[0].renewed }];
    const contractsExpired = [{ count: contractStats[0].expired }];
    const placementsThisMonth = [{ count: contractStats[0].this_month }];
    const placementsPrevMonth = [{ count: contractStats[0].prev_month }];
    const placementsTotal = [{ count: contractStats[0].total }];

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

    // Build WHERE clause: admin sees all, sales user sees ONLY their assigned clients
    const salesFilter = isAdmin ? '' : ' AND assigned_sales_id = ?';
    const salesParams = isAdmin ? [] : [salesId];
    const salesJoinFilter = isAdmin ? '' : ' AND cl.assigned_sales_id = ?';

    // Client counts by status
    const [clientStats] = await pool.execute(`
      SELECT 
        COUNT(CASE WHEN status IN ('followUp', 'lead') THEN 1 END) as followUp,
        COUNT(CASE WHEN status = 'interested' THEN 1 END) as interested,
        COUNT(CASE WHEN status IN ('notInterested', 'inactive') THEN 1 END) as notInterested,
        COUNT(CASE WHEN status IN ('converted', 'active') THEN 1 END) as converted
      FROM clients
      WHERE 1=1 ${salesFilter}
    `, salesParams);

    const followUps = Number(clientStats[0].followUp);
    const interested = Number(clientStats[0].interested);
    const notInterested = Number(clientStats[0].notInterested);
    const converted = Number(clientStats[0].converted);

    // Revenue this month / last month
    const [revenueStats] = await pool.execute(`
      SELECT 
        COALESCE(SUM(CASE WHEN c.created_at >= ? THEN c.amount_paid ELSE 0 END), 0) as thisMonth,
        COALESCE(SUM(CASE WHEN c.created_at >= ? AND c.created_at <= ? THEN c.amount_paid ELSE 0 END), 0) as lastMonth
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE 1=1 ${salesJoinFilter}
    `, [thisMonthStart, prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]);
    const revenueThisMonth = [{ collected: revenueStats[0].thisMonth }];
    const revenueLastMonth = [{ collected: revenueStats[0].lastMonth }];

    // Contract counts this month / last month
    const [contractCountStats] = await pool.execute(`
      SELECT 
        COUNT(CASE WHEN c.created_at >= ? THEN 1 END) as thisMonth,
        COUNT(CASE WHEN c.created_at >= ? AND c.created_at <= ? THEN 1 END) as lastMonth
      FROM contracts c JOIN clients cl ON c.client_id = cl.id
      WHERE 1=1 ${salesJoinFilter}
    `, [thisMonthStart, prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]);
    const contractsThisMonth = [{ count: contractCountStats[0].thisMonth }];
    const contractsLastMonth = [{ count: contractCountStats[0].lastMonth }];

    // Inquiries (clients created) this month / last month
    const [inquiryStats] = await pool.execute(`
      SELECT 
        COUNT(CASE WHEN created_at >= ? THEN 1 END) as thisMonth,
        COUNT(CASE WHEN created_at >= ? AND created_at <= ? THEN 1 END) as lastMonth
      FROM clients
      WHERE 1=1 ${salesFilter}
    `, [thisMonthStart, prevMonthStart, prevMonthEndStr + ' 23:59:59', ...salesParams]);
    const inquiriesThisMonth = [{ count: inquiryStats[0].thisMonth }];
    const inquiriesLastMonth = [{ count: inquiryStats[0].lastMonth }];

    // Actionable follow-up clients list
    const [followUpClientsRows] = await pool.execute(`
      SELECT c.*, u.name AS assigned_sales_name 
      FROM clients c 
      LEFT JOIN users u ON c.assigned_sales_id = u.id 
      WHERE c.status IN ('followUp', 'lead') ${isAdmin ? '' : ' AND c.assigned_sales_id = ?'}
      ORDER BY c.inquiry_date ASC, c.created_at DESC 
      LIMIT 10
    `, salesParams);

    // Recent top wins / contracts
    const [topWinsRows] = await pool.execute(`
      SELECT c.*, cl.name AS client_name, cd.full_name AS candidate_name
      FROM contracts c
      LEFT JOIN clients cl ON c.client_id = cl.id
      LEFT JOIN candidates cd ON c.candidate_id = cd.id
      WHERE 1=1 ${salesJoinFilter}
      ORDER BY c.created_at DESC
      LIMIT 5
    `, salesParams);

    // Top driving categories
    let [categoryRows] = await pool.execute(`
      SELECT COALESCE(cl.preferred_category, 'House Maid') as category, COUNT(*) as count
      FROM contracts c
      JOIN clients cl ON c.client_id = cl.id
      WHERE 1=1 ${salesJoinFilter}
      GROUP BY cl.preferred_category
      ORDER BY count DESC
      LIMIT 5
    `, salesParams);

    if (categoryRows.length === 0) {
      const [clientCategoryRows] = await pool.execute(`
        SELECT COALESCE(preferred_category, 'House Maid') as category, COUNT(*) as count
        FROM clients
        WHERE 1=1 ${salesFilter}
        GROUP BY preferred_category
        ORDER BY count DESC
        LIMIT 5
      `, salesParams);
      categoryRows = clientCategoryRows;
    }

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
        followUpClients: followUpClientsRows,
        topWins: topWinsRows,
      },
      categories: categoryRows.map(r => ({ category: r.category, count: Number(r.count) })),
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
      `SELECT COUNT(*) as count FROM candidates WHERE status = 'readyToPlace' AND (is_medical_cleared = FALSE OR is_medical_cleared IS NULL)${ownerFilterAnd}`, ownerParams
    );
    // Urgent Hires from Sales
    const [urgentHiresRes] = await pool.execute(
      "SELECT COUNT(*) as count FROM urgent_hires WHERE status = 'pending'"
    );
    const [recentUrgentHires] = await pool.execute(
      "SELECT * FROM urgent_hires WHERE status IN ('pending', 'in_progress') ORDER BY created_at DESC LIMIT 5"
    );

    res.json({
      myCandidates: Number(myCandidatesRes[0].count),
      activePipeline: activePipeline,
      urgentReplacements: Number(replacementsRes[0].count),
      urgentHiresPending: Number(urgentHiresRes[0].count),
      urgentHires: recentUrgentHires,
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
        urgentHiresPending: Number(urgentHiresRes[0].count),
        highPriority: 0,
        dueToday: 0,
      },
      recent: {
        urgentRequests: recentUrgentHires,
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
