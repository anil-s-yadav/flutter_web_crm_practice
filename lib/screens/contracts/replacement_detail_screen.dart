import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/candidate_picker_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_event.dart';
import 'package:practice_app/blocs/replacement/replacement_state.dart';

class ReplacementDetailScreen extends StatefulWidget {
  final String requestId;

  const ReplacementDetailScreen({super.key, required this.requestId});

  @override
  State<ReplacementDetailScreen> createState() =>
      _ReplacementDetailScreenState();
}

class _ReplacementDetailScreenState extends State<ReplacementDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReplacementBloc>().add(const LoadReplacements());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return BlocBuilder<ReplacementBloc, ReplacementState>(
      builder: (context, replacementState) {
        if (replacementState is ReplacementInitial ||
            replacementState is ReplacementLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (replacementState is ReplacementError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${replacementState.message}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          );
        } else if (replacementState is ReplacementLoaded) {
          final request =
              replacementState.replacements
                  .where((r) => r.id == widget.requestId)
                  .firstOrNull;

          if (request == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Replacement Details')),
              body: const Center(child: Text('Replacement Request not found')),
            );
          }

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
            body: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/sales/contracts/replacements');
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 18,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back to Replacements',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Card
                  _buildHeaderCard(request, dateFormat, isDark),
                  const SizedBox(height: 20),

                  // Info Cards
                  _buildInfoCard(context, request, isDark),
                  const SizedBox(height: 20),

                  // Sourcing Suggestions
                  if (request.suggestedCandidateIds.isNotEmpty &&
                      request.status != ReplacementStatus.resolved) ...[
                    _buildSourcingSuggestionsCard(context, request, isDark),
                    const SizedBox(height: 20),
                  ],

                  // Resolution Card (if resolved)
                  if (request.status == ReplacementStatus.resolved) ...[
                    _buildResolutionCard(request, dateFormat, isDark),
                    const SizedBox(height: 20),
                  ],

                  // Action Button
                  _buildActionButtons(context, request, state, isDark),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderCard(
    ReplacementRequestModel request,
    DateFormat dateFormat,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request ID: ${request.id}',
                style: GoogleFonts.poppins(
                  color: AppColors.grey500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildStatusBadge(
                request.status.displayName,
                _getStatusColor(request.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Request Date: ${dateFormat.format(request.requestDate)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ReplacementRequestModel request,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.navyBlue),
              const SizedBox(width: 10),
              Text(
                'Request Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 20,
            children: [
              _buildInfoItem(
                'Client Name',
                request.clientName,
                Icons.person,
                isDark,
              ),
              InkWell(
                onTap: () {
                  final currentRoute = GoRouterState.of(context).uri.toString();
                  final prefix =
                      currentRoute.startsWith('/admin') ? '/admin' : '/sales';
                  context.push('$prefix/contracts/${request.contractId}');
                },
                child: _buildInfoItem(
                  'Contract ID',
                  request.contractId,
                  Icons.description,
                  isDark,
                  isLink: true,
                ),
              ),
              _buildInfoItem(
                'Old Candidate',
                request.oldCandidateName,
                Icons.person_remove,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Reason',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.grey500 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.reason,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionCard(
    ReplacementRequestModel request,
    DateFormat dateFormat,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? AppColors.dividerDark
                  : AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: AppColors.successGreen),
              const SizedBox(width: 10),
              Text(
                'Resolution',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 20,
            children: [
              _buildInfoItem(
                'New Candidate Name',
                request.newCandidateId ?? 'Unknown',
                Icons.person_add,
                isDark,
              ),
              if (request.resolvedDate != null)
                _buildInfoItem(
                  'Resolved Date',
                  dateFormat.format(request.resolvedDate!),
                  Icons.calendar_today,
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourcingSuggestionsCard(
    BuildContext context,
    ReplacementRequestModel request,
    bool isDark,
  ) {
    if (request.suggestedCandidateIds.isEmpty) return const SizedBox.shrink();

    final candidateState = context.read<CandidateBloc>().state;
    final candidates =
        candidateState is CandidateLoaded
            ? candidateState.candidates
            : <CandidateModel>[];
    final suggestedCandidates =
        request.suggestedCandidateIds
            .map((id) => candidates.where((c) => c.id == id).firstOrNull)
            .where((c) => c != null)
            .cast<CandidateModel>()
            .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, size: 20, color: AppColors.gold),
              const SizedBox(width: 10),
              Text(
                'Sourcing Suggestions',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sourcing has provided the following candidates for this request. Please review and assign.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                suggestedCandidates
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkSurface : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.dividerDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.fullName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            Text(
                              '${c.category} • ₹${c.expectedSalary}',
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
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ReplacementRequestModel request,
    dynamic state,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed:
              request.status == ReplacementStatus.resolved
                  ? null
                  : () => _handleAssignNewStaff(context, request, state),
          icon: const Icon(Icons.person_add),
          label: Text(
            'Assign New Staff',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.standardBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        if (request.status != ReplacementStatus.resolved &&
            !request.isEscalatedToSourcing)
          OutlinedButton.icon(
            onPressed: () => _showEscalateToSourcingSheet(context, request),
            icon: const Icon(Icons.support_agent),
            label: Text(
              'Request Urgent Sourcing',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.urgentAmber,
              side: const BorderSide(color: AppColors.urgentAmber),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
      ],
    );
  }

  void _showEscalateToSourcingSheet(
    BuildContext context,
    ReplacementRequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _EscalateToSourcingSheet(request: request),
    );
  }

  Future<void> _handleAssignNewStaff(
    BuildContext context,
    ReplacementRequestModel request,
    dynamic state,
  ) async {
    final selectedCandidate = await CandidatePickerDialog.show(context);
    if (selectedCandidate != null) {
      context.read<ReplacementBloc>().add(
        AssignReplacementStaff(
          requestId: request.id,
          newCandidateId: selectedCandidate['id']!,
          newCandidateName: selectedCandidate['name']!,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Replacement staff assigned')),
        );
      }
    }
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool isLink = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.grey500 : AppColors.grey600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    isLink
                        ? AppColors.standardBlue
                        : (isDark ? AppColors.white : AppColors.navyBlue),
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(ReplacementStatus status) {
    switch (status) {
      case ReplacementStatus.pending:
        return AppColors.statusPending;
      case ReplacementStatus.inProgress:
        return AppColors.infoBlue;
      case ReplacementStatus.resolved:
        return AppColors.successGreen;
    }
  }
}

class _EscalateToSourcingSheet extends StatefulWidget {
  final ReplacementRequestModel request;
  const _EscalateToSourcingSheet({required this.request});

  @override
  State<_EscalateToSourcingSheet> createState() =>
      _EscalateToSourcingSheetState();
}

class _EscalateToSourcingSheetState extends State<_EscalateToSourcingSheet> {
  final _formKey = GlobalKey<FormState>();
  String _criteria = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Urgent Sourcing',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send this replacement request back to the sourcing pool for urgent fulfillment.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Required Criteria (Optional)',
                  hintText:
                      'e.g. Needs to speak Hindi, experienced in infant care',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                onSaved: (val) => _criteria = val ?? '',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: AppColors.grey500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _escalate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.urgentAmber,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Escalate Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _escalate() {
    _formKey.currentState!.save();

    // Escalate via BLoC
    context.read<ReplacementBloc>().add(
      UpdateReplacement(
        widget.request.copyWith(
          isEscalatedToSourcing: true,
          requiredCriteria: _criteria,
        ),
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request escalated to Sourcing for urgent fulfillment!'),
      ),
    );
  }
}
