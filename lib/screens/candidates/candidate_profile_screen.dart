import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/blocs/contract/contract_bloc.dart';
import 'package:practice_app/blocs/contract/contract_state.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/audit_log/audit_log_bloc.dart';
import 'package:practice_app/widgets/candidate_avatar.dart';
import 'package:practice_app/utils/image_picker_helper.dart';
import 'package:practice_app/core/default_doc_urls.dart';
import 'package:practice_app/widgets/candidate_promotion_helper.dart';

class CandidateProfileScreen extends StatelessWidget {
  final String candidateId;

  const CandidateProfileScreen({super.key, required this.candidateId});

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
      case CandidateStatus.pendingDrop:
        return AppColors.urgentAmber;
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

  int _pipelineProgress(CandidateStatus status) {
    switch (status) {
      case CandidateStatus.newlyAdded:
        return 1;
      case CandidateStatus.verificationPending:
        return 2;
      case CandidateStatus.medicalPending:
        return 3;
      case CandidateStatus.readyToPlace:
      case CandidateStatus.pendingDrop:
        return 4;
      case CandidateStatus.placed:
        return 5;
      case CandidateStatus.blacklisted:
        return 0;
      case CandidateStatus.renewalPending:
        throw UnimplementedError();
      case CandidateStatus.jobLeft:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = context.media.width;
    final isMobile = width < 800;
    final isTablet = width >= 800 && width <= 1100;

    return BlocBuilder<CandidateBloc, CandidateState>(
      builder: (context, candidateState) {
        if (candidateState is CandidateLoading ||
            candidateState is CandidateInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (candidateState is CandidateError) {
          return Scaffold(
            body: Center(child: Text('Error: ${candidateState.message}')),
          );
        }

        final candidates = (candidateState as CandidateLoaded).candidates;
        final candidateIndex = candidates.indexWhere(
          (c) => c.id == candidateId,
        );
        if (candidateIndex == -1) {
          return const Scaffold(
            body: Center(child: Text('Candidate not found')),
          );
        }
        final candidate = candidates[candidateIndex];

        final auditState = context.watch<AuditLogBloc>().state;
        final relevantLogs =
            auditState is AuditLogLoaded
                ? auditState.auditLogs
                    .where((l) => l.targetId == candidate.id)
                    .toList()
                : <AuditLogModel>[];

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (!isMobile) ...[
                //   Row(
                //     children: [
                //       TextButton.icon(
                //         onPressed: () => context.pop(),
                //         icon: const Icon(Icons.arrow_back_ios, size: 18),
                //         label: Text('Go Back', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                //         style: TextButton.styleFrom(foregroundColor: isDark ? AppColors.white : AppColors.navyBlue),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 16),
                // ],
                if (isMobile)
                  _buildMobileLayout(context, candidate, isDark, relevantLogs)
                else if (isTablet)
                  _buildTabletLayout(context, candidate, isDark, relevantLogs)
                else
                  _buildDesktopLayout(context, candidate, isDark, relevantLogs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CandidateModel candidate,

    bool isDark,
    List<dynamic> relevantLogs,
  ) {
    return Column(
      children: [
        _buildProfileHeader(context, candidate, isDark),
        const SizedBox(height: 16),
        _buildTopActions(context, candidate),
        const SizedBox(height: 24),
        if (candidate.status == CandidateStatus.placed)
          _buildplacedDashboard(context, candidate, isDark)
        else
          _buildPipelineIndicator(candidate, isDark),
        const SizedBox(height: 24),
        _buildPersonalDetails(candidate, isDark),
        const SizedBox(height: 16),
        _buildVerificationStatus(context, candidate, isDark),
        const SizedBox(height: 16),
        _buildDocuments(context, candidate, isDark),
        const SizedBox(height: 16),
        if (candidate.currentPlacementId != null)
          _buildCurrentPlacement(candidate, isDark),
        if (candidate.remarks != null) ...[
          const SizedBox(height: 16),
          _buildRemarks(candidate, isDark),
        ],
        const SizedBox(height: 32),
        AuditLogWidget(
          logs: relevantLogs.cast(),
          title: 'Candidate Activity History',
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    CandidateModel candidate,

    bool isDark,
    List<dynamic> relevantLogs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileHeader(context, candidate, isDark),
        const SizedBox(height: 16),
        _buildTopActions(context, candidate),
        const SizedBox(height: 24),
        if (candidate.status == CandidateStatus.placed)
          _buildplacedDashboard(context, candidate, isDark)
        else
          _buildPipelineIndicator(candidate, isDark),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPersonalDetails(candidate, isDark)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVerificationStatus(context, candidate, isDark),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDocuments(context, candidate, isDark),
        const SizedBox(height: 16),
        if (candidate.currentPlacementId != null)
          _buildCurrentPlacement(candidate, isDark),
        if (candidate.remarks != null) ...[
          const SizedBox(height: 16),
          _buildRemarks(candidate, isDark),
        ],
        const SizedBox(height: 32),
        AuditLogWidget(
          logs: relevantLogs.cast(),
          title: 'Candidate Activity History',
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CandidateModel candidate,

    bool isDark,
    List<dynamic> relevantLogs,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, candidate, isDark),
              const SizedBox(height: 16),
              _buildTopActions(context, candidate),
              const SizedBox(height: 16),
              _buildPersonalDetails(candidate, isDark),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (candidate.status == CandidateStatus.placed)
                _buildplacedDashboard(context, candidate, isDark)
              else
                _buildPipelineIndicator(candidate, isDark),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildVerificationStatus(context, candidate, isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDocuments(context, candidate, isDark)),
                ],
              ),
              const SizedBox(height: 24),
              if (candidate.currentPlacementId != null) ...[
                _buildCurrentPlacement(candidate, isDark),
                const SizedBox(height: 24),
              ],
              if (candidate.remarks != null) ...[
                _buildRemarks(candidate, isDark),
                const SizedBox(height: 24),
              ],
              AuditLogWidget(
                logs: relevantLogs.cast(),
                title: 'Candidate Activity History',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopActions(BuildContext context, CandidateModel candidate) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final text =
                'Hello, here is a candidate profile from Verified Maids:\n\n'
                'View Photo: ${candidate.photoUrl}\n\n'
                'Name: ${candidate.fullName.split(' ').first} (ID: ${candidate.id})\n'
                'Work profile: ${candidate.category == 'Candidate' ? (candidate.preferredWorkType ?? 'Maid') : candidate.category}\n'
                'Expected Salary: ${candidate.expectedSalary}\n'
                'Age: ${candidate.age} | Experience: ${candidate.experienceYears} Years\n'
                'Religion: ${candidate.religion}\n'
                'Languages: ${candidate.languages.join(', ')}\n'
                'Location: ${candidate.city}\n\n'
                'Please let us know if you are interested in scheduling an interview.';
            final url = Uri.parse(
              'https://wa.me/?text=${Uri.encodeComponent(text)}',
            );
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open WhatsApp.')),
              );
            }
          },
          icon: const Icon(Icons.share, size: 16),
          label: Text(
            'Share Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyBlue,
            elevation: 0,
            side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
          ),
        ),

        if (candidate.status == CandidateStatus.newlyAdded)
          ElevatedButton.icon(
            onPressed: () {
              context.push('/sourcing/candidates/${candidate.id}/edit');
            },
            icon: const Icon(Icons.edit, size: 16),
            label: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.navyBlue,
              elevation: 0,
              side: BorderSide(
                color: AppColors.navyBlue.withValues(alpha: 0.2),
              ),
            ),
          ),
        if (candidate.status == CandidateStatus.verificationPending)
          ElevatedButton.icon(
            onPressed: () {
              CandidatePromotionHelper.rollbackToNewlyAdded(context, candidate);
            },
            icon: const Icon(Icons.undo, size: 16),
            label: Text(
              'Rollback to Newly Added',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.urgentAmber,
              elevation: 0,
              side: BorderSide(
                color: AppColors.urgentAmber.withValues(alpha: 0.4),
              ),
            ),
          ),
        if (candidate.status != CandidateStatus.placed &&
            candidate.status != CandidateStatus.blacklisted &&
            candidate.status != CandidateStatus.readyToPlace)
          PopupMenuButton<VoidCallback>(
            tooltip: 'Promote Candidate',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: AppColors.navyBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Promote',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: AppColors.navyBlue,
                  ),
                ],
              ),
            ),
            onSelected: (action) => action(),
            itemBuilder: (context) {
              return [
                if (candidate.status == CandidateStatus.newlyAdded)
                  PopupMenuItem(
                    value:
                        () => CandidatePromotionHelper.promoteToVerification(
                          context,
                          candidate,
                        ),
                    child: const Text('Move to Verification'),
                  ),
                if (candidate.status ==
                    CandidateStatus.verificationPending) ...[
                  PopupMenuItem(
                    value:
                        () => CandidatePromotionHelper.rollbackToNewlyAdded(
                          context,
                          candidate,
                        ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.undo,
                          size: 16,
                          color: AppColors.urgentAmber,
                        ),
                        SizedBox(width: 8),
                        Text('Rollback to Newly Added'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value:
                        () => CandidatePromotionHelper.promoteToMedical(
                          context,
                          candidate,
                        ),
                    child: const Text('Promote to Medical Test'),
                  ),
                  PopupMenuItem(
                    value:
                        () => CandidatePromotionHelper.promoteToReadyToPlace(
                          context,
                          candidate,
                          skipMedical: true,
                        ),
                    child: const Text(
                      'Promote to Ready to Hire (Skip Medical)',
                    ),
                  ),
                ],
                if (candidate.status == CandidateStatus.medicalPending)
                  PopupMenuItem(
                    value:
                        () => CandidatePromotionHelper.promoteToReadyToPlace(
                          context,
                          candidate,
                        ),
                    child: const Text('Promote to Ready to Hire'),
                  ),
              ];
            },
          ),
        if (candidate.status != CandidateStatus.blacklisted &&
            candidate.status != CandidateStatus.placed)
          ElevatedButton.icon(
            onPressed: () {
              _showBlacklistDialog(context, candidate);
            },
            icon: const Icon(Icons.block, size: 16),
            label: Text(
              'Blacklist',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.criticalRed,
              elevation: 0,
              side: BorderSide(
                color: AppColors.criticalRed.withValues(alpha: 0.2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildplacedDashboard(
    BuildContext context,
    CandidateModel candidate,
    bool isDark,
  ) {
    final contractState = context.read<ContractBloc>().state;
    final allContracts =
        contractState is ContractLoaded
            ? contractState.contracts
            : <ContractModel>[];
    ContractModel? contract;
    try {
      contract = allContracts.firstWhere(
        (c) => c.id == candidate.currentPlacementId,
      );
    } catch (_) {}

    ClientModel? client;
    if (contract != null) {
      final clientState = context.read<ClientBloc>().state;
      final allClients =
          clientState is ClientLoaded ? clientState.clients : <ClientModel>[];
      try {
        client = allClients.firstWhere((c) => c.id == contract!.clientId);
      } catch (_) {}
    }

    if (contract == null || client == null) return const SizedBox.shrink();

    final clientContracts =
        allContracts.where((c) => c.clientId == client!.id).toList()
          ..sort((a, b) => a.placementDate.compareTo(b.placementDate));

    final contractIndex = clientContracts.indexWhere(
      (c) => c.id == contract!.id,
    );
    final placementNumber = contractIndex >= 0 ? contractIndex + 1 : 1;

    String placementLabel;
    if (placementNumber <= 1) {
      placementLabel = 'Primary (1st Candidate)';
    } else {
      final suffix =
          (placementNumber % 10 == 2 && placementNumber != 12)
              ? 'nd'
              : (placementNumber % 10 == 3 && placementNumber != 13)
              ? 'rd'
              : 'th';
      placementLabel =
          'Replacement #${placementNumber - 1} ($placementNumber$suffix)';
    }

    final format = NumberFormat('#,##,###', 'en_IN');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.successGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_history, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active Placement Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Downloading signed contract...'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Signed Contract',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.goldLight : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDashboardCard(
                'Customer',
                '${client.fullName}\nID: ${client.id}\nPh: ${client.phone}',
                Icons.person,
                isDark,
                width: 220,
              ),
              _buildDashboardCard(
                'Placement Info',
                placementLabel,
                Icons.published_with_changes,
                isDark,
                width: 200,
              ),
              _buildDashboardCard(
                'Contract Date',
                DateFormat('dd MMM yyyy').format(contract.placementDate),
                Icons.calendar_today,
                isDark,
              ),
              _buildDashboardCard(
                'Contract Length',
                _getContractLength(
                  contract.placementDate,
                  contract.guaranteeEndDate,
                ),
                Icons.timer,
                isDark,
              ),
              _buildDashboardCard(
                'Guarantee Until',
                DateFormat('dd MMM yyyy').format(contract.guaranteeEndDate),
                Icons.security,
                isDark,
              ),
              _buildDashboardCard(
                'Contract Expiry',
                DateFormat('dd MMM yyyy').format(
                  DateTime(
                    contract.placementDate.year,
                    contract.placementDate.month + 11,
                    contract.placementDate.day,
                  ),
                ),
                Icons.event_busy,
                isDark,
              ),
              _buildDashboardCard(
                'Salary / Fee',
                '₹${format.format(contract.serviceFee)}',
                Icons.payments,
                isDark,
              ),
              _buildDashboardCard(
                'Work Location',
                '${client.locality}, ${client.city}',
                Icons.location_on,
                isDark,
              ),
              _buildDashboardCard(
                'Working Hours',
                '${candidate.workingHoursPerDay} hrs/day',
                Icons.access_time,
                isDark,
              ),
              _buildDashboardCard(
                'Role',
                candidate.category,
                Icons.work,
                isDark,
              ),
              _buildDashboardCard(
                'House Details',
                '${client.houseType} (${client.familySize} Members)',
                Icons.home,
                isDark,
              ),
              _buildDashboardCard(
                'Contract Status',
                contract.contractStatus.name.toUpperCase(),
                Icons.assignment,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    bool isDark, {
    double width = 160,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.grey500),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _getContractLength(DateTime start, DateTime end) {
    final diffDays = end.difference(start).inDays;
    if (diffDays <= 100) return '3 Months';
    if (diffDays <= 200) return '6 Months';
    if (diffDays <= 370) return '1 Year';
    return '${(diffDays / 30).round()} Months';
  }

  Widget _buildProfileHeader(
    BuildContext context,
    CandidateModel candidate,
    bool isDark,
  ) {
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
          children: [
            CandidateAvatar(
              photoUrl: candidate.photoUrl,
              name: candidate.fullName,
              radius: 36,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildBadge(candidate.category, AppColors.gold),
                      _buildBadge(
                        candidate.status.displayName,
                        _candidateStatusColor(candidate.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID: ${candidate.id} • ${candidate.city} • ${candidate.experienceYears} yrs experience',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineIndicator(CandidateModel candidate, bool isDark) {
    final progress = _pipelineProgress(candidate.status);
    final steps = ['New', 'Verification', 'Medical', 'Ready'];
    final colors = [
      AppColors.stageInterviewed,
      AppColors.stagePoliceVerification,
      AppColors.stageMedicalCheck,
      AppColors.stageVerified,
    ];
    final dates = [
      candidate.dateAdded,
      candidate.dateVerificationSent,
      candidate.dateMedicalSent,
      candidate.dateReadyToHire,
    ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pipeline Progress',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(steps.length, (stepIndex) {
                final isComplete = stepIndex < progress - 1 || progress >= 4;
                final isActive = stepIndex == progress - 1 && progress < 4;
                bool isSkipped = false;

                // If past Medical (progress > 3) and medical not cleared, it was skipped
                if (stepIndex == 2 &&
                    progress > 3 &&
                    !candidate.isMedicalCleared) {
                  isSkipped = true;
                }

                final effectiveComplete = isSkipped ? false : isComplete;
                final effectiveActive = isSkipped ? false : isActive;

                return Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Horizontal connector lines passing through vertical center of node
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color:
                                        stepIndex == 0
                                            ? Colors.transparent
                                            : (progress > stepIndex
                                                ? colors[stepIndex - 1]
                                                : (isDark
                                                    ? AppColors.grey700
                                                    : AppColors.grey300)),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    color:
                                        stepIndex == steps.length - 1
                                            ? Colors.transparent
                                            : (progress > stepIndex + 1
                                                ? colors[stepIndex]
                                                : (isDark
                                                    ? AppColors.grey700
                                                    : AppColors.grey300)),
                                  ),
                                ),
                              ],
                            ),
                            // Circle step node
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isSkipped
                                        ? (isDark
                                            ? AppColors.grey700
                                            : AppColors.grey200)
                                        : ((effectiveComplete ||
                                                effectiveActive)
                                            ? colors[stepIndex]
                                            : (isDark
                                                ? AppColors.grey700
                                                : AppColors.grey300)),
                                border:
                                    isSkipped
                                        ? Border.all(
                                          color: AppColors.grey400,
                                          width: 2,
                                        )
                                        : (effectiveActive
                                            ? Border.all(
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : AppColors.navyBlue,
                                              width: 2,
                                            )
                                            : null),
                              ),
                              child: Icon(
                                isSkipped
                                    ? Icons.double_arrow
                                    : (effectiveComplete
                                        ? Icons.check
                                        : (effectiveActive
                                            ? Icons.hourglass_empty
                                            : Icons.circle)),
                                size:
                                    isSkipped
                                        ? 16
                                        : (effectiveComplete
                                            ? 18
                                            : (effectiveActive ? 16 : 8)),
                                color:
                                    isSkipped
                                        ? AppColors.grey500
                                        : AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSkipped ? 'Skipped' : steps[stepIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight:
                              (effectiveComplete ||
                                      effectiveActive ||
                                      isSkipped)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          color:
                              isSkipped
                                  ? AppColors.grey500
                                  : ((effectiveComplete || effectiveActive)
                                      ? colors[stepIndex]
                                      : (isDark
                                          ? AppColors.grey500
                                          : AppColors.grey600)),
                        ),
                      ),
                      if (dates[stepIndex] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(dates[stepIndex]!),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color:
                                isDark ? AppColors.grey500 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(CandidateModel candidate, bool isDark) {
    return _buildSection('Personal Details', isDark, [
      _infoRow('Age', '${candidate.age} years', isDark),
      _infoRow('Phone', candidate.phone, isDark),
      if (candidate.altPhone != null)
        _infoRow('Alt Phone', candidate.altPhone!, isDark),
      _infoRow('Address', candidate.address, isDark),
      _infoRow('City', '${candidate.city}, ${candidate.state}', isDark),
      _infoRow('Religion', candidate.religion, isDark),
      _infoRow('Education', candidate.education, isDark),
      _infoRow('Expected Salary', candidate.formattedExpectedSalary, isDark),
      _infoRow(
        'Working Hours',
        '${candidate.workingHoursPerDay} hrs/day',
        isDark,
      ),
      if (candidate.preferredWorkType != null)
        _infoRow('Pref. Work Type', candidate.preferredWorkType!, isDark),
      if (candidate.languages.isNotEmpty)
        _infoRow('Languages', candidate.languages.join(', '), isDark),
      if (candidate.sourcedById != null && candidate.sourcedById!.isNotEmpty)
        _infoRow(
          'Sourced By',
          (candidate.sourcedByName != null &&
                  candidate.sourcedByName!.isNotEmpty)
              ? '${candidate.sourcedById} (${candidate.sourcedByName})'
              : candidate.sourcedById!,
          isDark,
        ),
      _infoRow(
        'Date Added',
        DateFormat('dd MMM yyyy').format(candidate.dateAdded),
        isDark,
      ),
      _infoRow('Lead Source', candidate.source, isDark),
    ]);
  }

  Future<void> _handleUploadDocument(
    BuildContext context,
    CandidateModel candidate,
    String docType,
  ) async {
    try {
      final picked = await pickImageData();
      if (picked != null) {
        CandidateModel updated;
        if (docType == 'Aadhaar Card') {
          updated = candidate.copyWith(
            aadhaarDocUrl: DefaultDocUrls.sanitizeDocUrl(
              picked.base64DataUrl,
              'Aadhaar',
            ),
          );
        } else if (docType == 'PAN Card') {
          updated = candidate.copyWith(
            panDocUrl: DefaultDocUrls.sanitizeDocUrl(
              picked.base64DataUrl,
              'PAN',
            ),
          );
        } else if (docType == 'Passport') {
          updated = candidate.copyWith(
            passportDocUrl: DefaultDocUrls.sanitizeDocUrl(
              picked.base64DataUrl,
              'Passport',
            ),
          );
        } else if (docType == 'Police Verification') {
          updated = candidate.copyWith(
            policeVerificationDocUrl: DefaultDocUrls.sanitizeDocUrl(
              picked.base64DataUrl,
              'Police',
            ),
            isPoliceVerified: true,
          );
        } else if (docType == 'Medical Clearance') {
          updated = candidate.copyWith(
            medicalClearanceDocUrl: DefaultDocUrls.sanitizeDocUrl(
              picked.base64DataUrl,
              'Medical',
            ),
            isMedicalCleared: true,
          );
        } else {
          return;
        }

        if (context.mounted) {
          context.read<CandidateBloc>().add(UpdateCandidate(updated));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$docType uploaded successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: AppColors.criticalRed,
          ),
        );
      }
    }
  }

  Widget _buildVerificationStatus(
    BuildContext context,
    CandidateModel candidate,
    bool isDark,
  ) {
    final hasPoliceDoc = CandidatePromotionHelper.hasDoc(
      candidate.policeVerificationDocUrl,
    );
    final hasMedicalDoc = CandidatePromotionHelper.hasDoc(
      candidate.medicalClearanceDocUrl,
    );
    final isPoliceVerified = candidate.isPoliceVerified || hasPoliceDoc;
    final isMedicalCleared = candidate.isMedicalCleared || hasMedicalDoc;

    return _buildSection('Verification Hub', isDark, [
      _verificationItem(
        context: context,
        label: 'Police Verification',
        isVerified: isPoliceVerified,
        isDark: isDark,
      ),
      _verificationItem(
        context: context,
        label: 'Medical Clearance',
        isVerified: isMedicalCleared,
        isDark: isDark,
      ),
    ]);
  }

  Widget _buildDocuments(
    BuildContext context,
    CandidateModel candidate,
    bool isDark,
  ) {
    return _buildSection('Documents', isDark, [
      _documentRow(
        context: context,
        candidate: candidate,
        name: 'Aadhaar Card',
        url: candidate.aadhaarDocUrl,
        isDark: isDark,
      ),
      _documentRow(
        context: context,
        candidate: candidate,
        name: 'PAN Card',
        url: candidate.panDocUrl,
        isDark: isDark,
      ),
      _documentRow(
        context: context,
        candidate: candidate,
        name: 'Passport',
        url: candidate.passportDocUrl,
        isDark: isDark,
      ),
      _documentRow(
        context: context,
        candidate: candidate,
        name: 'Police Verification',
        url: candidate.policeVerificationDocUrl,
        isDark: isDark,
        isPromotionOnly: true,
      ),
      _documentRow(
        context: context,
        candidate: candidate,
        name: 'Medical Clearance',
        url: candidate.medicalClearanceDocUrl,
        isDark: isDark,
        isPromotionOnly: true,
      ),
    ]);
  }

  Widget _buildCurrentPlacement(CandidateModel candidate, bool isDark) {
    return _buildSection('Current Placement', isDark, [
      _infoRow('Placement ID', candidate.currentPlacementId ?? 'N/A', isDark),
    ]);
  }

  Widget _buildRemarks(CandidateModel candidate, bool isDark) {
    return _buildSection('Remarks', isDark, [
      Text(
        candidate.remarks ?? '',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
        ),
      ),
    ]);
  }

  void _showBlacklistDialog(BuildContext context, CandidateModel candidate) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          title: Text(
            'Blacklist Candidate',
            style: GoogleFonts.poppins(
              color: AppColors.criticalRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide a reason for blacklisting this candidate. This action will log a permanent note.',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter blacklist reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.grey500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a note before blacklisting.'),
                    ),
                  );
                  return;
                }
                context.read<CandidateBloc>().add(
                  UpdateCandidate(
                    candidate.copyWith(
                      status: CandidateStatus.blacklisted,
                      remarks: noteController.text.trim(),
                    ),
                  ),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.criticalRed,
                foregroundColor: AppColors.white,
              ),
              child: Text(
                'Confirm Blacklist',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationItem({
    required BuildContext context,
    required String label,
    required bool isVerified,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isVerified ? AppColors.successGreen : AppColors.criticalRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  isVerified
                      ? 'Verified (Certificate Uploaded)'
                      : 'Pending (Upload on Promotion)',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        isVerified ? AppColors.successGreen : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isVerified
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : AppColors.grey500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    isVerified
                        ? AppColors.successGreen.withValues(alpha: 0.4)
                        : AppColors.grey500.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isVerified ? 'Verified' : 'Pending',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    isVerified
                        ? AppColors.successGreen
                        : (isDark ? AppColors.grey400 : AppColors.grey600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentRow({
    required BuildContext context,
    required CandidateModel candidate,
    required String name,
    required String? url,
    required bool isDark,
    bool isPromotionOnly = false,
  }) {
    final hasDoc = url != null && url.trim().isNotEmpty && url.trim() != 'null';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            hasDoc ? Icons.description : Icons.description_outlined,
            size: 18,
            color: hasDoc ? AppColors.successGreen : AppColors.grey500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  hasDoc
                      ? 'Uploaded'
                      : (isPromotionOnly ? 'Upload on Promotion' : 'Missing'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color:
                        hasDoc
                            ? AppColors.successGreen
                            : (isPromotionOnly
                                ? AppColors.grey500
                                : AppColors.urgentAmber),
                  ),
                ),
              ],
            ),
          ),
          if (hasDoc) ...[
            InkWell(
              onTap: () async {
                final uri = Uri.tryParse(url.trim());
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot open document: $url')),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Doc',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.open_in_new,
                      size: 12,
                      color: AppColors.successGreen,
                    ),
                  ],
                ),
              ),
            ),
            if (!isPromotionOnly &&
                candidate.status != CandidateStatus.blacklisted) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                tooltip: 'Replace $name',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: isDark ? AppColors.grey400 : AppColors.grey600,
                onPressed:
                    () => _handleUploadDocument(context, candidate, name),
              ),
            ],
          ] else if (isPromotionOnly ||
              candidate.status == CandidateStatus.blacklisted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.grey500.withValues(alpha: 0.1)
                        : AppColors.grey200.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isPromotionOnly ? 'Via Promotion' : 'Not Allowed',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
            ),
          ] else ...[
            InkWell(
              onTap: () => _handleUploadDocument(context, candidate, name),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.file_upload_outlined,
                      size: 13,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Upload',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
