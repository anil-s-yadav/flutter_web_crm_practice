import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/invoice_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  String _formatCurrency(double value) {
    final indianFormat = NumberFormat('#,##,###', 'en_IN');
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)} L';
    }
    return '₹${indianFormat.format(value.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final state = Provider.of<GlobalAppState>(context);

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);

    // --- Candidate Counts ---
    final allCandidates = state.candidates;
    final candidatesThisMonth =
        allCandidates
            .where((c) => c.dateAdded.isAfter(currentMonthStart))
            .length;
    final candidatesPrevMonth =
        allCandidates
            .where(
              (c) =>
                  c.dateAdded.isAfter(prevMonthStart) &&
                  c.dateAdded.isBefore(currentMonthStart),
            )
            .length;
    final totalCandidates = allCandidates.length;

    // --- Client Counts ---
    final allClients = state.clients;
    final clientsThisMonth =
        allClients
            .where((c) => c.inquiryDate.isAfter(currentMonthStart))
            .length;
    final clientsPrevMonth =
        allClients
            .where(
              (c) =>
                  c.inquiryDate.isAfter(prevMonthStart) &&
                  c.inquiryDate.isBefore(currentMonthStart),
            )
            .length;
    final totalClients = allClients.length;

    // --- Placement / Contract Counts ---
    final allContracts = state.contracts;
    final placementsThisMonth =
        allContracts
            .where((c) => c.placementDate.isAfter(currentMonthStart))
            .length;
    final placementsPrevMonth =
        allContracts
            .where(
              (c) =>
                  c.placementDate.isAfter(prevMonthStart) &&
                  c.placementDate.isBefore(currentMonthStart),
            )
            .length;
    final totalPlacements = allContracts.length;

    // --- Revenue ---
    final allInvoices = state.invoices;
    final revenueThisMonth = allInvoices
        .where(
          (i) =>
              i.status == InvoiceStatus.paid &&
              i.date.isAfter(currentMonthStart),
        )
        .fold(0.0, (sum, i) => sum + i.amount);
    final revenuePrevMonth = allInvoices
        .where(
          (i) =>
              i.status == InvoiceStatus.paid &&
              i.date.isAfter(prevMonthStart) &&
              i.date.isBefore(currentMonthStart),
        )
        .fold(0.0, (sum, i) => sum + i.amount);
    final totalRevenue = allInvoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold(0.0, (sum, i) => sum + i.amount);
    final pendingCollections = allInvoices
        .where((i) => i.status != InvoiceStatus.paid)
        .fold(0.0, (sum, i) => sum + i.amount);

    // --- Pipeline ---
    final newlyAdded =
        allCandidates
            .where((c) => c.status == CandidateStatus.newlyAdded)
            .length;
    final verificationPending =
        allCandidates
            .where((c) => c.status == CandidateStatus.verificationPending)
            .length;
    final medicalPending =
        allCandidates
            .where((c) => c.status == CandidateStatus.medicalPending)
            .length;
    final readyToPlace =
        allCandidates
            .where((c) => c.status == CandidateStatus.readyToPlace)
            .length;
    final placed =
        allCandidates.where((c) => c.status == CandidateStatus.Placed).length;
    final blacklisted =
        allCandidates
            .where((c) => c.status == CandidateStatus.blacklisted)
            .length;

    // --- Active vs Expired contracts ---
    final activeContracts =
        allContracts
            .where((c) => c.contractStatus == ContractStatus.active)
            .length;
    final expiredContracts =
        allContracts
            .where(
              (c) =>
                  c.contractStatus == ContractStatus.completed ||
                  c.contractStatus == ContractStatus.cancelled,
            )
            .length;

    // --- Client status breakdown ---
    final activeClients =
        allClients.where((c) => c.status == ClientStatus.converted).length;
    final newInquiries =
        allClients.where((c) => c.status == ClientStatus.interested).length;
    final followUpClients =
        allClients.where((c) => c.status == ClientStatus.followUp).length;

    final monthName = DateFormat('MMMM').format(now);
    final prevMonthName = DateFormat('MMMM').format(prevMonthStart);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Period Comparison Cards ---
          _buildSectionTitle('Business Metrics', isDark),
          const SizedBox(height: 16),
          _buildComparisonTable(
            isDark: isDark,
            monthName: monthName,
            prevMonthName: prevMonthName,
            rows: [
              _ComparisonRow(
                'Candidates Added',
                candidatesThisMonth,
                candidatesPrevMonth,
                totalCandidates,
                AppColors.stageInterviewed,
              ),
              _ComparisonRow(
                'Clients Acquired',
                clientsThisMonth,
                clientsPrevMonth,
                totalClients,
                AppColors.gold,
              ),
              _ComparisonRow(
                'Placements Made',
                placementsThisMonth,
                placementsPrevMonth,
                totalPlacements,
                AppColors.stageVerified,
              ),
              _ComparisonRow(
                'Revenue Collected',
                revenueThisMonth.toInt(),
                revenuePrevMonth.toInt(),
                totalRevenue.toInt(),
                AppColors.successGreen,
                isCurrency: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- KPI Row ---
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  icon: Icons.account_balance_wallet,
                  iconColor: AppColors.gold,
                  title: 'Total Revenue',
                  value: _formatCurrency(totalRevenue),
                  subtitle: 'All time',
                  isDark: isDark,
                  onTap: () => context.go('/admin/contracts'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  icon: Icons.money_off,
                  iconColor: AppColors.criticalRed,
                  title: 'Pending Collections',
                  value: _formatCurrency(pendingCollections),
                  subtitle: 'Unpaid invoices',
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  icon: Icons.handshake,
                  iconColor: AppColors.stageVerified,
                  title: 'Active Contracts',
                  value: activeContracts.toString(),
                  subtitle: 'Currently running',
                  isDark: isDark,
                  onTap: () => context.go('/admin/contracts'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  icon: Icons.person_add,
                  iconColor: AppColors.warningOrange,
                  title: 'New Inquiries',
                  value: newInquiries.toString(),
                  subtitle: 'Awaiting follow-up',
                  isDark: isDark,
                  onTap: () => context.go('/admin/clients'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Quick Actions ---
          _buildSectionTitle('Quick Actions', isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(
                'All Candidates',
                Icons.people_outline,
                AppColors.stageInterviewed,
                isDark,
                () => context.go('/admin/candidates/ready'),
              ),
              _buildQuickAction(
                'All Clients',
                Icons.business_outlined,
                AppColors.gold,
                isDark,
                () => context.go('/admin/clients'),
              ),
              _buildQuickAction(
                'Contracts',
                Icons.description_outlined,
                AppColors.stageDocuments,
                isDark,
                () => context.go('/admin/contracts'),
              ),
              _buildQuickAction(
                'Tickets',
                Icons.confirmation_number_outlined,
                AppColors.urgentAmber,
                isDark,
                () => context.go('/admin/tickets'),
              ),
              _buildQuickAction(
                'Audit Trail',
                Icons.history,
                AppColors.stageMedicalCheck,
                isDark,
                () => context.go('/admin/audit'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Pipeline + Revenue Row ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildPipelineCard(
                  isDark,
                  newlyAdded,
                  verificationPending,
                  medicalPending,
                  readyToPlace,
                  placed,
                  blacklisted,
                  totalCandidates,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildRevenueChart(isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // --- Client & Contract Breakdown + Recent Activity ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildBreakdownCard('Client Status', isDark, [
                      _BreakdownItem(
                        'New Inquiries',
                        newInquiries,
                        AppColors.stageInterviewed,
                      ),
                      _BreakdownItem(
                        'Follow Ups',
                        followUpClients,
                        AppColors.warningOrange,
                      ),
                      _BreakdownItem(
                        'Active (Converted)',
                        activeClients,
                        AppColors.successGreen,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildBreakdownCard('Contract Status', isDark, [
                      _BreakdownItem(
                        'Active',
                        activeContracts,
                        AppColors.successGreen,
                      ),
                      _BreakdownItem(
                        'Expired',
                        expiredContracts,
                        AppColors.criticalRed,
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildRecentActivity(isDark, state.auditLogs),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section Title ---
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.white : AppColors.navyBlue,
      ),
    );
  }

  // --- Comparison Table ---
  Widget _buildComparisonTable({
    required bool isDark,
    required String monthName,
    required String prevMonthName,
    required List<_ComparisonRow> rows,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Metric', style: _headerStyle(isDark)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    monthName,
                    style: _headerStyle(isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    prevMonthName,
                    style: _headerStyle(isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'All Time',
                    style: _headerStyle(isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Trend',
                    style: _headerStyle(isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
              height: 1,
            ),
            const SizedBox(height: 8),
            // Rows
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildComparisonRow(row, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(_ComparisonRow row, bool isDark) {
    final indianFormat = NumberFormat('#,##,###', 'en_IN');
    final diff = row.current - row.previous;
    final isUp = diff >= 0;

    String formatVal(int val) {
      if (row.isCurrency) return _formatCurrency(val.toDouble());
      return indianFormat.format(val);
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: row.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                row.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            formatVal(row.current),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            formatVal(row.previous),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            formatVal(row.total),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: isUp ? AppColors.successGreen : AppColors.criticalRed,
              ),
              const SizedBox(width: 4),
              Text(
                row.previous > 0
                    ? '${((diff.abs() / row.previous) * 100).toStringAsFixed(0)}%'
                    : (row.current > 0 ? '100%' : '0%'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUp ? AppColors.successGreen : AppColors.criticalRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyle(bool isDark) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.grey400 : AppColors.grey600,
    );
  }

  // --- KPI Card ---
  Widget _buildKPICard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
        color: isDark ? AppColors.darkSurface : AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.grey500 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Quick Action ---
  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Pipeline Card ---
  Widget _buildPipelineCard(
    bool isDark,
    int newlyAdded,
    int verification,
    int medical,
    int ready,
    int placed,
    int blacklisted,
    int total,
  ) {
    final stages = [
      _PipelineStage('Newly Added', newlyAdded, AppColors.stagePending),
      _PipelineStage(
        'Verification',
        verification,
        AppColors.stagePoliceVerification,
      ),
      _PipelineStage('Medical', medical, AppColors.stageMedicalCheck),
      _PipelineStage('Ready to Place', ready, AppColors.stageDocuments),
      _PipelineStage('Placed', placed, AppColors.stageVerified),
      _PipelineStage('Blacklisted', blacklisted, AppColors.criticalRed),
    ];
    final maxCount = stages.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate Pipeline',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$total total candidates across all stages',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),
            ...stages.map(
              (stage) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPipelineRow(stage, maxCount, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineRow(_PipelineStage stage, int maxCount, bool isDark) {
    final pct = maxCount > 0 ? stage.count / maxCount : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stage.label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.grey300 : AppColors.grey700,
              ),
            ),
            Text(
              stage.count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor:
                isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
            valueColor: AlwaysStoppedAnimation<Color>(stage.color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  // --- Revenue Chart ---
  Widget _buildRevenueChart(bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last 6 months overview',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar('Feb', 0.35, isDark),
                  _buildChartBar('Mar', 0.55, isDark),
                  _buildChartBar('Apr', 0.45, isDark),
                  _buildChartBar('May', 0.75, isDark),
                  _buildChartBar('Jun', 0.65, isDark),
                  _buildChartBar('Jul', 1.0, isDark, isCurrent: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Current Month',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(
    String label,
    double fillPct,
    bool isDark, {
    bool isCurrent = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  heightFactor: fillPct,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isCurrent
                              ? AppColors.gold
                              : (isDark
                                  ? AppColors.grey700
                                  : AppColors.grey300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isDark ? AppColors.grey300 : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Breakdown Card ---
  Widget _buildBreakdownCard(
    String title,
    bool isDark,
    List<_BreakdownItem> items,
  ) {
    final total = items.fold(0, (sum, i) => sum + i.count);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 24),
            ...items.map((item) {
              final pct = total > 0 ? item.count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color:
                                isDark ? AppColors.grey300 : AppColors.grey700,
                          ),
                        ),
                        Text(
                          item.count.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor:
                            isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.grey100,
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- Recent Activity ---
  Widget _buildRecentActivity(bool isDark, List<AuditLogModel> logs) {
    final recentLogs = logs.take(8).toList();
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Builder(
                  builder:
                      (context) => TextButton(
                        onPressed: () => context.go('/admin/audit'),
                        child: Text(
                          'View All →',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 40,
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent activity yet.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actions like adding candidates or updating invoices will appear here.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey500 : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentLogs.map((log) {
                Color actionColor;
                IconData actionIcon;
                switch (log.actionType) {
                  case ActionType.create:
                    actionColor = AppColors.successGreen;
                    actionIcon = Icons.add_circle_outline;
                    break;
                  case ActionType.update:
                    actionColor = AppColors.stageInterviewed;
                    actionIcon = Icons.edit_outlined;
                    break;
                  case ActionType.delete:
                    actionColor = AppColors.criticalRed;
                    actionIcon = Icons.delete_outline;
                    break;
                  case ActionType.statusChange:
                    actionColor = AppColors.warningOrange;
                    actionIcon = Icons.swap_horiz;
                    break;
                  case ActionType.paymentLogged:
                    actionColor = AppColors.gold;
                    actionIcon = Icons.payment;
                    break;
                  case ActionType.contractRenewed:
                    actionColor = AppColors.stageDocuments;
                    actionIcon = Icons.autorenew;
                    break;
                  case ActionType.slaInitiated:
                    actionColor = AppColors.stageMedicalCheck;
                    actionIcon = Icons.timer;
                    break;
                  case ActionType.taskCompleted:
                    actionColor = AppColors.stageVerified;
                    actionIcon = Icons.task_alt;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(actionIcon, size: 16, color: actionColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log.userName} • ${dateFormat.format(log.timestamp)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color:
                                    isDark
                                        ? AppColors.grey500
                                        : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _PipelineStage {
  final String label;
  final int count;
  final Color color;
  const _PipelineStage(this.label, this.count, this.color);
}

class _ComparisonRow {
  final String label;
  final int current;
  final int previous;
  final int total;
  final Color color;
  final bool isCurrency;
  const _ComparisonRow(
    this.label,
    this.current,
    this.previous,
    this.total,
    this.color, {
    this.isCurrency = false,
  });
}

class _BreakdownItem {
  final String label;
  final int count;
  final Color color;
  const _BreakdownItem(this.label, this.count, this.color);
}
