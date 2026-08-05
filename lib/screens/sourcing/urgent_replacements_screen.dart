import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/widgets/candidate_picker_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_event.dart';
import 'package:practice_app/blocs/replacement/replacement_state.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';

class UrgentReplacementsScreen extends StatefulWidget {
  const UrgentReplacementsScreen({super.key});

  @override
  State<UrgentReplacementsScreen> createState() =>
      _UrgentReplacementsScreenState();
}

class _UrgentReplacementsScreenState extends State<UrgentReplacementsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReplacementBloc>().add(const LoadReplacements());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Urgent Replacements'),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
          onPressed: () => context.go('/sourcing'),
        ),
      ),
      body: BlocBuilder<ReplacementBloc, ReplacementState>(
        builder: (context, replacementState) {
          if (replacementState is ReplacementInitial ||
              replacementState is ReplacementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (replacementState is ReplacementError) {
            return Center(
              child: Text(
                'Error: ${replacementState.message}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          } else if (replacementState is ReplacementLoaded) {
            // Filter requests escalated to Sourcing and not yet resolved
            final urgentRequests =
                replacementState.replacements
                    .where(
                      (r) =>
                          r.isEscalatedToSourcing &&
                          r.status != ReplacementStatus.resolved,
                    )
                    .toList();

            return urgentRequests.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No urgent replacements needed!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.grey300 : AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: urgentRequests.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _UrgentReplacementCard(
                      request: urgentRequests[index],
                    );
                  },
                );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UrgentReplacementCard extends StatefulWidget {
  final ReplacementRequestModel request;
  const _UrgentReplacementCard({required this.request});

  @override
  State<_UrgentReplacementCard> createState() => _UrgentReplacementCardState();
}

class _UrgentReplacementCardState extends State<_UrgentReplacementCard> {
  final List<CandidateModel> _selectedCandidates = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.urgentAmber.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Client: ${widget.request.clientName}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.urgentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.urgentAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'URGENT',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.urgentAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Requested on: ${dateFormat.format(widget.request.requestDate)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replacement Reason:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.reason,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Required Criteria (from Sales):',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.requiredCriteria?.isNotEmpty == true
                        ? widget.request.requiredCriteria!
                        : 'No specific criteria provided.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Suggested Candidates section
            Text(
              'Selected Candidates for Sales to Review',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedCandidates.isEmpty)
              Text(
                'No candidates selected yet.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey500,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _selectedCandidates
                        .map(
                          (c) => Chip(
                            label: Text('${c.fullName} (${c.id})'),
                            onDeleted:
                                () => setState(
                                  () => _selectedCandidates.remove(c),
                                ),
                            backgroundColor: AppColors.standardBlue.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(
                              color: AppColors.standardBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickCandidate,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Candidate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.standardBlue,
                    side: const BorderSide(color: AppColors.standardBlue),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed:
                      _selectedCandidates.isEmpty ? null : _submitFulfillment,
                  icon: const Icon(Icons.send),
                  label: const Text('Fulfill Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCandidate() async {
    final result = await CandidatePickerDialog.show(context);
    if (result != null) {
      if (!mounted) return;
      final candidateState = context.read<CandidateBloc>().state;
      if (candidateState is CandidateLoaded) {
        final candidate = candidateState.candidates.firstWhere(
          (c) => c.id == result['id'],
          orElse:
              () => CandidateModel(
                id: result['id']!,
                fullName: result['name']!,
                age: 25,
                phone: '',
                address: '',
                city: '',
                state: '',
                languages: const [],
                religion: '',
                category: '',
                education: '',
                experienceYears: 0,
                expectedSalary: '0',
                workingHoursPerDay: 8,
                status: CandidateStatus.readyToPlace,
                isMedicalCleared: true,
                isPoliceVerified: true,
                addedBy: 'System',
                dateAdded: DateTime.now(),
              ),
        );
        if (!_selectedCandidates.any((c) => c.id == candidate.id)) {
          setState(() {
            _selectedCandidates.add(candidate);
          });
        }
      }
    }
  }

  void _submitFulfillment() {
    if (_selectedCandidates.isNotEmpty) {
      context.read<ReplacementBloc>().add(
        AssignReplacementStaff(
          requestId: widget.request.id,
          newCandidateId: _selectedCandidates.first.id,
          newCandidateName: _selectedCandidates.first.fullName,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request fulfilled and sent back to Sales!'),
      ),
    );
  }
}
