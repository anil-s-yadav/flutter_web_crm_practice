const pool = require('../config/db');

// @route   GET /api/analytics/admin
// @desc    Get top-level KPIs for Admin Dashboard
// @access  Private (Admin)
const getAdminAnalytics = async (req, res) => {
  try {
    const [revenueRes] = await pool.execute('SELECT SUM(total_fee) as total, SUM(amount_paid) as collected FROM contracts');
    const [contractsRes] = await pool.execute('SELECT COUNT(*) as count FROM contracts WHERE status = "active"');
    const [replacementsRes] = await pool.execute('SELECT COUNT(*) as count FROM replacement_requests WHERE status != "resolved"');
    const [leadsRes] = await pool.execute('SELECT COUNT(*) as count FROM clients WHERE status = "lead"');
    const [tasksRes] = await pool.execute('SELECT COUNT(*) as count FROM executive_tasks WHERE status != "completed"');

    const total = Number(revenueRes[0].total || 0);
    const collected = Number(revenueRes[0].collected || 0);

    res.json({
      revenue: {
        total: total,
        collected: collected,
        pending: total - collected,
        thisMonth: collected,
        prevMonth: 0
      },
      contracts: {
        active: contractsRes[0].count,
        renewed: 0,
        expired: 0
      },
      clients: {
        active: leadsRes[0].count,
        leads: leadsRes[0].count,
        followUps: 0,
        thisMonth: 0,
        prevMonth: 0,
        total: leadsRes[0].count
      },
      replacements: {
        pending: replacementsRes[0].count
      },
      pipeline: {
        newlyAdded: 0,
        verificationPending: 0,
        medicalPending: 0,
        readyToPlace: 0,
        placed: 0,
        blacklisted: 0,
        thisMonth: 0,
        prevMonth: 0,
        total: 0
      },
      tasks: {
        pending: tasksRes[0].count
      },
      placements: {
        thisMonth: 0,
        prevMonth: 0,
        total: contractsRes[0].count
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/analytics/sales
// @desc    Get KPIs for Sales Dashboard (scoped to current user)
// @access  Private (Sales/Admin)
const getSalesAnalytics = async (req, res) => {
  try {
    const salesId = req.user.id;
    
    // Contracts tied to clients managed by this sales rep
    const [contractsRes] = await pool.execute(`
      SELECT COUNT(*) as activeContracts 
      FROM contracts c
      JOIN clients cl ON c.client_id = cl.id
      WHERE cl.assigned_sales_id = ? AND c.status = "active"
    `, [salesId]);

    const [leadsRes] = await pool.execute('SELECT COUNT(*) as count FROM clients WHERE assigned_sales_id = ? AND status = "lead"', [salesId]);
    const [convertedRes] = await pool.execute('SELECT COUNT(*) as count FROM clients WHERE assigned_sales_id = ? AND status = "converted"', [salesId]);

    res.json({
      clients: {
        followUps: 0,
        interested: leadsRes[0].count,
        notInterested: 0,
        converted: convertedRes[0].count,
        totalPipeline: leadsRes[0].count + convertedRes[0].count
      },
      revenue: {
        currentMonth: 0,
        lastMonth: 0
      },
      contracts: {
        currentMonthClosed: 0,
        lastMonthClosed: 0
      },
      slaCountdowns: 0,
      inquiries: {
        currentMonth: 0,
        lastMonth: 0
      },
      recent: {
        followUpClients: [],
        topWins: []
      },
      categories: []
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/analytics/sourcing
// @desc    Get KPIs for Sourcing Dashboard
// @access  Private (Sourcing/Admin)
const getSourcingAnalytics = async (req, res) => {
  try {
    const sourcingId = req.user.id;
    const [candidatesRes] = await pool.execute('SELECT COUNT(*) as count FROM candidates WHERE added_by_id = ?', [sourcingId]);
    const [pipelineRes] = await pool.execute('SELECT COUNT(*) as count FROM candidates WHERE added_by_id = ? AND status IN ("verification_pending", "medical_pending", "ready_to_place")', [sourcingId]);
    const [replacementsRes] = await pool.execute('SELECT COUNT(*) as count FROM replacement_requests WHERE status = "pending"');

    res.json({
      myCandidates: candidatesRes[0].count,
      activePipeline: pipelineRes[0].count,
      urgentReplacements: replacementsRes[0].count,
      pipeline: {
        newlyAdded: 0,
        verificationPending: pipelineRes[0].count,
        medicalPending: 0,
        readyToPlace: 0,
        placed: 0,
        blacklisted: 0
      },
      quality: {
        placementsThisMonth: 0,
        replacementsThisMonth: 0,
        successRate: 0
      },
      urgent: {
        totalPending: replacementsRes[0].count,
        highPriority: 0,
        dueToday: 0
      },
      recent: {
        urgentRequests: [],
        newCandidates: []
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/analytics/executive
// @desc    Get KPIs for Executive Dashboard (scoped to current user)
// @access  Private (Executive/Admin)
const getExecutiveAnalytics = async (req, res) => {
  try {
    const execId = req.user.id;
    const [tasksRes] = await pool.execute('SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_to_id = ? AND status = "pending"', [execId]);
    const [clientsRes] = await pool.execute('SELECT COUNT(*) as count FROM clients'); // simplified for now

    res.json({
      pendingTasks: tasksRes[0].count,
      activeClients: clientsRes[0].count,
      tasks: {
        pending: tasksRes[0].count,
        inProgress: 0,
        completedToday: 0
      },
      clients: {
        followUps: 0,
        escalated: 0
      },
      recent: {
        tasks: []
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getAdminAnalytics,
  getSalesAnalytics,
  getSourcingAnalytics,
  getExecutiveAnalytics
};
