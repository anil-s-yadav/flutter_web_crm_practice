import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/core/pagination.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _stats = MockDataGenerator.getAdminStats();
  late final List<TicketModel> _recentTickets;
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void initState() {
    super.initState();
    final result = MockDataGenerator.getTickets(
      const PaginationParams(pageSize: 5)
    );
    _recentTickets = result.items;
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)} L';
    }
    return '₹${_indianFormat.format(value.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isDesktop = width > 1100;
    final isTablet = width > 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main stat cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.account_balance_wallet,
                iconColor: AppColors.gold,
                title: 'Total Revenue',
                value: _formatCurrency(_stats['totalRevenue'] as double),
                subtitle: 'This Financial Year',
                width: _cardWidth(width, isDesktop, isTablet),
                isDark: isDark
              ),
              _buildStatCard(
                icon: Icons.people,
                iconColor: AppColors.successGreen,
                title: 'Active Placements',
                value: _indianFormat.format(_stats['activePlacements'] as int),
                subtitle: 'Currently Placed',
                width: _cardWidth(width, isDesktop, isTablet),
                isDark: isDark
              ),
              _buildStatCard(
                icon: Icons.trending_down,
                iconColor: AppColors.urgentAmber,
                title: 'Candidate Attrition Rate',
                value: '${_stats['attritionRate']}%',
                subtitle: 'Last 90 Days',
                width: _cardWidth(width, isDesktop, isTablet),
                isDark: isDark
              ),
              _buildStatCard(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.criticalRed,
                title: 'Urgent Tickets',
                value: _indianFormat.format(_stats['urgentTickets'] as int),
                subtitle: 'Requires Attention',
                width: _cardWidth(width, isDesktop, isTablet),
                isDark: isDark
              ),
            ]
          ),
          const SizedBox(height: 24),

          // Quick stats row
          Text(
            'Quick Stats',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue
            )
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMiniStat(
                'Total Candidates',
                _indianFormat.format(_stats['totalCandidates'] as int),
                Icons.people_outline,
                AppColors.stageInterviewed,
                isDark
              ),
              _buildMiniStat(
                'Total Clients',
                _indianFormat.format(_stats['totalClients'] as int),
                Icons.business_outlined,
                AppColors.gold,
                isDark
              ),
              _buildMiniStat(
                'Open Tickets',
                _indianFormat.format(_stats['openTickets'] as int),
                Icons.confirmation_number_outlined,
                AppColors.urgentAmber,
                isDark
              ),
              InkWell(
                onTap: () => context.go('/admin/audit'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.3))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 20, color: AppColors.navyBlue),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Global Logs', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.grey400 : AppColors.grey600)),
                          Text('View Audit Trail', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
                        ]
                      )
                    ]
                  )
                )
              )
            ]
          ),
          const SizedBox(height: 24),

          // Recent Tickets
          Text(
            'Recent Tickets',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue
            )
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey200
              )
            ),
            color: isDark ? AppColors.darkSurface : AppColors.white,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTickets.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.grey200
              ),
              itemBuilder: (context, index) {
                final ticket = _recentTickets[index];
                return _buildTicketTile(ticket, isDark);
              }
            )
          ),
        ]
      )
    );
  }

  double _cardWidth(double screenWidth, bool isDesktop, bool isTablet) {
    if (isDesktop) return (screenWidth - 240 - 48 - 48) / 4;
    if (isTablet) return (screenWidth - 48 - 16) / 2;
    return screenWidth - 32;
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required double width,
    required bool isDark
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200
          )
        ),
        color: isDark ? AppColors.darkSurface : AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Icon(icon, size: 22, color: iconColor)
                  ),
                  const Spacer(),
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: AppColors.successGreen
                  ),
                ]
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600
                )
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.navyBlue
                )
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.grey500 : AppColors.grey600
                )
              ),
            ]
          )
        )
      )
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600
                )
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.navyBlue
                )
              ),
            ]
          ),
        ]
      )
    );
  }

  Widget _buildTicketTile(TicketModel ticket, bool isDark) {
    Color priorityColor;
    switch (ticket.priority) {
      case TicketPriority.critical:
        priorityColor = AppColors.criticalRed;
        break;
      case TicketPriority.urgent:
        priorityColor = AppColors.urgentAmber;
        break;
      case TicketPriority.standard:
        priorityColor = AppColors.standardBlue;
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          color: priorityColor,
          borderRadius: BorderRadius.circular(2)
        )
      ),
      title: Text(
        ticket.title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.white : AppColors.textPrimaryLight
        )
      ),
      subtitle: Text(
        '${ticket.clientName} • ${ticket.priority.displayName}',
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: isDark ? AppColors.grey500 : AppColors.grey600
        )
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: priorityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Text(
          ticket.status.displayName,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: priorityColor
          )
        )
      )
    );
  }
}
