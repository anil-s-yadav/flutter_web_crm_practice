import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_state.dart';
import 'package:practice_app/blocs/audit_log/audit_log_bloc.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_event.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/blocs/contract/contract_bloc.dart';
import 'package:practice_app/blocs/contract/contract_event.dart';
import 'package:practice_app/blocs/contract/contract_state.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/utils/pdf_generator.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/blocs/replacement/replacement_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_state.dart';

class ClientProfileScreen extends StatefulWidget {
  final String clientId;

  const ClientProfileScreen({super.key, required this.clientId});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(LoadClients());
    context.read<ContractBloc>().add(LoadContracts());
    context.read<CandidateBloc>().add(LoadCandidates());
    context.read<AuditLogBloc>().add(const LoadAuditLogs());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, clientState) {
        return BlocBuilder<ContractBloc, ContractState>(
          builder: (context, contractState) {
            return BlocBuilder<CandidateBloc, CandidateState>(
              builder: (context, candidateState) {
                return BlocBuilder<AuditLogBloc, AuditLogState>(
                  builder: (context, auditLogState) {
                    if (clientState is ClientLoading ||
                        contractState is ContractLoading ||
                        candidateState is CandidateLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (clientState is ClientError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${clientState.message}')),
                  );
                }
                if (contractState is ContractError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${contractState.message}'),
                    ),
                  );
                }
                if (candidateState is CandidateError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${candidateState.message}'),
                    ),
                  );
                }

                if (clientState is ClientLoaded &&
                    contractState is ContractLoaded &&
                    candidateState is CandidateLoaded) {
                  final clientList =
                      clientState.clients
                          .where((c) => c.id == widget.clientId)
                          .toList();
                  if (clientList.isEmpty) {
                    return const Scaffold(
                      body: Center(child: Text('Client not found')),
                    );
                  }
                  final client = clientList.first;

                  final contractList =
                      contractState.contracts
                          .where((c) => c.clientId == client.id)
                          .toList();
                  contractList.sort(
                    (a, b) => b.placementDate.compareTo(a.placementDate),
                  );
                  final contract =
                      contractList.isNotEmpty ? contractList.first : null;

                  final candidateList =
                      contract != null
                          ? candidateState.candidates
                              .where((c) => c.id == contract.candidateId)
                              .toList()
                          : [];
                  final candidate =
                      candidateList.isNotEmpty ? candidateList.first : null;

                  final relevantLogs = auditLogState is AuditLogLoaded
                      ? auditLogState.auditLogs
                          .where((l) => l.targetId == client.id)
                          .toList()
                      : <AuditLogModel>[];

                  final tabs = [
                    'Details',
                    'Candidates & Contracts',
                    'Documents',
                  ];

                  return Scaffold(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color:
                              isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceLight,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(tabs.length, (index) {
                                final isSelected = _activeTabIndex == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(
                                      tabs[index],
                                      style: GoogleFonts.poppins(
                                        color:
                                            isSelected
                                                ? AppColors.navyBlue
                                                : (isDark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors
                                                        .textSecondaryLight),
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.gold,
                                    backgroundColor:
                                        isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.white,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        _activeTabIndex = index;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: _buildActiveTabContent(
                              client,
                              contract,
                              candidate,
                              relevantLogs,
                              isDark,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Scaffold(
                  body: Center(child: Text('Unknown state')),
                );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveTabContent(
    ClientModel client,
    ContractModel? contract,
    CandidateModel? candidate,
    List<AuditLogModel> relevantLogs,
    bool isDark,
    BuildContext context,
  ) {
    if (_activeTabIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientHeader(context, client, isDark),
          const SizedBox(height: 16),
          if (client.status == ClientStatus.converted &&
              client.renewalCount > 0) ...[
            _buildLoyaltyCard(context, client, isDark),
            const SizedBox(height: 16),
          ],
          _buildUnifiedDetailsCard(context, client, isDark),
        ],
      );
    } else if (_activeTabIndex == 1) {
      final contractState = context.read<ContractBloc>().state;
      final allContracts =
          contractState is ContractLoaded
              ? contractState.contracts
              : <ContractModel>[];

      // All contracts for this client, sorted by date descending
      final allClientContracts =
          allContracts.where((c) => c.clientId == client.id).toList()
            ..sort((a, b) => b.placementDate.compareTo(a.placementDate));
      final replacementState = context.read<ReplacementBloc>().state;
      final clientReplacements =
          replacementState is ReplacementLoaded
              ? (replacementState.replacements
                  .where((r) => r.clientId == client.id)
                  .toList()
                ..sort((a, b) => b.requestDate.compareTo(a.requestDate)))
              : <ReplacementRequestModel>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contract != null && candidate != null) ...[
            _buildActiveContractCard(context, contract, candidate, isDark),
            const SizedBox(height: 16),
            _buildContractActions(context, contract, client, candidate, isDark),
          ] else ...[
            _buildEmptyContractState(context, client, isDark),
          ],
          const SizedBox(height: 32),
          // --- Contract History Timeline ---
          if (allClientContracts.isNotEmpty) ...[
            _buildContractHistoryTimeline(context, allClientContracts, isDark),
            const SizedBox(height: 32),
          ],
          // --- Replacement Requests ---
          if (clientReplacements.isNotEmpty) ...[
            _buildClientReplacements(context, clientReplacements, isDark),
            const SizedBox(height: 32),
          ],
          AuditLogWidget(
            logs: relevantLogs,
            title: 'Client & Contract History',
          ),
        ],
      );
    } else {
      return _buildDocumentsTab(client, contract, candidate, isDark);
    }
  }

  Widget _buildClientHeader(
    BuildContext context,
    ClientModel client,
    bool isDark,
  ) {
    final isMobile = context.media.width < 800;

    final actionButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final currentLocation = GoRouterState.of(context).uri.toString();
            final routePrefix =
                currentLocation.startsWith('/admin') ? '/admin' : '/sales';
            context.push('$routePrefix/clients/${client.id}/edit');
          },
          icon: const Icon(Icons.edit, size: 16),
          label: Text(
            'Edit',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? AppColors.darkSurfaceVariant : AppColors.white,
            foregroundColor: isDark ? AppColors.white : AppColors.navyBlue,
            elevation: 0,
            side: BorderSide(
              color: (isDark ? AppColors.white : AppColors.navyBlue).withValues(
                alpha: 0.2,
              ),
            ),
          ),
        ),
        // ElevatedButton.icon(
        //   onPressed: () => _showAddNoteDialog(context, client),
        //   icon: const Icon(Icons.phone_in_talk, size: 16),
        //   label: Text(
        //     'Log Call / Note',
        //     style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor:
        //         isDark ? const Color.fromARGB(255, 46, 48, 51) : AppColors.grey100,
        //     foregroundColor: isDark ? AppColors.white : AppColors.navyBlue,
        //     elevation: 0,
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   ),
        // ),
        if (client.status == ClientStatus.followUp) ...[
          ElevatedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.interested,
                  'Client moved to Interested',
                ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Move to Interested'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.notInterested,
                  'Client marked as Not Interested',
                ),
            icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
            label: const Text('Not Interested'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.criticalRed,
              side: const BorderSide(color: AppColors.criticalRed),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ] else if (client.status == ClientStatus.interested) ...[
          ElevatedButton.icon(
            onPressed: () => _showAssignCandidateModal(context, client),
            icon: const Icon(Icons.handshake, size: 18),
            label: const Text('Assign Candidate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.notInterested,
                  'Client marked as Not Interested',
                ),
            icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
            label: const Text('Not Interested'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.criticalRed,
              side: const BorderSide(color: AppColors.criticalRed),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.followUp,
                  'Client moved back to Follow Up',
                ),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Back to Follow Up'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.grey300 : AppColors.grey700,
              side: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ] else if (client.status == ClientStatus.notInterested) ...[
          ElevatedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.followUp,
                  'Client reactivated to Follow Up',
                ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Re-open to Follow Up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.interested,
                  'Client moved to Interested',
                ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Move to Interested'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ],
    );

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
        child:
            isMobile
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.gold.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            client.fullName.isNotEmpty
                                ? client.fullName[0]
                                : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.navyBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildBadge(
                                client.status.displayName,
                                _statusColor(client.status),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ID: ${client.id} • ${client.locality}, ${client.city}',
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    actionButtons,
                  ],
                )
                : Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                      child: Text(
                        client.fullName.isNotEmpty ? client.fullName[0] : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                client.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.navyBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildBadge(
                                client.status.displayName,
                                _statusColor(client.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID: ${client.id} • ${client.locality}, ${client.city}',
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
                    actionButtons,
                  ],
                ),
      ),
    );
  }

  Future<void> _showStatusChangeDialog(
    BuildContext context,
    ClientModel client,
    ClientStatus nextStatus,
    String successMessage,
  ) async {
    final TextEditingController noteController = TextEditingController();
    final isNotInterested = nextStatus == ClientStatus.notInterested;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isNotInterested
                          ? AppColors.criticalRed.withValues(alpha: 0.15)
                          : AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isNotInterested
                      ? Icons.warning_amber_rounded
                      : Icons.swap_horiz,
                  color:
                      isNotInterested ? AppColors.criticalRed : AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Move to ${nextStatus.displayName}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNotInterested
                      ? 'Please provide a mandatory reason for marking this client as Not Interested (e.g. Budget mismatch, hired relative, service not needed):'
                      : 'Add a note explaining the interaction or agreement to move this client to ${nextStatus.displayName}:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        isNotInterested
                            ? 'Mandatory Reason *'
                            : 'Status Change Note *',
                    hintText:
                        isNotInterested
                            ? 'e.g. Client decided not to hire maid now due to relocation.'
                            : 'e.g. Client liked maid profiles, searching for matching staff.',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.grey500 : AppColors.grey400,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.dividerDark : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isNotInterested ? AppColors.criticalRed : AppColors.gold,
                foregroundColor:
                    isNotInterested ? AppColors.white : AppColors.navyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              child: Text(
                'Confirm Status Change',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                final note = noteController.text.trim();
                if (note.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isNotInterested
                            ? 'A reason is mandatory when marking a client Not Interested.'
                            : 'Please provide a note for this status transition.',
                      ),
                      backgroundColor: AppColors.criticalRed,
                    ),
                  );
                  return;
                }

                final timestamp = DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(DateTime.now());

                final newRemarks =
                    (client.remarks == null || client.remarks!.isEmpty)
                        ? '[$timestamp] Status changed to ${nextStatus.displayName}: $note'
                        : '[$timestamp] Status changed to ${nextStatus.displayName}: $note\n\n${client.remarks}';

                context.read<ClientBloc>().add(
                  UpdateClient(
                    client.copyWith(status: nextStatus, remarks: newRemarks),
                    reason: note,
                  ),
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(successMessage),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddNoteDialog(
    BuildContext context,
    ClientModel client,
  ) async {
    final TextEditingController noteController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Log Call / Add Note',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record conversation details, client callbacks, preferences, or discussion notes for ${client.fullName}:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Called client. Spoke with spouse, requested 2 maid profiles on WhatsApp. Follow up in 3 days.',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? AppColors.grey500 : AppColors.grey400,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.dividerDark : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.save, size: 18),
              label: Text(
                'Save Note',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                final note = noteController.text.trim();
                if (note.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a note before saving.'),
                      backgroundColor: AppColors.criticalRed,
                    ),
                  );
                  return;
                }

                final timestamp = DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(DateTime.now());
                final newRemarks =
                    (client.remarks == null || client.remarks!.isEmpty)
                        ? '[$timestamp] Sales: $note'
                        : '[$timestamp] Sales: $note\n\n${client.remarks}';

                context.read<ClientBloc>().add(
                  UpdateClient(
                    client.copyWith(remarks: newRemarks),
                    reason: 'Note logged: $note',
                  ),
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Interaction note saved successfully!'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoyaltyCard(
    BuildContext context,
    ClientModel client,
    bool isDark,
  ) {
    final yearsPassed =
        (DateTime.now().difference(client.inquiryDate).inDays / 365.25).floor();
    final joinedDateStr = DateFormat('MMM yyyy').format(client.inquiryDate);

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
            Row(
              children: [
                Icon(Icons.stars, color: AppColors.gold, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Loyalty Metrics',
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
              runSpacing: 16,
              children: [
                _buildLoyaltyMetricItem(
                  'Joined',
                  joinedDateStr,
                  Icons.calendar_today,
                  isDark,
                ),
                _buildLoyaltyMetricItem(
                  'Years as Customer',
                  yearsPassed.toString(),
                  Icons.hourglass_bottom,
                  isDark,
                ),
                _buildLoyaltyMetricItem(
                  'Total Renewals',
                  client.renewalCount.toString(),
                  Icons.autorenew,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyMetricItem(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.white : AppColors.navyBlue).withValues(
              alpha: 0.05,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.grey300 : AppColors.grey600,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnifiedDetailsCard(
    BuildContext context,
    ClientModel client,
    bool isDark,
  ) {
    final isMobile = context.media.width < 800;

    final reqColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 20,
              color: AppColors.gold,
            ),
            const SizedBox(width: 8),
            Text(
              'Service Requirements',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _infoRow('Looking For', client.preferredCandidateCategory, isDark),
        if (client.serviceType.isNotEmpty)
          _infoRow('Service Type', client.serviceType, isDark),
        if (client.workTimings.isNotEmpty)
          _infoRow('Work Timings', client.workTimings, isDark),
        _infoRow('Budget', client.budgetRange, isDark),
        if (client.foodPreference.isNotEmpty)
          _infoRow('Food Preference', client.foodPreference, isDark),
        if (client.genderPreference.isNotEmpty)
          _infoRow('Gender Preference', client.genderPreference, isDark),
        if (client.preferredLanguages.isNotEmpty)
          _infoRow('Language(s)', client.preferredLanguages.join(', '), isDark),
        if (client.religionPreference.isNotEmpty)
          _infoRow('Religion Pref', client.religionPreference, isDark),
        if (client.expectedJoining.isNotEmpty)
          _infoRow('Expected Joining', client.expectedJoining, isDark),
        _infoRow('Lead Source', client.source, isDark),
        _infoRow(
          'Inquiry Date',
          DateFormat('dd MMM yyyy').format(client.inquiryDate),
          isDark,
        ),
        if (client.assignedEmployeeId != null &&
            client.assignedEmployeeId!.isNotEmpty)
          _infoRow(
            'Sales Rep',
            (client.assignedEmployeeName != null &&
                    client.assignedEmployeeName!.isNotEmpty)
                ? '${client.assignedEmployeeId} (${client.assignedEmployeeName})'
                : client.assignedEmployeeId!,
            isDark,
          ),
        if (client.remarks != null && client.remarks!.isNotEmpty)
          _infoRow('Remarks', client.remarks!, isDark),
      ],
    );

    final detailsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.home_outlined, size: 20, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'Household & Contact Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _infoRow('House Type', client.houseType, isDark),
        _infoRow('Family Size', '${client.familySize} Members', isDark),
        _infoRow(
          'Has Children',
          client.hasChildren ? 'Yes (${client.childrenCount})' : 'No',
          isDark,
        ),
        _infoRow(
          'Has Elderly',
          client.hasElderlyMembers ? 'Yes' : 'No',
          isDark,
        ),
        _infoRow(
          'Has Pets',
          client.hasPets ? 'Yes (${client.petDetails ?? ""})' : 'No',
          isDark,
        ),
        const SizedBox(height: 12),
        _infoRow(
          'Address',
          '${client.address}, ${client.locality}, ${client.city}',
          isDark,
        ),
        const SizedBox(height: 12),
        _infoRow('Phone', client.phone, isDark),
        if (client.altPhone != null && client.altPhone!.isNotEmpty)
          _infoRow('Alt Phone', client.altPhone!, isDark),
        _infoRow('Email', client.email, isDark),
      ],
    );

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOTES SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notes, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Detailed Notes & Call Logs',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddNoteDialog(context, client),
                  icon: const Icon(Icons.add_call, size: 16),
                  label: Text(
                    'Add Call Note',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppColors.gold, width: 4),
                ),
              ),
              child: Text(
                (client.remarks == null || client.remarks!.isEmpty)
                    ? 'No notes available.'
                    : client.remarks!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.grey300 : AppColors.grey700,
                  // height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
            ),
            const SizedBox(height: 32),
            // TWO COLUMNS: REQUIREMENTS AND DETAILS
            isMobile
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reqColumn,
                    const SizedBox(height: 32),
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.dividerDark : AppColors.grey200,
                    ),
                    const SizedBox(height: 32),
                    detailsColumn,
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: reqColumn),
                    const SizedBox(width: 32),
                    Container(
                      width: 1,
                      height: 250, // Line separator
                      color: isDark ? AppColors.dividerDark : AppColors.grey200,
                    ),
                    const SizedBox(width: 32),
                    Expanded(child: detailsColumn),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContractCard(
    BuildContext context,
    ContractModel contract,
    CandidateModel candidate,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isPending = contract.contractStatus == ContractStatus.pending;
    final primaryColor =
        isPending ? AppColors.standardBlue : AppColors.successGreen;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPending
                      ? 'Pending Placement (Awaiting Drop & Payment)'
                      : 'Active Placement',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                _buildBadge(contract.contractStatus.displayName, primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Text(
              'Candidate Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            candidate.photoUrl.isNotEmpty
                                ? NetworkImage(candidate.photoUrl)
                                : null,
                        child:
                            candidate.photoUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.fullName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${candidate.category} • ${candidate.experienceYears} yrs exp',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        onPressed: () {
                          final authState = context.read<AuthBloc>().state;
                          final routePrefix =
                              ((authState is AuthAuthenticated)
                                              ? (authState).user
                                              : null)
                                          ?.role ==
                                      UserRole.admin
                                  ? '/admin'
                                  : '/sales';
                          context.push(
                            '$routePrefix/candidates/${candidate.id}',
                          );
                        },
                        tooltip: 'View Candidate Profile',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _infoRow('Age', '${candidate.age} yrs', isDark),
                      ),
                      Expanded(
                        child: _infoRow('Religion', candidate.religion, isDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _infoRow(
                          'Salary',
                          candidate.expectedSalary,
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _infoRow(
                          'Hours',
                          '${candidate.workingHoursPerDay} hrs/day',
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _infoRow(
                          'Languages',
                          candidate.languages.join(', '),
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _infoRow(
                          'Medical',
                          candidate.isMedicalCleared ? 'Cleared' : 'Pending',
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Text(
              'Contract & Financials',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Contract ID', contract.id, isDark),
                      _infoRow(
                        'Placement Date',
                        dateFormat.format(contract.placementDate),
                        isDark,
                      ),
                      _infoRow(
                        'Guarantee Ends',
                        dateFormat.format(contract.guaranteeEndDate),
                        isDark,
                      ),
                      if (!isPending) ...[
                        _infoRow(
                          'Days Left',
                          '${contract.daysRemainingInGuarantee} days',
                          isDark,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: contract.daysRemainingInGuarantee / 180,
                          backgroundColor:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            contract.daysRemainingInGuarantee > 30
                                ? AppColors.successGreen
                                : AppColors.urgentAmber,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _infoRow('Created By', contract.createdBy, isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        'Service Fee',
                        '₹${contract.serviceFee}',
                        isDark,
                      ),
                      _infoRow(
                        'Amount Paid',
                        '₹${contract.amountPaid}',
                        isDark,
                      ),
                      _infoRow('Balance', '₹${contract.balanceAmount}', isDark),
                      _infoRow(
                        'Payment Status',
                        contract.paymentStatus.displayName,
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      if (contract.isReplacementUsed) ...[
                        _infoRow(
                          'RePlaced On',
                          contract.replacementDate != null
                              ? dateFormat.format(contract.replacementDate!)
                              : 'N/A',
                          isDark,
                        ),
                        _infoRow(
                          'Replacement ID',
                          contract.replacementCandidateId ?? 'N/A',
                          isDark,
                        ),
                      ],
                      if (contract.remarks != null &&
                          contract.remarks!.isNotEmpty)
                        _infoRow('Remarks', contract.remarks!, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContractState(
    BuildContext context,
    ClientModel client,
    bool isDark,
  ) {
    final candidateState = context.watch<CandidateBloc>().state;
    final allCandidates =
        candidateState is CandidateLoaded
            ? candidateState.candidates
            : <CandidateModel>[];

    // Normalize category match (handling House Maid / House Candidate, Baby Care / Japa Maid, etc.)
    final clientCat =
        client.preferredCandidateCategory
            .toLowerCase()
            .replaceAll('candidate', 'maid')
            .trim();
    final matchingCandidates =
        allCandidates.where((c) {
          final candCat =
              c.category.toLowerCase().replaceAll('candidate', 'maid').trim();
          final matchesCategory =
              candCat == clientCat ||
              (clientCat.contains('house') && candCat.contains('house')) ||
              (clientCat.contains('japa') && candCat.contains('japa')) ||
              (clientCat.contains('baby') &&
                  (candCat.contains('baby') || candCat.contains('japa')));
          return matchesCategory && c.status == CandidateStatus.readyToPlace;
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Requirement Summary & Matching Banner
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_search_outlined,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Target Service: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                        Text(
                          client.preferredCandidateCategory,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildBadge(
                          'Budget: ${client.budgetRange}',
                          AppColors.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review matching candidates from the pool below. You can copy formatted candidate profiles to share with the customer on WhatsApp, or assign a candidate once the deal is ready.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAssignCandidateModal(context, client),
                icon: const Icon(Icons.manage_search, size: 18),
                label: Text(
                  'Search & Assign (${matchingCandidates.length})',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Matching candidates list
        if (matchingCandidates.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Available Matches in Pool (${matchingCandidates.length})',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matchingCandidates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cand = matchingCandidates[index];
              return _buildCandidateMatchCard(context, client, cand, isDark);
            },
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.grey200,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_search_outlined,
                  size: 44,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Direct Matches Ready in "${client.preferredCandidateCategory}"',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You can browse candidates across all categories or assign an available candidate.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAssignCandidateModal(context, client),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Search & Assign Candidate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCandidateMatchCard(
    BuildContext context,
    ClientModel client,
    CandidateModel candidate,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.gold.withValues(alpha: 0.15),
            child: Text(
              candidate.fullName.isNotEmpty ? candidate.fullName[0] : '?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      candidate.fullName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        candidate.id,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge('Ready to Place', AppColors.successGreen),
                    if (candidate.isPoliceVerified) ...[
                      const SizedBox(width: 6),
                      _buildBadge('Police ✓', AppColors.successGreen),
                    ],
                    if (candidate.isMedicalCleared) ...[
                      const SizedBox(width: 6),
                      _buildBadge('Medical ✓', AppColors.successGreen),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '💼 ${candidate.category} (${candidate.experienceYears}y exp)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    Text(
                      '💰 ₹${candidate.expectedSalary}/mo (${candidate.workingHoursPerDay}h/day)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      '🗣️ ${candidate.languages.join(', ')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Actions: Share Profile & Assign
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => _shareCandidateProfile(context, candidate),
                icon: const Icon(Icons.share, size: 16),
                label: Text(
                  'Share Profile',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed:
                    () => _assignCandidateToClient(context, client, candidate),
                icon: const Icon(Icons.handshake, size: 16),
                label: Text(
                  'Assign Candidate',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareCandidateProfile(BuildContext context, CandidateModel candidate) {
    final verificationStatus = [
      if (candidate.aadhaarDocUrl != null) 'Aadhaar Verified',
      if (candidate.isPoliceVerified) 'Police Verified',
      if (candidate.isMedicalCleared) 'Medical Cleared',
    ].join(' • ');

    final workTypeStr = candidate.preferredWorkType ?? candidate.category;
    final languagesStr =
        candidate.languages.isNotEmpty
            ? candidate.languages.join(', ')
            : 'Hindi';

    final summary = '''
🌟 *MaidMatch Candidate Profile*
━━━━━━━━━━━━━━━━━━━━━━
👤 *Name*: ${candidate.fullName} (ID: ${candidate.id})
💼 *Role / Category*: ${candidate.category}
⏱️ *Experience*: ${candidate.experienceYears} Years
🎂 *Age*: ${candidate.age} yrs | 🕊️ *Religion*: ${candidate.religion}
🗣️ *Languages*: $languagesStr
💰 *Expected Salary*: ₹${candidate.expectedSalary}/month (${candidate.workingHoursPerDay} hrs/day)
🛡️ *Verification*: ${verificationStatus.isNotEmpty ? verificationStatus : 'Pending'}
🎯 *Specialization*: $workTypeStr (Edu: ${candidate.education})
━━━━━━━━━━━━━━━━━━━━━━
📞 Contact Sales for immediate placement & trial!
''';

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.navyBlue,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${candidate.fullName}\'s profile copied to clipboard! Ready to share via WhatsApp / SMS.',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _assignCandidateToClient(
    BuildContext context,
    ClientModel client,
    CandidateModel candidate,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _ContractFormDialog(
        client: client,
        candidate: candidate,
      ),
    );
  }

  void _showAssignCandidateModal(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (ctx) => _AssignCandidateSheet(client: client),
    );
  }

  Widget _buildContractActions(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
    CandidateModel candidate,
    bool isDark,
  ) {
    final isPending = contract.contractStatus == ContractStatus.pending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _actionButton(
            'Print / Download Contract',
            Icons.print,
            AppColors.navyBlue,
            isDark,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating contract PDF...')),
              );
              PdfGenerator.generateAndPrintContract(contract, client, candidate);
            },
          ),
          if (isPending) ...[
            _actionButton(
              'Mark Drop Complete & Paid',
              Icons.check_circle,
              AppColors.successGreen,
              isDark,
              () {
                // Simulated action for now
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contract marked as Active!')),
                );
              },
            ),
            _actionButton(
              'Generate Payment Link',
              Icons.link,
              AppColors.standardBlue,
              isDark,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment link copied to clipboard'),
                  ),
                );
              },
            ),
            _actionButton(
              'Cancel Drop',
              Icons.cancel,
              AppColors.criticalRed,
              isDark,
              () {},
            ),
          ] else ...[
            _actionButton(
              'Log Payment',
              Icons.payment,
              AppColors.successGreen,
              isDark,
              () {},
            ),
            _actionButton(
              'Extend Guarantee (+30d)',
              Icons.date_range,
              AppColors.statusInterviewed,
              isDark,
              () {},
            ),
            _actionButton(
              'Initiate Replacement',
              Icons.warning_amber_rounded,
              contract.isReplacementUsed
                  ? AppColors.grey500
                  : AppColors.urgentAmber,
              isDark,
              () {
                if (contract.isReplacementUsed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Max replacements reached')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Replacement ticket generated')),
                );
              },
            ),
            _actionButton(
              'Release to Pool',
              Icons.person_add_alt_1,
              AppColors.navyBlue,
              isDark,
              () {},
            ),
            _actionButton(
              'Mark Job Left',
              Icons.exit_to_app,
              AppColors.grey600,
              isDark,
              () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(
    ClientModel client,
    ContractModel? contract,
    CandidateModel? candidate,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard('Client Documents', isDark, [
          _documentRow('Aadhaar Card / ID Proof', null, isDark, required: true),
          _documentRow('Address Proof', null, isDark, required: false),
        ]),
        const SizedBox(height: 24),
        if (contract != null) ...[
          _buildSectionCard('Contract & Legal Documents', isDark, [
            _documentRow(
              'Service Agreement (Signed)',
              null,
              isDark,
              required: true,
            ),
            _documentRow('Payment Receipt', null, isDark, required: false),
          ]),
          const SizedBox(height: 24),
        ],
        if (candidate != null) ...[
          _buildSectionCard(
            'Candidate Documents (${candidate.fullName})',
            isDark,
            [
              _documentRow(
                'Aadhaar Card',
                candidate.aadhaarDocUrl,
                isDark,
                required: true,
              ),
              _documentRow(
                'Police Verification',
                candidate.policeVerificationDocUrl,
                isDark,
                required: true,
              ),
              _documentRow(
                'Medical Clearance',
                candidate.medicalClearanceDocUrl,
                isDark,
                required: false,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _documentRow(
    String name,
    String? url,
    bool isDark, {
    bool required = false,
  }) {
    final hasDoc = url != null && url.isNotEmpty;
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!hasDoc && required)
                  _buildBadge('Required', AppColors.criticalRed)
                else if (!hasDoc && !required)
                  _buildBadge('Optional', AppColors.grey500),
              ],
            ),
          ),
          if (hasDoc) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                'View',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold),
              ),
            ),
          ] else ...[
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text('Upload', style: GoogleFonts.poppins(fontSize: 12)),
            ),
          ],
        ],
      ),
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

  Widget _buildSectionCard(String title, bool isDark, List<Widget> children) {
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
            const SizedBox(height: 16),
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
            width: 120,
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

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.followUp:
        return AppColors.urgentAmber;
      case ClientStatus.interested:
        return AppColors.infoBlue;
      case ClientStatus.converted:
        return AppColors.successGreen;
      case ClientStatus.notInterested:
        return AppColors.grey500;
      case ClientStatus.inactive:
        throw UnimplementedError();
    }
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // --- Contract History Timeline ---
  Widget _buildContractHistoryTimeline(
    BuildContext context,
    List<ContractModel> contracts,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
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
              Icon(Icons.timeline, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contract History',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${contracts.length} contracts',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contracts.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final isLast = index == contracts.length - 1;

            Color statusColor;
            switch (c.contractStatus) {
              case ContractStatus.active:
                statusColor = AppColors.successGreen;
                break;
              case ContractStatus.rePlaced:
                statusColor = AppColors.urgentAmber;
                break;
              case ContractStatus.completed:
                statusColor = AppColors.grey500;
                break;
              case ContractStatus.cancelled:
                statusColor = AppColors.criticalRed;
                break;
              default:
                statusColor = AppColors.infoBlue;
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline dot and line
                  SizedBox(
                    width: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.darkSurface
                                      : AppColors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color:
                                  isDark
                                      ? AppColors.dividerDark
                                      : AppColors.grey200,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contract card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.grey50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c.id,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.navyBlue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (c.isRenewal)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Renewal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.infoBlue,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  c.contractStatus.displayName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Candidate: ${c.candidateName}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey600,
                            ),
                          ),
                          Text(
                            'Placed: ${dateFormat.format(c.placementDate)} • Warranty: ${c.replacementsUsed}/3',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.grey500
                                      : AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Replacement Requests for this Client ---
  Widget _buildClientReplacements(
    BuildContext context,
    List<ReplacementRequestModel> replacements,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
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
              Icon(Icons.find_replace, color: AppColors.urgentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Replacement Requests',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.urgentAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${replacements.length} requests',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.urgentAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...replacements.map((r) {
            Color statusColor;
            switch (r.status) {
              case ReplacementStatus.pending:
                statusColor = AppColors.urgentAmber;
                break;
              case ReplacementStatus.inProgress:
                statusColor = AppColors.infoBlue;
                break;
              case ReplacementStatus.resolved:
                statusColor = AppColors.successGreen;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Old: ${r.oldCandidateName}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.white
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.reason,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Requested: ${dateFormat.format(r.requestDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color:
                                isDark ? AppColors.grey500 : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      r.status.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Bottom Sheet for Assigning Candidate
class _AssignCandidateSheet extends StatefulWidget {
  final ClientModel client;

  const _AssignCandidateSheet({required this.client});

  @override
  State<_AssignCandidateSheet> createState() => _AssignCandidateSheetState();
}

class _AssignCandidateSheetState extends State<_AssignCandidateSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final candidateState = context.watch<CandidateBloc>().state;
    final allCandidates =
        candidateState is CandidateLoaded
            ? candidateState.candidates
            : <CandidateModel>[];

    // Find candidates ready to place matching the requested category
    var pool =
        allCandidates
            .where(
              (c) =>
                  c.status == CandidateStatus.readyToPlace &&
                  c.category == widget.client.preferredCandidateCategory,
            )
            .toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      pool =
          pool.where((c) {
            return c.fullName.toLowerCase().contains(query) ||
                c.id.toLowerCase().contains(query) ||
                c.phone.contains(query) ||
                (c.altPhone != null && c.altPhone!.contains(query));
          }).toList();
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Candidate to Assign',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or phone...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.grey300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.grey300,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: isDark ? AppColors.white : AppColors.grey900,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child:
                  pool.isEmpty
                      ? Center(
                        child: Text(
                          'No matching candidates found.',
                          style: GoogleFonts.poppins(
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 650;
                          if (isWide) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 82,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: pool.length,
                              itemBuilder: (context, index) {
                                return _buildCompactCandidateCard(
                                  pool[index],
                                  isDark,
                                  context,
                                );
                              },
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pool.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _buildCompactCandidateCard(
                                pool[index],
                                isDark,
                                context,
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCandidateCard(
    CandidateModel candidate,
    bool isDark,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
            child: Text(
              candidate.fullName.isNotEmpty ? candidate.fullName[0] : '?',
              style: const TextStyle(
                color: AppColors.navyBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        candidate.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        candidate.id,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '📞 ${candidate.phone}   •   ₹${candidate.expectedSalary}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${candidate.category} • ${candidate.experienceYears}y exp • ${candidate.education}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (candidate.isMedicalCleared)
                _smallBadge('Medical Verified', AppColors.successGreen)
              else
                _smallBadge('No Medical', AppColors.urgentAmber),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 16),
                    color: AppColors.gold,
                    tooltip: 'Share Candidate Profile',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () => _shareCandidateProfile(context, candidate),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => _ContractFormDialog(
                            client: widget.client,
                            candidate: candidate,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Assign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareCandidateProfile(BuildContext context, CandidateModel candidate) {
    final verificationStatus = [
      if (candidate.aadhaarDocUrl != null) 'Aadhaar Verified',
      if (candidate.isPoliceVerified) 'Police Verified',
      if (candidate.isMedicalCleared) 'Medical Cleared',
    ].join(' • ');

    final workTypeStr = candidate.preferredWorkType ?? candidate.category;
    final languagesStr =
        candidate.languages.isNotEmpty
            ? candidate.languages.join(', ')
            : 'Hindi';

    final summary = '''
🌟 *MaidMatch Candidate Profile*
━━━━━━━━━━━━━━━━━━━━━━
👤 *Name*: ${candidate.fullName} (ID: ${candidate.id})
💼 *Role / Category*: ${candidate.category}
⏱️ *Experience*: ${candidate.experienceYears} Years
🎂 *Age*: ${candidate.age} yrs | 🕊️ *Religion*: ${candidate.religion}
🗣️ *Languages*: $languagesStr
💰 *Expected Salary*: ₹${candidate.expectedSalary}/month (${candidate.workingHoursPerDay} hrs/day)
🛡️ *Verification*: ${verificationStatus.isNotEmpty ? verificationStatus : 'Pending'}
🎯 *Specialization*: $workTypeStr (Edu: ${candidate.education})
━━━━━━━━━━━━━━━━━━━━━━
📞 Contact Sales for immediate placement & trial!
''';

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.navyBlue,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${candidate.fullName}\'s profile copied to clipboard! Ready to share via WhatsApp / SMS.',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _smallBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}


class _ContractFormDialog extends StatefulWidget {
  final ClientModel client;
  final CandidateModel candidate;

  const _ContractFormDialog({
    required this.client,
    required this.candidate,
  });

  @override
  State<_ContractFormDialog> createState() => _ContractFormDialogState();
}

class _ContractFormDialogState extends State<_ContractFormDialog> {
  final _salaryController = TextEditingController();
  final _feeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Parse candidate expected salary to digits
    final matches = RegExp(r'\d+').allMatches(widget.candidate.expectedSalary.replaceAll(',', ''));
    String initialSalary = '15000';
    if (matches.isNotEmpty) {
      initialSalary = matches.first.group(0) ?? '15000';
    }
    _salaryController.text = initialSalary;
    _feeController.text = initialSalary;

    _salaryController.addListener(() {
      _feeController.text = _salaryController.text;
    });
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign ${widget.candidate.fullName}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalize the contract details to assign this candidate.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Summary', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
                  const SizedBox(height: 8),
                  _infoRowDialog('Client:', '${widget.client.fullName} (${widget.client.phone})', isDark),
                  _infoRowDialog('Service:', '${widget.client.serviceType} - ${widget.client.preferredCandidateCategory}', isDark),
                  _infoRowDialog('Candidate:', '${widget.candidate.fullName} (${widget.candidate.category})', isDark),
                  _infoRowDialog('Location:', '${widget.client.locality}, ${widget.client.city}', isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Agreed Salary
            Text(
              'Agreed Monthly Salary (₹)',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 15000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // Service Fee
            Text(
              'Service Fee (₹)',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 15000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // Guarantee
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusInterviewed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.statusInterviewed, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Standard 6-Month Guarantee applies.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.statusInterviewed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final salary = int.tryParse(_salaryController.text) ?? 0;
                    final fee = int.tryParse(_feeController.text) ?? 0;

                    if (salary <= 0 || fee <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid salary and fee')),
                      );
                      return;
                    }

                    final newContract = ContractModel(
                      id: 'PENDING',
                      clientId: widget.client.id,
                      clientName: widget.client.fullName,
                      candidateId: widget.candidate.id,
                      candidateName: widget.candidate.fullName,
                      placementDate: DateTime.now(),
                      guaranteeEndDate: DateTime.now().add(const Duration(days: 180)),
                      contractStatus: ContractStatus.pending,
                      serviceFee: fee.toDouble(),
                      amountPaid: 0,
                      balanceAmount: fee.toDouble(),
                      paymentStatus: PaymentStatus.pending,
                      replacementsUsed: 0,
                      createdBy: 'System',
                    );

                    // Update contract
                    context.read<ContractBloc>().add(CreateContract(newContract));

                    // Update candidate locally
                    final updatedCandidate = widget.candidate.copyWith(
                      status: CandidateStatus.pendingDrop,
                    );
                    context.read<CandidateBloc>().add(UpdateCandidateLocally(updatedCandidate));

                    // Update client locally
                    final updatedClient = widget.client.copyWith(
                      status: ClientStatus.converted,
                    );
                    context.read<ClientBloc>().add(UpdateClientLocally(updatedClient));

                    // Audit log
                    context.read<AuditLogBloc>().add(
                          LogAuditEvent(
                            entityType: 'client',
                            targetId: widget.client.id,
                            actionType: ActionType.statusChange.name,
                            description:
                                'Assigned ${widget.candidate.fullName} (Contract PENDING). Agreed Salary: ₹$salary, Fee: ₹$fee',
                          ),
                        );

                    Navigator.pop(context); // Close the Contract Form
                    Navigator.pop(context); // Close the Assign Candidate Sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Candidate assigned! Pending Contract Generated.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyBlue,
                  ),
                  child: const Text('Generate Contract'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRowDialog(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.navyBlue),
            ),
          ),
        ],
      ),
    );
  }
}
