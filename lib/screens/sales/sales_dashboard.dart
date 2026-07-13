import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/utils/extensions.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isDesktop = width > 1100;
    final isTablet = width > 700;

    // Filter data for Sales user
    final myClients =
        state.currentUser?.role == UserRole.sales
            ? state.clients.where((c) => c.assignedEmployeeId == '2').toList()
            : state.clients;

    final myContracts =
        state.currentUser?.role == UserRole.sales
            ? state.contracts
                .where((c) => c.createdBy == 'Priya Mehta')
                .toList()
            : state.contracts;

    // Pipeline Stats
    final newInquiries =
        myClients.where((c) => c.status == ClientStatus.newInquiry).length;
    final followUps =
        myClients.where((c) => c.status == ClientStatus.followUp).length;
    final negotiating =
        0; // Assuming we use followUps or define a negotiating stage later
    final converted =
        myClients
            .where(
              (c) =>
                  c.status == ClientStatus.converted ||
                  c.status == ClientStatus.active,
            )
            .length;
    final totalPipeline = newInquiries + followUps + negotiating;

    // Other Stats
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final lastMonthDate = DateTime(now.year, now.month - 1, 1);
    final lastMonth = lastMonthDate.month;
    final lastMonthYear = lastMonthDate.year;

    final slaCountdowns =
        myContracts
            .where(
              (c) => c.isGuaranteeActive && c.daysRemainingInGuarantee < 30,
            )
            .length;

    final currentMonthRevenue = myContracts
        .where(
          (c) =>
              c.placementDate.month == currentMonth &&
              c.placementDate.year == currentYear,
        )
        .fold<double>(0, (sum, c) => sum + c.amountPaid);

    final lastMonthRevenue = myContracts
        .where(
          (c) =>
              c.placementDate.month == lastMonth &&
              c.placementDate.year == lastMonthYear,
        )
        .fold<double>(0, (sum, c) => sum + c.amountPaid);

    final currentMonthClosed =
        myContracts
            .where(
              (c) =>
                  c.placementDate.month == currentMonth &&
                  c.placementDate.year == currentYear,
            )
            .length;

    final lastMonthClosed =
        myContracts
            .where(
              (c) =>
                  c.placementDate.month == lastMonth &&
                  c.placementDate.year == lastMonthYear,
            )
            .length;

    // Additional Stats calculations
    final currentMonthInquiries =
        myClients
            .where(
              (c) =>
                  c.inquiryDate.month == currentMonth &&
                  c.inquiryDate.year == currentYear,
            )
            .length;
    final lastMonthInquiries =
        myClients
            .where(
              (c) =>
                  c.inquiryDate.month == lastMonth &&
                  c.inquiryDate.year == lastMonthYear,
            )
            .length;

    final currentConversionRate =
        currentMonthInquiries > 0
            ? ((currentMonthClosed / currentMonthInquiries) * 100)
            : 0.0;
    final lastConversionRate =
        lastMonthInquiries > 0
            ? ((lastMonthClosed / lastMonthInquiries) * 100)
            : 0.0;

    final currentAvgDeal =
        currentMonthClosed > 0
            ? (currentMonthRevenue / currentMonthClosed)
            : 0.0;
    final lastAvgDeal =
        lastMonthClosed > 0 ? (lastMonthRevenue / lastMonthClosed) : 0.0;

    final followUpClients =
        myClients.where((c) => c.status == ClientStatus.followUp).toList()
          ..sort((a, b) => a.inquiryDate.compareTo(b.inquiryDate));

    final recentWins = List<ContractModel>.from(myContracts)
      ..sort((a, b) => b.placementDate.compareTo(a.placementDate));
    final topWins = recentWins.take(5).toList();

    // Top Categories
    final categoryCounts = <String, int>{};
    for (var client in myClients.where(
      (c) =>
          c.status == ClientStatus.converted || c.status == ClientStatus.active,
    )) {
      categoryCounts[client.preferredCandidateCategory] =
          (categoryCounts[client.preferredCandidateCategory] ?? 0) + 1;
    }
    final sortedCategories =
        categoryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(4).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Pipeline Visualization
            Text(
              'Sales Funnel Pipeline',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 12),
            Card(
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
                child:
                    isTablet
                        ? Row(
                          children: _buildPipelineSteps(
                            isDark,
                            true,
                            newInquiries,
                            followUps,
                            converted,
                            totalPipeline,
                          ),
                        )
                        : Column(
                          children: _buildPipelineSteps(
                            isDark,
                            false,
                            newInquiries,
                            followUps,
                            converted,
                            totalPipeline,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final isTablet = constraints.maxWidth > 600 && !isDesktop;

                final revenueCard = _buildStatCard(
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.gold,
                  title: 'Monthly Revenue',
                  value: '₹${_indianFormat.format(currentMonthRevenue)}',
                  isDark: isDark,
                  subtitle:
                      'Last month: ₹${_indianFormat.format(lastMonthRevenue)}',
                );

                final contractsCard = _buildStatCard(
                  icon: Icons.handshake_outlined,
                  iconColor: AppColors.successGreen,
                  title: 'Closed Contracts',
                  value: _indianFormat.format(currentMonthClosed),
                  isDark: isDark,
                  subtitle:
                      'Last month: ${_indianFormat.format(lastMonthClosed)}',
                );

                final slaCard = _buildStatCard(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.urgentAmber,
                  title: 'Expiring Contracts',
                  value: _indianFormat.format(slaCountdowns),
                  isDark: isDark,
                  subtitle: '< 1 month left',
                );

                final conversionCard = _buildStatCard(
                  icon: Icons.trending_up,
                  iconColor: AppColors.infoBlue,
                  title: 'Conversion Rate',
                  value: '${currentConversionRate.toStringAsFixed(1)}%',
                  isDark: isDark,
                  subtitle:
                      'Last month: ${lastConversionRate.toStringAsFixed(1)}%',
                );

                final avgDealCard = _buildStatCard(
                  icon: Icons.monetization_on_outlined,
                  iconColor: AppColors.successGreen,
                  title: 'Avg Deal Value',
                  value: '₹${_indianFormat.format(currentAvgDeal)}',
                  isDark: isDark,
                  subtitle: 'Last month: ₹${_indianFormat.format(lastAvgDeal)}',
                );

                if (isDesktop) {
                  return Row(
                    children: [
                      Expanded(child: revenueCard),
                      const SizedBox(width: 16),
                      Expanded(child: contractsCard),
                      const SizedBox(width: 16),
                      Expanded(child: conversionCard),
                      const SizedBox(width: 16),
                      Expanded(child: avgDealCard),
                    ],
                  );
                } else if (isTablet) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: revenueCard),
                          const SizedBox(width: 16),
                          Expanded(child: contractsCard),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: conversionCard),
                          const SizedBox(width: 16),
                          Expanded(child: avgDealCard),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      revenueCard,
                      const SizedBox(height: 16),
                      contractsCard,
                      const SizedBox(height: 16),
                      conversionCard,
                      const SizedBox(height: 16),
                      avgDealCard,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // Two Column Layout
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildFollowUpList(context, followUpClients, isDark),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildRecentWins(context, topWins, isDark),
                        const SizedBox(height: 24),
                        _buildTopCategories(context, topCategories, isDark),
                        const SizedBox(height: 24),
                        _buildUpcomingRenewals(context, myContracts, isDark),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildFollowUpList(context, followUpClients, isDark),
                  const SizedBox(height: 24),
                  _buildRecentWins(context, topWins, isDark),
                  const SizedBox(height: 24),
                  _buildTopCategories(context, topCategories, isDark),
                  const SizedBox(height: 24),
                  _buildUpcomingRenewals(context, myContracts, isDark),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPipelineSteps(
    bool isDark,
    bool isHorizontal,
    int newInquiries,
    int followUps,
    int converted,
    int totalPipeline,
  ) {
    final steps = [
      _PipelineStep(
        title: 'New Inquiries',
        count: newInquiries,
        total: totalPipeline,
        color: AppColors.standardBlue,
        icon: Icons.person_add_alt_1,
      ),
      _PipelineStep(
        title: 'Follow Up',
        count: followUps,
        total: totalPipeline,
        color: AppColors.urgentAmber,
        icon: Icons.phone_in_talk,
      ),
      _PipelineStep(
        title: 'Converted',
        count: converted,
        total:
            totalPipeline > 0
                ? totalPipeline
                : 1, // Avoid div/0 but keep logic simple
        color: AppColors.successGreen,
        icon: Icons.handshake,
      ),
    ];

    List<Widget> children = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      children.add(
        isHorizontal
            ? Expanded(child: _buildPipelineCard(step, isDark))
            : _buildPipelineCard(step, isDark),
      );

      if (i < steps.length - 1) {
        children.add(
          isHorizontal
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? AppColors.grey700 : AppColors.grey300,
                  size: 20,
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.arrow_downward,
                  color: isDark ? AppColors.grey700 : AppColors.grey300,
                  size: 20,
                ),
              ),
        );
      }
    }
    return children;
  }

  Widget _buildPipelineCard(_PipelineStep step, bool isDark) {
    final double percentage = step.total > 0 ? step.count / step.total : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: step.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(step.icon, color: step.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _indianFormat.format(step.count),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor:
                  isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(step.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    String? subtitle,
  }) {
    return Card(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey500 : AppColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRenewals(
    BuildContext context,
    List<ContractModel> myContracts,
    bool isDark,
  ) {
    final upcomingRenewals =
        myContracts.where((c) {
          if (c.contractStatus != ContractStatus.active) return false;
          final expiryDate = DateTime(
            c.placementDate.year,
            c.placementDate.month + 11,
            c.placementDate.day,
          );
          final daysToExpiry = expiryDate.difference(DateTime.now()).inDays;
          return daysToExpiry >= 0 && daysToExpiry <= 30;
        }).toList();

    if (upcomingRenewals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.event_busy,
              color: AppColors.urgentAmber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Renewals (30 Days)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.urgentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${upcomingRenewals.length}',
                style: const TextStyle(
                  color: AppColors.urgentAmber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingRenewals.length,
          itemBuilder: (context, index) {
            final contract = upcomingRenewals[index];
            final expiryDate = DateTime(
              contract.placementDate.year,
              contract.placementDate.month + 11,
              contract.placementDate.day,
            );
            final daysLeft = expiryDate.difference(DateTime.now()).inDays;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.urgentAmber.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.urgentAmber,
                    size: 20,
                  ),
                ),
                title: Text(
                  contract.clientName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Candidate: ${contract.candidateName} • Expires in $daysLeft days',
                ),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Follow Up'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowUpList(
    BuildContext context,
    List<ClientModel> followUps,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.phone_in_talk_outlined,
              color: AppColors.warningOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Actionable Follow-Ups',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (followUps.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.grey200,
              ),
            ),
            child: const Center(child: Text('No pending follow-ups!')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: followUps.length > 5 ? 5 : followUps.length,
            itemBuilder: (context, index) {
              final client = followUps[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
                color: isDark ? AppColors.darkSurface : AppColors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.warningOrange.withValues(
                      alpha: 0.1,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.warningOrange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    client.fullName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${client.preferredCandidateCategory} • ${client.budgetRange}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone_forwarded),
                    color: AppColors.successGreen,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentWins(
    BuildContext context,
    List<ContractModel> wins,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: AppColors.gold,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Wins',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (wins.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.grey200,
              ),
            ),
            child: const Center(child: Text('No recent wins yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wins.length,
            itemBuilder: (context, index) {
              final win = wins[index];
              final dateStr = DateFormat('MMM dd').format(win.placementDate);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
                color: isDark ? AppColors.darkSurface : AppColors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.successGreen.withValues(
                      alpha: 0.1,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    win.clientName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${win.candidateName} • $dateStr'),
                  trailing: Text(
                    '₹${NumberFormat('#,##,###').format(win.serviceFee)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopCategories(
    BuildContext context,
    List<MapEntry<String, int>> categories,
    bool isDark,
  ) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final maxCount = categories.isNotEmpty ? categories.first.value : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.pie_chart_outline,
              color: AppColors.infoBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Top Driving Categories',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
            ),
          ),
          child: Column(
            children:
                categories.map((entry) {
                  final double percentage = entry.value / maxCount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            Text(
                              '${entry.value} closed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey100,
                            color: AppColors.infoBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PipelineStep {
  final String title;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _PipelineStep({
    required this.title,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });
}
