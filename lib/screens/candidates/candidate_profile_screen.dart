import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:provider/provider.dart';

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
      case CandidateStatus.placed:
        return 4;
      case CandidateStatus.blacklisted:
        return 0;
      case CandidateStatus.renewalPending:
        // TODO: Handle this case.
        throw UnimplementedError();
      case CandidateStatus.jobLeft:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isMobile = width < 800;
    final isTablet = width >= 800 && width <= 1100;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final candidate = state.getCandidate(candidateId);
    if (candidate == null) {
      return const Center(child: Text('Candidate not found'));
    }

    final relevantLogs = state.auditLogs.where((l) => l.targetId == candidate.id).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  label: Text('Go Back', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.navyBlue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isMobile)
              _buildMobileLayout(context, candidate, state, isDark, relevantLogs)
            else if (isTablet)
              _buildTabletLayout(context, candidate, state, isDark, relevantLogs)
            else
              _buildDesktopLayout(context, candidate, state, isDark, relevantLogs),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CandidateModel candidate, GlobalAppState state, bool isDark, List<dynamic> relevantLogs) {
    return Column(
      children: [
        _buildProfileHeader(candidate, isDark),
        const SizedBox(height: 16),
        _buildTopActions(context, state, candidate),
        const SizedBox(height: 24),
        if (candidate.status == CandidateStatus.placed) _buildHiredDashboard(context, candidate, isDark)
        else _buildPipelineIndicator(candidate, isDark),
        const SizedBox(height: 24),
        _buildPersonalDetails(candidate, isDark),
        const SizedBox(height: 16),
        _buildLanguages(candidate, isDark),
        const SizedBox(height: 16),
        _buildVerificationStatus(candidate, isDark),
        const SizedBox(height: 16),
        _buildDocuments(candidate, isDark),
        const SizedBox(height: 16),
        if (candidate.currentPlacementId != null) _buildCurrentPlacement(candidate, isDark),
        if (candidate.remarks != null) ...[
          const SizedBox(height: 16),
          _buildRemarks(candidate, isDark),
        ],
        const SizedBox(height: 24),
        if (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin)
          _buildActionBar(context, candidate, isDark),
        const SizedBox(height: 32),
        AuditLogWidget(logs: relevantLogs.cast(), title: 'Candidate Activity History'),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, CandidateModel candidate, GlobalAppState state, bool isDark, List<dynamic> relevantLogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileHeader(candidate, isDark),
        const SizedBox(height: 16),
        _buildTopActions(context, state, candidate),
        const SizedBox(height: 24),
        if (candidate.status == CandidateStatus.placed) _buildHiredDashboard(context, candidate, isDark)
        else _buildPipelineIndicator(candidate, isDark),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPersonalDetails(candidate, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildVerificationStatus(candidate, isDark)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDocuments(candidate, isDark),
        const SizedBox(height: 16),
        if (candidate.currentPlacementId != null) _buildCurrentPlacement(candidate, isDark),
        if (candidate.remarks != null) ...[
          const SizedBox(height: 16),
          _buildRemarks(candidate, isDark),
        ],
        const SizedBox(height: 24),
        if (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin) ...[
          _buildActionBar(context, candidate, isDark),
          const SizedBox(height: 16),
        ],
        _buildLanguages(candidate, isDark),
        const SizedBox(height: 32),
        AuditLogWidget(logs: relevantLogs.cast(), title: 'Candidate Activity History'),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CandidateModel candidate, GlobalAppState state, bool isDark, List<dynamic> relevantLogs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(candidate, isDark),
              const SizedBox(height: 16),
              _buildTopActions(context, state, candidate),
              const SizedBox(height: 16),
              _buildPersonalDetails(candidate, isDark),
              const SizedBox(height: 24),
              if (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin) ...[
                _buildActionBar(context, candidate, isDark),
                const SizedBox(height: 16),
              ],
              _buildLanguages(candidate, isDark),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (candidate.status == CandidateStatus.placed) _buildHiredDashboard(context, candidate, isDark)
              else _buildPipelineIndicator(candidate, isDark),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildVerificationStatus(candidate, isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDocuments(candidate, isDark),
                  ),
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
              AuditLogWidget(logs: relevantLogs.cast(), title: 'Candidate Activity History'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopActions(BuildContext context, GlobalAppState state, CandidateModel candidate) {
    if (candidate.status == CandidateStatus.placed || candidate.status == CandidateStatus.blacklisted || candidate.status == CandidateStatus.readyToPlace) {
      if (!(candidate.status == CandidateStatus.newlyAdded && (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin))) {
        return const SizedBox.shrink();
      }
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (candidate.status == CandidateStatus.newlyAdded && (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin))
          ElevatedButton.icon(
            onPressed: () {
              final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
              context.go('$routePrefix/candidates/${candidate.id}/edit');
            },
            icon: const Icon(Icons.edit, size: 16),
            label: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.navyBlue,
              elevation: 0,
              side: BorderSide(color: AppColors.navyBlue.withValues(alpha: 0.2)),
            ),
          ),
        if (candidate.status != CandidateStatus.placed && candidate.status != CandidateStatus.blacklisted && candidate.status != CandidateStatus.readyToPlace)
          PopupMenuButton<VoidCallback>(
            tooltip: 'Promote Candidate',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.navyBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward, size: 16, color: AppColors.white),
                  const SizedBox(width: 8),
                  Text('Promote', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.white),
                ],
              ),
            ),
            onSelected: (action) => action(),
            itemBuilder: (context) {
              final appState = Provider.of<GlobalAppState>(context, listen: false);
              return [
                if (candidate.status == CandidateStatus.newlyAdded)
                  PopupMenuItem(
                    value: () => appState.advanceCandidatePipeline(candidate.id, CandidateStatus.verificationPending),
                    child: const Text('Promote to Police Verification'),
                  ),
                if (candidate.status == CandidateStatus.verificationPending) ...[
                  PopupMenuItem(
                    value: () => appState.updateCandidate(candidate.copyWith(status: CandidateStatus.medicalPending, isPoliceVerified: true, isAadhaarVerified: true), 'Police & Aadhaar Verified. Moved to Medical Pending.'),
                    child: const Text('Promote to Medical Test'),
                  ),
                  PopupMenuItem(
                    value: () => appState.updateCandidate(candidate.copyWith(status: CandidateStatus.readyToPlace, isPoliceVerified: true, isAadhaarVerified: true, isMedicalCleared: false, availableFrom: DateTime.now()), 'Police & Aadhaar Verified. Medical bypassed. Moved to Ready to Place.'),
                    child: const Text('Promote to Ready to Hire (Skip Medical)'),
                  ),
                ],
                if (candidate.status == CandidateStatus.medicalPending)
                  PopupMenuItem(
                    value: () => appState.updateCandidate(candidate.copyWith(status: CandidateStatus.readyToPlace, isMedicalCleared: true, availableFrom: DateTime.now()), 'Medical Test Cleared. Moved to Ready to Place.'),
                    child: const Text('Promote to Ready to Hire'),
                  ),
              ];
            },
          ),
      ],
    );
  }

  Widget _buildHiredDashboard(
    BuildContext context,
    CandidateModel candidate,
    bool isDark,
  ) {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    ContractModel? contract;
    try {
      contract = state.contracts.firstWhere(
        (c) => c.id == candidate.currentPlacementId,
      );
    } catch (_) {}

    final client = contract != null ? state.getClient(contract.clientId) : null;

    if (contract == null || client == null) return const SizedBox.shrink();

    final clientContracts =
        state.contracts.where((c) => c.clientId == client.id).toList()
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
              Text(
                'Active Placement Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const Spacer(),
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
                  foregroundColor: AppColors.navyBlue,
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

  Widget _buildProfileHeader(CandidateModel candidate, bool isDark) {
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
            CircleAvatar(
              radius: 36,
              backgroundColor: isDark 
                  ? AppColors.white.withValues(alpha: 0.1)
                  : AppColors.navyBlue.withValues(alpha: 0.1),
              child: Text(
                candidate.fullName.isNotEmpty
                    ? candidate.fullName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join()
                    : '?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
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
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIndex = i ~/ 2;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color:
                          stepIndex < progress
                              ? colors[stepIndex]
                              : (isDark
                                  ? AppColors.grey700
                                  : AppColors.grey300),
                    ),
                  );
                }
                final stepIndex = i ~/ 2;
                bool isComplete = stepIndex < progress;
                bool isSkipped = false;
                
                if (stepIndex == 2 && progress > 2 && !candidate.isMedicalCleared) {
                  isComplete = false;
                  isSkipped = true;
                }

                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSkipped 
                            ? (isDark ? AppColors.grey700 : AppColors.grey200)
                            : (isComplete
                                ? colors[stepIndex]
                                : (isDark
                                    ? AppColors.grey700
                                    : AppColors.grey300)),
                        border: isSkipped ? Border.all(color: AppColors.grey400, width: 2) : null,
                      ),
                      child: Icon(
                        isSkipped ? Icons.double_arrow : (isComplete ? Icons.check : Icons.circle),
                        size: isSkipped ? 16 : (isComplete ? 18 : 8),
                        color: isSkipped ? AppColors.grey500 : AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSkipped ? 'Skipped' : steps[stepIndex],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight:
                            (isComplete || isSkipped) ? FontWeight.w600 : FontWeight.w400,
                        color: isSkipped 
                            ? AppColors.grey500
                            : (isComplete
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
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: isDark ? AppColors.grey500 : AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
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
      if (candidate.altPhone != null) _infoRow('Alt Phone', candidate.altPhone!, isDark),
      _infoRow('Address', candidate.address, isDark),
      _infoRow('City', '${candidate.city}, ${candidate.state}', isDark),
      _infoRow('Religion', candidate.religion, isDark),
      _infoRow('Expected Salary', candidate.expectedSalary, isDark),
      _infoRow('Working Hours', '${candidate.workingHoursPerDay} hrs/day', isDark),
      if (candidate.preferredWorkType != null)
        _infoRow('Pref. Work Type', candidate.preferredWorkType!, isDark),
    ]);
  }

  Widget _buildLanguages(CandidateModel candidate, bool isDark) {
    return _buildSection('Languages', isDark, [
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children:
            candidate.languages
                .map(
                  (l) => Chip(
                    label: Text(l),
                    labelStyle: GoogleFonts.poppins(fontSize: 11),
                    backgroundColor: AppColors.stageInterviewed.withValues(
                      alpha: 0.1,
                    ),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
      ),
    ]);
  }

  Widget _buildVerificationStatus(CandidateModel candidate, bool isDark) {
    return _buildSection('Verification Hub', isDark, [
      _verificationItem('Police Verification', candidate.isPoliceVerified, isDark),
      _verificationItem('Aadhaar Verification', candidate.isAadhaarVerified, isDark),
      _verificationItem('Medical Clearance', candidate.isMedicalCleared, isDark),
    ]);
  }

  Widget _buildDocuments(CandidateModel candidate, bool isDark) {
    return _buildSection('Documents', isDark, [
      _documentRow('Aadhaar', candidate.aadhaarDocUrl, isDark),
      _documentRow('Medical Clearance', candidate.medicalClearanceDocUrl, isDark),
      _documentRow(
        'Police Verification',
        candidate.policeVerificationDocUrl,
        isDark,
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

  Widget _buildActionBar(BuildContext context, CandidateModel candidate, bool isDark) {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark
                  ? AppColors.dividerDark
                  : AppColors.criticalRed.withValues(alpha: 0.2),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          if (candidate.status == CandidateStatus.newlyAdded) ...[
            _actionButton(
              'Edit Profile',
              Icons.edit,
              AppColors.navyBlue,
              isDark,
              () {
                final routePrefix =
                    state.currentUser?.role == UserRole.admin
                        ? '/admin'
                        : '/sourcing';
                context.go('$routePrefix/candidates/${candidate.id}/edit');
              },
            ),
            _actionButton(
              'Move to Verification',
              Icons.fact_check,
              AppColors.stagePoliceVerification,
              isDark,
              () {
                Provider.of<GlobalAppState>(
                  context,
                  listen: false,
                ).advanceCandidatePipeline(candidate.id, CandidateStatus.verificationPending);
              },
            ),
          ],

          if (candidate.status == CandidateStatus.verificationPending) ...[
            _actionButton(
              'Promote to Medical Test',
              Icons.medical_services,
              AppColors.stageMedicalCheck,
              isDark,
              () {
                Provider.of<GlobalAppState>(context, listen: false).updateCandidate(
                  candidate.copyWith(
                    status: CandidateStatus.medicalPending,
                    isPoliceVerified: true,
                    isAadhaarVerified: true,
                  ),
                  'Police & Aadhaar Verified. Moved to Medical Pending.',
                );
              },
            ),
            _actionButton(
              'Promote to Ready to Hire',
              Icons.verified,
              AppColors.statusVerified,
              isDark,
              () {
                Provider.of<GlobalAppState>(context, listen: false).updateCandidate(
                  candidate.copyWith(
                    status: CandidateStatus.readyToPlace,
                    isPoliceVerified: true,
                    isAadhaarVerified: true,
                    isMedicalCleared: false, // Explicitly bypassed
                    availableFrom: DateTime.now(),
                  ),
                  'Police & Aadhaar Verified. Medical bypassed. Moved to Ready to Place.',
                );
              },
            ),
          ],

          if (candidate.status == CandidateStatus.medicalPending)
            _actionButton(
              'Promote to Ready to Hire',
              Icons.verified,
              AppColors.statusVerified,
              isDark,
              () {
                Provider.of<GlobalAppState>(context, listen: false).updateCandidate(
                  candidate.copyWith(
                    status: CandidateStatus.readyToPlace,
                    isMedicalCleared: true,
                    availableFrom: DateTime.now(),
                  ),
                  'Medical Test Cleared. Moved to Ready to Place.',
                );
              },
            ),

          if (candidate.status != CandidateStatus.blacklisted &&
              candidate.status != CandidateStatus.placed)
            _actionButton(
              'Blacklist',
              Icons.block,
              AppColors.statusBlacklisted,
              isDark,
              () {
                _showBlacklistDialog(context, candidate.id);
              },
            ),
        ],
      ),
    );
  }

  void _showBlacklistDialog(BuildContext context, String candidateId) {
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
                Provider.of<GlobalAppState>(
                  context,
                  listen: false,
                ).blacklistCandidate(candidateId, noteController.text.trim());
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

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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

  Widget _verificationItem(String label, bool isVerified, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isVerified ? AppColors.successGreen : AppColors.criticalRed,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentRow(String name, String? url, bool isDark) {
    final hasDoc = url != null && url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            hasDoc ? Icons.description : Icons.description_outlined,
            size: 18,
            color: hasDoc ? AppColors.successGreen : AppColors.grey500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
              ),
            ),
          ),
          Text(
            hasDoc ? 'Uploaded' : 'Missing',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: hasDoc ? AppColors.successGreen : AppColors.urgentAmber,
            ),
          ),
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
