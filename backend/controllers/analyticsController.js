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

    res.json({
      revenue: {
        total: revenueRes[0].total || 0,
        collected: revenueRes[0].collected || 0,
      },
      activeContracts: contractsRes[0].count,
      pendingReplacements: replacementsRes[0].count,
      activeLeads: leadsRes[0].count,
      pendingTasks: tasksRes[0].count
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
      activeContracts: contractsRes[0].activeContracts,
      myLeads: leadsRes[0].count,
      myConversions: convertedRes[0].count
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
    const [readyRes] = await pool.execute('SELECT COUNT(*) as count FROM candidates WHERE status = "readyToPlace"');
    const [pendingVerificationRes] = await pool.execute('SELECT COUNT(*) as count FROM candidates WHERE is_police_verified = FALSE OR is_medical_cleared = FALSE');
    const [urgentRes] = await pool.execute('SELECT COUNT(*) as count FROM replacement_requests WHERE is_escalated_to_sourcing = TRUE');

    res.json({
      readyToPlace: readyRes[0].count,
      pendingVerification: pendingVerificationRes[0].count,
      urgentReplacements: urgentRes[0].count
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

    const [pendingRes] = await pool.execute('SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_executive_id = ? AND status != "completed"', [execId]);
    const [completedRes] = await pool.execute('SELECT COUNT(*) as count FROM executive_tasks WHERE assigned_executive_id = ? AND status = "completed"', [execId]);

    res.json({
      pendingTasks: pendingRes[0].count,
      completedTasks: completedRes[0].count
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
