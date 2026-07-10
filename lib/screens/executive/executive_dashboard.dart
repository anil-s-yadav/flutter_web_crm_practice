import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:google_fonts/google_fonts.dart';

class ExecutiveDashboard extends StatelessWidget {
  const ExecutiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = MockDataGenerator.getExecutiveStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            "Drop Metrics",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              _MetricCard(
                title: "Today's Status",
                value: "${stats['todaysPendingDrops']} Pending",
                subtitle: "Out of ${stats['todaysAssignedDrops']} assigned",
                icon: Icons.assignment_late,
                color: AppColors.urgentAmber,
              ),
              _MetricCard(
                title: 'This Week',
                value: '${stats['dropsThisWeek']}',
                subtitle: 'Drops completed',
                icon: Icons.view_week,
                color: AppColors.gold,
              ),
              _MetricCard(
                title: 'Last Week',
                value: '${stats['dropsLastWeek']}',
                subtitle: 'Drops completed',
                icon: Icons.history,
                color: AppColors.grey500,
              ),
              _MetricCard(
                title: 'This Month',
                value: '${stats['dropsThisMonth']}',
                subtitle: 'Drops completed',
                icon: Icons.calendar_today,
                color: AppColors.gold,
              ),
              _MetricCard(
                title: 'Last Month',
                value: '${stats['dropsLastMonth']}',
                subtitle: 'Drops completed',
                icon: Icons.date_range,
                color: AppColors.grey500,
              ),
              _MetricCard(
                title: 'Total Drops',
                value: '${stats['totalDrops']}',
                subtitle: 'Overall drops',
                icon: Icons.done_all,
                color: AppColors.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              icon,
              size: 70,
              color: color.withValues(alpha: isDark ? 0.1 : 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
