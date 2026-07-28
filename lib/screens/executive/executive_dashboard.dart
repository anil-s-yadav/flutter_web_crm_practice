import 'package:flutter/material.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/dashboard/dashboard_bloc.dart';
import 'package:practice_app/blocs/dashboard/dashboard_event.dart';
import 'package:practice_app/blocs/dashboard/dashboard_state.dart';

class ExecutiveDashboard extends StatefulWidget {
  const ExecutiveDashboard({super.key});

  @override
  State<ExecutiveDashboard> createState() => _ExecutiveDashboardState();
}

class _ExecutiveDashboardState extends State<ExecutiveDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadExecutiveDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        if (dashboardState is DashboardLoading || dashboardState is DashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (dashboardState is DashboardError) {
          return Center(child: Text('Error: ${dashboardState.message}'));
        }

        final data = (dashboardState as DashboardLoaded).data;
        
        final pendingTasks = data['pendingTasks'] ?? 0;
        final inProgressTasks = data['tasks']?['inProgress'] ?? 0;
        final completedToday = data['tasks']?['completedToday'] ?? 0;
        final followUps = data['clients']?['followUps'] ?? 0;
        final escalated = data['clients']?['escalated'] ?? 0;
        final activeClients = data['activeClients'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 2;
        double aspect = 1.1;

        if (constraints.maxWidth >= 1200) {
          columns = 4;
          aspect = 1.6;
        } else if (constraints.maxWidth >= 900) {
          columns = 3;
          aspect = 1.4;
        } else if (constraints.maxWidth >= 600) {
          columns = 3;
          aspect = 1.2;
        }

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
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: aspect,
                children: [
              _MetricCard(
                title: "Pending Tasks",
                value: "$pendingTasks",
                subtitle: "Tasks to do",
                icon: Icons.assignment_late,
                color: AppColors.urgentAmber,
              ),
              _MetricCard(
                title: 'In Progress',
                value: '$inProgressTasks',
                subtitle: 'Currently working',
                icon: Icons.view_week,
                color: AppColors.infoBlue,
              ),
              _MetricCard(
                title: 'Completed Today',
                value: '$completedToday',
                subtitle: 'Finished tasks',
                icon: Icons.history,
                color: AppColors.successGreen,
              ),
              _MetricCard(
                title: 'Client Follow-ups',
                value: '$followUps',
                subtitle: 'Needs attention',
                icon: Icons.calendar_today,
                color: AppColors.warningOrange,
              ),
              _MetricCard(
                title: 'Escalated Issues',
                value: '$escalated',
                subtitle: 'High priority',
                icon: Icons.date_range,
                color: AppColors.criticalRed,
              ),
              _MetricCard(
                title: 'Active Clients',
                value: '$activeClients',
                subtitle: 'Total managing',
                icon: Icons.done_all,
                color: AppColors.gold,
              ),
            ],
          ),
        ],
      ),
    );
    },
    );
      },
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
                  color:
                      isDark
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
