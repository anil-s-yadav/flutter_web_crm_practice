import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/core/pagination.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

import 'package:go_router/go_router.dart';

class SourcingDashboard extends StatefulWidget {
  const SourcingDashboard({super.key});

  @override
  State<SourcingDashboard> createState() => _SourcingDashboardState();
}

class _SourcingDashboardState extends State<SourcingDashboard> {
  final _stats = MockDataGenerator.getSourcingStats();
  late final List<CandidateModel> _recentCandidates;
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void initState() {
    super.initState();
    final result = MockDataGenerator.getCandidates(
      const PaginationParams(pageSize: 5),
    );
    _recentCandidates = result.items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isDesktop = width > 1100;
    final isTablet = width > 700;

    final totalPipeline =
        (_stats['newlyAdded'] as int) +
        (_stats['verificationPending'] as int) +
        (_stats['medicalPending'] as int);

    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.go('/sourcing/add_candidate'),
      //   backgroundColor: AppColors.navyBlue,
      //   foregroundColor: AppColors.white,
      //   icon: const Icon(Icons.person_add),
      //   label: Text(
      //     'Add Candidate',
      //     style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pipeline visualization
            Text(
              'Verification Pipeline',
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
                        ? Row(children: _buildPipelineSteps(isDark, true))
                        : Column(children: _buildPipelineSteps(isDark, false)),
              ),
            ),
            const SizedBox(height: 24),

            // Stat cards
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    constraints.maxWidth > 1200
                        ? 5
                        : constraints.maxWidth > 900
                        ? 3
                        : constraints.maxWidth > 600
                        ? 2
                        : 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Sourcing Goal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildStatCard(
                        icon: Icons.person_add_alt_1,
                        iconColor: AppColors.stageMedicalCheck,
                        title: 'Added This Month',
                        value: _indianFormat.format(
                          _stats['addedThisMonth'] as int,
                        ),
                        isDark: isDark,
                        progress:
                            (_stats['addedThisMonth'] as int) /
                            (_stats['targetThisMonth'] as int),
                        progressText:
                            '${_indianFormat.format(_stats['addedThisMonth'] as int)} / ${_indianFormat.format(_stats['targetThisMonth'] as int)} Goal',
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 135,
                      ),
                      children: [
                        _buildStatCard(
                          icon: Icons.person_add,
                          iconColor: AppColors.successGreen,
                          title: 'Added Last Month',
                          value: _indianFormat.format(
                            _stats['addedLastMonth'] as int,
                          ),
                          isDark: isDark,
                        ),
                        _buildStatCard(
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.stageVerified,
                          title: 'Ready (No Medical)',
                          value: _indianFormat.format(
                            _stats['readyToPlaceNoMedical'] as int,
                          ),
                          isDark: isDark,
                        ),
                        _buildStatCard(
                          icon: Icons.medical_services,
                          iconColor: AppColors.successGreen,
                          title: 'Ready (Medical Verified)',
                          value: _indianFormat.format(
                            _stats['readyToPlaceMedical'] as int,
                          ),
                          isDark: isDark,
                        ),
                        _buildStatCard(
                          icon: Icons.people_outline,
                          iconColor: AppColors.navyBlue,
                          title: 'Total Candidates',
                          value: _indianFormat.format(
                            _stats['totalCandidates'] as int,
                          ),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPipelineSteps(bool isDark, bool isHorizontal) {
    final steps = [
      _PipelineStep(
        'Newly Added',
        _stats['newlyAdded'] as int,
        AppColors.stageInterviewed,
        Icons.person_add,
        '/sourcing/candidates/new',
      ),
      _PipelineStep(
        'Verification Pending',
        _stats['verificationPending'] as int,
        AppColors.stagePoliceVerification,
        Icons.fact_check,
        '/sourcing/candidates/verification',
      ),
      _PipelineStep(
        'Medical Pending',
        _stats['medicalPending'] as int,
        AppColors.stageMedicalCheck,
        Icons.medical_services,
        '/sourcing/candidates/medical',
      ),
      _PipelineStep(
        'Ready to Place',
        _stats['readyToPlace'] as int,
        AppColors.stageVerified,
        Icons.verified,
        '/sourcing/candidates/ready',
      ),
    ];

    final widgets = <Widget>[];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      widgets.add(
        isHorizontal
            ? Expanded(child: _buildPipelineCard(step, isDark))
            : _buildPipelineCard(step, isDark),
      );
      if (i < steps.length - 1) {
        widgets.add(
          isHorizontal
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: isDark ? AppColors.grey500 : AppColors.grey400,
                ),
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: isDark ? AppColors.grey500 : AppColors.grey400,
                  ),
                ),
              ),
        );
      }
    }
    return widgets;
  }

  Widget _buildPipelineCard(_PipelineStep step, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(step.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: step.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: step.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(step.icon, size: 28, color: step.color),
              const SizedBox(height: 8),
              Text(
                _indianFormat.format(step.count),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
    required bool isDark,
    double? progress,
    String? progressText,
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
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
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                borderRadius: BorderRadius.circular(4),
              ),
              if (progressText != null) ...[
                const SizedBox(height: 4),
                Text(
                  progressText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _candidateStatusColor(CandidateStatus status) {
    switch (status) {
      case CandidateStatus.newlyAdded:
        return AppColors.statusInterviewed;
      case CandidateStatus.verificationPending:
        return AppColors.stagePoliceVerification;
      case CandidateStatus.medicalPending:
        return AppColors.stageMedicalCheck;
      case CandidateStatus.readyToPlace:
        return AppColors.statusVerified;
      case CandidateStatus.placed:
        return AppColors.statusPlaced;
      case CandidateStatus.blacklisted:
        return AppColors.statusBlacklisted;
      case CandidateStatus.renewalPending:
        // TODO: Handle this case.
        throw UnimplementedError();
      case CandidateStatus.jobLeft:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _PipelineStep {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final String route;

  const _PipelineStep(
    this.label,
    this.count,
    this.color,
    this.icon,
    this.route,
  );
}
