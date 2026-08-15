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
import 'package:practice_app/models/urgent_hire_model.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_bloc.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_event.dart';
import 'package:practice_app/core/service_constants.dart';
import 'package:practice_app/core/category_constants.dart';

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
                    if (clientState is ClientError) {
                      return Scaffold(
                        body: Center(
                          child: Text('Error: ${clientState.message}'),
                        ),
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

                    if (clientState is! ClientLoaded ||
                        contractState is! ContractLoaded ||
                        candidateState is! CandidateLoaded) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

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

                      final relevantLogs =
                          auditLogState is AuditLogLoaded
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
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 920;

        final actionButtons = Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (client.status == ClientStatus.followUp) ...[
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
            child: isCompact
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
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12,
                                  runSpacing: 6,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      actionButtons,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 6,
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
                      const SizedBox(width: 16),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: actionButtons,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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
                context.read<AuditLogBloc>().add(const LoadAuditLogs());

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
                context.read<AuditLogBloc>().add(const LoadAuditLogs());

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
        if (client.contractDuration.isNotEmpty)
          _infoRow('Contract Duration', client.contractDuration, isDark),
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
        // if (client.remarks != null && client.remarks!.isNotEmpty)
        //   _infoRow('Remarks', client.remarks!, isDark),
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
                      ? 'Pending Placement (Awaiting Drop, Contract Signing & Payment)'
                      : 'Active Placement (Contract Executed)',
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
                        child: _infoRow(
                          'Expected Salary',
                          candidate.expectedSalary,
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _infoRow(
                          'Experience',
                          '${candidate.experienceYears} yrs',
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _infoRow(
                          'Location',
                          '${candidate.city}, ${candidate.state}',
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _infoRow(
                          'Verification',
                          (candidate.isPoliceVerified &&
                                  candidate.isMedicalCleared)
                              ? 'Police & Medical ✓'
                              : (candidate.isPoliceVerified
                                  ? 'Police ✓'
                                  : (candidate.isMedicalCleared
                                      ? 'Medical ✓'
                                      : 'Pending')),
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
                      _infoRow(
                        'Contract ID',
                        isPending ? '${contract.id} (Draft)' : contract.id,
                        isDark,
                      ),
                      _infoRow(
                        isPending ? 'Drop Scheduled' : 'Placement Date',
                        dateFormat.format(contract.placementDate),
                        isDark,
                      ),
                      _infoRow(
                        isPending ? 'Guarantee Terms' : 'Guarantee Ends',
                        isPending
                            ? '6 Months (Starts upon Joining)'
                            : dateFormat.format(contract.guaranteeEndDate),
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
                          value: (contract.daysRemainingInGuarantee / 180).clamp(
                            0.0,
                            1.0,
                          ),
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
                      ] else ...[
                        _infoRow(
                          'Placement Status',
                          'Pending Drop / Trial (Warranty Paused)',
                          isDark,
                        ),
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
                        '₹${contract.serviceFee.toStringAsFixed(0)}',
                        isDark,
                      ),
                      _infoRow(
                        'Amount Paid',
                        '₹${contract.amountPaid.toStringAsFixed(0)}',
                        isDark,
                      ),
                      _infoRow(
                        'Balance',
                        '₹${(contract.serviceFee - contract.amountPaid).clamp(0.0, double.infinity).toStringAsFixed(0)}',
                        isDark,
                      ),
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                              client.preferredCandidateCategory.isNotEmpty
                                  ? client.preferredCandidateCategory
                                  : 'Not specified',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark ? AppColors.white : AppColors.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        if (client.budgetRange.isNotEmpty)
                          _buildBadge(
                            'Budget: ${client.budgetRange}',
                            AppColors.gold,
                          ),
                        if (client.serviceType.isNotEmpty ||
                            client.workTimings.isNotEmpty)
                          _buildBadge(
                            client.serviceType.isNotEmpty
                                ? client.serviceType
                                : client.workTimings,
                            AppColors.standardBlue,
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
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showRequestMaidModal(context, client, isDark),
                    icon: const Icon(Icons.flash_on, size: 16),
                    label: const Text('Request Maid'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.criticalRed,
                      side: const BorderSide(color: AppColors.criticalRed),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
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
          ...matchingCandidates.take(10).map((cand) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCandidateMatchCard(context, client, cand, isDark),
            );
          }),
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
                  'Submit an urgent sourcing request to our Sourcing team, or browse all available candidates.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showRequestMaidModal(context, client, isDark),
                      icon: const Icon(Icons.flash_on, size: 18),
                      label: const Text('Request Maid (Urgent Hire)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.criticalRed,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showAssignCandidateModal(context, client),
                      icon: const Icon(Icons.person_search, size: 18),
                      label: const Text('Search & Assign Available'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? AppColors.gold : AppColors.navyBlue,
                        side: BorderSide(
                          color: isDark ? AppColors.gold : AppColors.navyBlue,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
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
                    if (candidate.education.isNotEmpty)
                      Text(
                        '🎓 ${candidate.education}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey300 : AppColors.grey700,
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
      builder:
          (ctx) => _ContractFormDialog(client: client, candidate: candidate),
    );
  }

  void _showAssignCandidateModal(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (ctx) => _AssignCandidateSheet(client: client),
    );
  }

  void _showRequestMaidModal(
    BuildContext context,
    ClientModel client,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _RequestMaidDialog(client: client, isDark: isDark),
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
              PdfGenerator.generateAndPrintContract(
                contract,
                client,
                candidate,
              );
            },
          ),
          if (isPending) ...[
            _actionButton(
              'Mark Drop Complete & Activate Contract',
              Icons.check_circle,
              AppColors.successGreen,
              isDark,
              () => _showActivateContractModal(
                context,
                contract,
                client,
                candidate,
              ),
            ),
            _actionButton(
              'Change Candidate',
              Icons.swap_horiz,
              AppColors.gold,
              isDark,
              () => _showChangeCandidateModal(
                context,
                contract,
                client,
                candidate,
              ),
            ),
            _actionButton(
              'Generate Payment Link',
              Icons.link,
              AppColors.standardBlue,
              isDark,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment link & QR copied to clipboard'),
                  ),
                );
              },
            ),
            _actionButton(
              'Cancel Drop',
              Icons.cancel,
              AppColors.criticalRed,
              isDark,
              () => _showCancelDropConfirmation(
                context,
                contract,
                client,
                candidate,
              ),
            ),
          ] else ...[
            _actionButton(
              'Log Payment',
              Icons.payment,
              AppColors.successGreen,
              isDark,
              () => _showLogPaymentModal(context, contract, client),
            ),
            _actionButton(
              'Extend Guarantee (+30d)',
              Icons.date_range,
              AppColors.statusInterviewed,
              isDark,
              () => _showExtendGuaranteeModal(context, contract),
            ),
            _actionButton(
              'Initiate Replacement',
              Icons.warning_amber_rounded,
              contract.replacementsUsed >= 3
                  ? AppColors.grey500
                  : AppColors.urgentAmber,
              isDark,
              () => _showInitiateReplacementModal(
                context,
                contract,
                client,
                candidate,
              ),
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
              () => _showMarkJobLeftModal(context, contract, candidate),
            ),
          ],
        ],
      ),
    );
  }

  void _showActivateContractModal(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
    CandidateModel candidate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime joiningDate = DateTime.now();
    final remainingBalance = (contract.serviceFee - contract.amountPaid).clamp(
      0.0,
      double.infinity,
    );
    final paymentCtrl = TextEditingController(
      text: remainingBalance > 0 ? remainingBalance.toStringAsFixed(0) : '0',
    );
    String paymentMode = 'UPI / Online';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final dateFormat = DateFormat('dd MMM yyyy');
          return Dialog(
            backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.successGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Activate Contract & Complete Drop',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _infoRowDialog('Client', client.fullName, isDark),
                        _infoRowDialog(
                          'Candidate',
                          '${candidate.fullName} (${candidate.category})',
                          isDark,
                        ),
                        _infoRowDialog(
                          'Total Fee',
                          '₹${contract.serviceFee.toStringAsFixed(0)}',
                          isDark,
                        ),
                        _infoRowDialog(
                          'Already Paid',
                          '₹${contract.amountPaid.toStringAsFixed(0)}',
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Actual Joining Date',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: joiningDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
                      );
                      if (picked != null) {
                        setModalState(() => joiningDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(joiningDate),
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Collected (₹)',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: paymentCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Mode',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: paymentMode,
                              items:
                                  [
                                    'UPI / Online',
                                    'Cash',
                                    'Bank Transfer / NEFT',
                                    'Cheque',
                                  ]
                                      .map(
                                        (mode) => DropdownMenuItem(
                                          value: mode,
                                          child: Text(
                                            mode,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => paymentMode = val);
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Executive Notes (Optional)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesCtrl,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Maid dropped safely, agreement signed physically by client.',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          final newlyPaid =
                              double.tryParse(paymentCtrl.text) ?? 0.0;
                          final totalPaid = contract.amountPaid + newlyPaid;
                          final newBalance = (contract.serviceFee - totalPaid)
                              .clamp(0.0, double.infinity);
                          PaymentStatus newPayStatus = PaymentStatus.pending;
                          if (newBalance <= 0) {
                            newPayStatus = PaymentStatus.paid;
                          } else if (totalPaid > 0) {
                            newPayStatus = PaymentStatus.partial;
                          }

                          final guaranteeDays =
                              client.contractDuration == '3 Months'
                                  ? 45
                                  : (client.contractDuration == '6 Months'
                                      ? 90
                                      : 180);
                          final contractDays =
                              client.contractDuration == '3 Months'
                                  ? 90
                                  : (client.contractDuration == '6 Months'
                                      ? 180
                                      : 365);

                          final updatedContract = contract.copyWith(
                            contractStatus: ContractStatus.active,
                            placementDate: joiningDate,
                            guaranteeEndDate: joiningDate.add(
                              Duration(days: guaranteeDays),
                            ),
                            contractEndDate: joiningDate.add(
                              Duration(days: contractDays),
                            ),
                            amountPaid: totalPaid,
                            balanceAmount: newBalance,
                            paymentStatus: newPayStatus,
                            remarks:
                                notesCtrl.text.isNotEmpty
                                    ? notesCtrl.text
                                    : contract.remarks,
                          );

                          // Update contract in bloc
                          context.read<ContractBloc>().add(
                            UpdateContract(updatedContract),
                          );

                          // Update candidate to placed
                          final updatedCandidate = candidate.copyWith(
                            status: CandidateStatus.placed,
                          );
                          context.read<CandidateBloc>().add(
                            UpdateCandidateLocally(updatedCandidate),
                          );

                          // Log Audit Event
                          context.read<AuditLogBloc>().add(
                            LogAuditEvent(
                              entityType: 'contract',
                              targetId: contract.id,
                              actionType: 'activate_contract',
                              description:
                                  'Contract activated on drop. Candidate: ${candidate.fullName}, Paid: ₹${newlyPaid.toStringAsFixed(0)} via $paymentMode.',
                            ),
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.successGreen,
                              content: Text(
                                '🎉 Candidate successfully placed! Contract is now ACTIVE and warranty timer started.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirm & Activate Contract'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showChangeCandidateModal(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
    CandidateModel currentCandidate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<CandidateBloc, CandidateState>(
            builder: (context, candState) {
              final candidates =
                  candState is CandidateLoaded
                      ? candState.candidates
                          .where(
                            (c) =>
                                c.status == CandidateStatus.readyToPlace &&
                                c.id != currentCandidate.id,
                          )
                          .toList()
                      : <CandidateModel>[];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: AppColors.gold,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Change / Reassign Candidate (Trial Swap)',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pre-placement swap: No replacement warranty will be consumed since contract is still pending.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? AppColors.grey200
                                      : AppColors.navyBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available Candidates in Pool',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (candidates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No other available candidates in pool right now.\nYou can request a new candidate from the Sourcing team.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final cand = candidates[idx];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.gold.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                cand.fullName.isNotEmpty
                                    ? cand.fullName[0]
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              cand.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${cand.category} • ${cand.experienceYears} yrs exp • ${cand.city}',
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Reassign candidate in pending contract
                                final updatedContract = contract.copyWith(
                                  candidateId: cand.id,
                                  candidateName: cand.fullName,
                                );
                                context.read<ContractBloc>().add(
                                  UpdateContract(updatedContract),
                                );

                                // Release current candidate back to available pool
                                final releasedCand = currentCandidate.copyWith(
                                  status: CandidateStatus.readyToPlace,
                                );
                                context.read<CandidateBloc>().add(
                                  UpdateCandidateLocally(releasedCand),
                                );

                                // Set new candidate to pending drop
                                final newCandAssigned = cand.copyWith(
                                  status: CandidateStatus.pendingDrop,
                                );
                                context.read<CandidateBloc>().add(
                                  UpdateCandidateLocally(newCandAssigned),
                                );

                                // Log Audit
                                context.read<AuditLogBloc>().add(
                                  LogAuditEvent(
                                    entityType: 'client',
                                    targetId: client.id,
                                    actionType: 'change_candidate_trial',
                                    description:
                                        'Trial candidate changed from ${currentCandidate.fullName} to ${cand.fullName}. Zero warranty consumed.',
                                  ),
                                );

                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.navyBlue,
                                    content: Text(
                                      'Candidate changed to ${cand.fullName} for drop/trial.',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.navyBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Select',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCancelDropConfirmation(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
    CandidateModel candidate,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel Candidate Drop?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will cancel the scheduled drop for ${candidate.fullName}, return the candidate back to the pool, and revert ${client.fullName} back to Interested.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Scheduled'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update contract to cancelled
              final updatedContract = contract.copyWith(
                contractStatus: ContractStatus.cancelled,
              );
              context.read<ContractBloc>().add(
                UpdateContract(updatedContract),
              );

              // Return candidate to available pool
              final updatedCand = candidate.copyWith(
                status: CandidateStatus.readyToPlace,
              );
              context.read<CandidateBloc>().add(
                UpdateCandidateLocally(updatedCand),
              );

              // Revert client to interested
              final updatedClient = client.copyWith(
                status: ClientStatus.interested,
              );
              context.read<ClientBloc>().add(
                UpdateClientLocally(updatedClient),
              );

              // Audit log
              context.read<AuditLogBloc>().add(
                LogAuditEvent(
                  entityType: 'client',
                  targetId: client.id,
                  actionType: 'cancel_drop',
                  description:
                      'Candidate drop cancelled for ${candidate.fullName}. Client reverted to Interested.',
                ),
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Candidate drop cancelled. Client moved back to Interested.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Drop'),
          ),
        ],
      ),
    );
  }

  void _showLogPaymentModal(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingBalance = (contract.serviceFee - contract.amountPaid).clamp(
      0.0,
      double.infinity,
    );
    final amountCtrl = TextEditingController(
      text: remainingBalance.toStringAsFixed(0),
    );
    String paymentMode = 'UPI / Online';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.payment,
                            color: AppColors.successGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Log Payment / Installment',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _infoRowDialog(
                          'Service Fee',
                          '₹${contract.serviceFee.toStringAsFixed(0)}',
                          isDark,
                        ),
                        _infoRowDialog(
                          'Already Paid',
                          '₹${contract.amountPaid.toStringAsFixed(0)}',
                          isDark,
                        ),
                        _infoRowDialog(
                          'Current Balance',
                          '₹${remainingBalance.toStringAsFixed(0)}',
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Amount (₹)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Payment Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: paymentMode,
                    items:
                        [
                          'UPI / Online',
                          'Cash',
                          'Bank Transfer / NEFT',
                          'Cheque',
                        ]
                            .map(
                              (mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(
                                  mode,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentMode = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Reference / Transaction ID',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesCtrl,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g. UPI Ref #439281920',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final newlyPaid =
                              double.tryParse(amountCtrl.text) ?? 0.0;
                          final totalPaid = contract.amountPaid + newlyPaid;
                          final newBalance = (contract.serviceFee - totalPaid)
                              .clamp(0.0, double.infinity);
                          PaymentStatus newPayStatus =
                              newBalance <= 0
                                  ? PaymentStatus.paid
                                  : PaymentStatus.partial;

                          final updatedContract = contract.copyWith(
                            amountPaid: totalPaid,
                            balanceAmount: newBalance,
                            paymentStatus: newPayStatus,
                          );
                          context.read<ContractBloc>().add(
                            UpdateContract(updatedContract),
                          );

                          context.read<AuditLogBloc>().add(
                            LogAuditEvent(
                              entityType: 'contract',
                              targetId: contract.id,
                              actionType: 'log_payment',
                              description:
                                  'Logged payment of ₹${newlyPaid.toStringAsFixed(0)} via $paymentMode. New balance: ₹${newBalance.toStringAsFixed(0)}.',
                            ),
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.successGreen,
                              content: Text(
                                'Payment of ₹${newlyPaid.toStringAsFixed(0)} logged successfully!',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Payment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showExtendGuaranteeModal(
    BuildContext context,
    ContractModel contract,
  ) {
    final newEndDate = contract.guaranteeEndDate.add(const Duration(days: 30));
    final dateFormat = DateFormat('dd MMM yyyy');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Extend Guarantee by +30 Days',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Current Guarantee End: ${dateFormat.format(contract.guaranteeEndDate)}\nNew Guarantee End: ${dateFormat.format(newEndDate)}\n\nDo you want to extend this contract warranty by 30 days?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = contract.copyWith(
                guaranteeEndDate: newEndDate,
              );
              context.read<ContractBloc>().add(UpdateContract(updated));
              context.read<AuditLogBloc>().add(
                LogAuditEvent(
                  entityType: 'contract',
                  targetId: contract.id,
                  actionType: 'extend_guarantee',
                  description:
                      'Guarantee extended by +30 days to ${dateFormat.format(newEndDate)}.',
                ),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guarantee successfully extended by +30 days!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusInterviewed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Extend Guarantee'),
          ),
        ],
      ),
    );
  }

  void _showInitiateReplacementModal(
    BuildContext context,
    ContractModel contract,
    ClientModel client,
    CandidateModel currentCandidate,
  ) {
    if (contract.replacementsUsed >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.criticalRed,
          content: Text(
            'Maximum free replacements (3/3) already utilized for this 1-year contract.',
          ),
        ),
      );
      return;
    }

    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.urgentAmber,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Initiate Replacement (${contract.replacementsUsed + 1}/3)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Candidate: ${currentCandidate.fullName} (${currentCandidate.category})\nRemaining Replacements: ${3 - contract.replacementsUsed} of 3 free',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 14),
            Text(
              'Reason for Replacement',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 12),
              decoration: InputDecoration(
                hintText:
                    'e.g. Candidate not keeping up with cooking style / requested replacement.',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedContract = contract.copyWith(
                contractStatus: ContractStatus.rePlaced,
                isReplacementUsed: true,
                replacementsUsed: contract.replacementsUsed + 1,
                replacementDate: DateTime.now(),
                remarks:
                    reasonCtrl.text.isNotEmpty
                        ? reasonCtrl.text
                        : contract.remarks,
              );
              context.read<ContractBloc>().add(
                UpdateContract(updatedContract),
              );

              // Mark current candidate as ready to place
              final updatedCand = currentCandidate.copyWith(
                status: CandidateStatus.readyToPlace,
              );
              context.read<CandidateBloc>().add(
                UpdateCandidateLocally(updatedCand),
              );

              context.read<AuditLogBloc>().add(
                LogAuditEvent(
                  entityType: 'contract',
                  targetId: contract.id,
                  actionType: 'initiate_replacement',
                  description:
                      'Replacement initiated (${contract.replacementsUsed + 1}/3). Reason: ${reasonCtrl.text}',
                ),
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.urgentAmber,
                  content: Text(
                    'Replacement ticket created! Sourcing team alerted to find a match.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgentAmber,
              foregroundColor: AppColors.navyBlue,
            ),
            child: const Text('Confirm Replacement Request'),
          ),
        ],
      ),
    );
  }

  void _showMarkJobLeftModal(
    BuildContext context,
    ContractModel contract,
    CandidateModel candidate,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Mark Staff Job Left?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will record that ${candidate.fullName} has left the position with this client.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCand = candidate.copyWith(
                status: CandidateStatus.readyToPlace,
              );
              context.read<CandidateBloc>().add(
                UpdateCandidateLocally(updatedCand),
              );

              context.read<AuditLogBloc>().add(
                LogAuditEvent(
                  entityType: 'candidate',
                  targetId: candidate.id,
                  actionType: 'job_left',
                  description:
                      '${candidate.fullName} marked as left job for Contract ${contract.id}.',
                ),
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Staff marked as Left. Candidate returned to available pool.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
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
    Color effectiveFgColor = color;
    if (isDark) {
      if (color == AppColors.navyBlue || color == AppColors.grey600) {
        effectiveFgColor = Colors.white;
      }
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (isDark && color == AppColors.navyBlue)
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.1),
        foregroundColor: effectiveFgColor,
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

  Widget _infoRowDialog(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue,
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
                          Builder(
                            builder: (ctx) {
                              String displayCandidateName = c.candidateName;
                              if (displayCandidateName == 'Unknown Candidate') {
                                final candidateState =
                                    ctx.read<CandidateBloc>().state;
                                if (candidateState is CandidateLoaded) {
                                  final matchingCand =
                                      candidateState.candidates
                                          .where(
                                            (cand) => cand.id == c.candidateId,
                                          )
                                          .firstOrNull;
                                  if (matchingCand != null) {
                                    displayCandidateName =
                                        matchingCand.fullName;
                                  }
                                }
                              }
                              return Text(
                                'Candidate: $displayCandidateName',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      isDark
                                          ? AppColors.grey400
                                          : AppColors.grey600,
                                ),
                              );
                            },
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
                          builder:
                              (ctx) => _ContractFormDialog(
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

  const _ContractFormDialog({required this.client, required this.candidate});

  @override
  State<_ContractFormDialog> createState() => _ContractFormDialogState();
}

class _ContractFormDialogState extends State<_ContractFormDialog> {
  final _salaryController = TextEditingController();
  final _feeController = TextEditingController();
  String _paymentOption = 'half';

  @override
  void initState() {
    super.initState();
    // Parse candidate expected salary to digits
    final matches = RegExp(
      r'\d+',
    ).allMatches(widget.candidate.expectedSalary.replaceAll(',', ''));
    String initialSalary = '15000';
    if (matches.isNotEmpty) {
      initialSalary = matches.first.group(0) ?? '15000';
    }
    _salaryController.text = initialSalary;
    _feeController.text = initialSalary;

    _salaryController.addListener(() {
      _feeController.text = _salaryController.text;
    });
    _feeController.addListener(() {
      setState(() {});
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

    final fee = double.tryParse(_feeController.text) ?? 0.0;
    final gst = fee * 0.18;
    final totalAmount = fee + gst;

    String guaranteeText = 'Standard 6-Month Guarantee applies.';
    if (widget.client.contractDuration == '3 Months') {
      guaranteeText = 'Standard 45-Day Guarantee applies.';
    } else if (widget.client.contractDuration == '6 Months') {
      guaranteeText = 'Standard 3-Month Guarantee applies.';
    }

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
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRowDialog(
                    'Client:',
                    '${widget.client.fullName} (${widget.client.phone})',
                    isDark,
                  ),
                  _infoRowDialog(
                    'Duration:',
                    widget.client.contractDuration,
                    isDark,
                  ),
                  _infoRowDialog(
                    'Service:',
                    '${widget.client.serviceType} - ${widget.client.preferredCandidateCategory}',
                    isDark,
                  ),
                  _infoRowDialog(
                    'Candidate:',
                    '${widget.candidate.fullName} (${widget.candidate.category})',
                    isDark,
                  ),
                  _infoRowDialog(
                    'Experience:',
                    '${widget.candidate.experienceYears} Years',
                    isDark,
                  ),
                  _infoRowDialog(
                    'Verification:',
                    'Police: ${widget.candidate.isPoliceVerified ? 'Yes' : 'No'} | Medical: ${widget.candidate.isMedicalCleared ? 'Yes' : 'No'}',
                    isDark,
                  ),
                  _infoRowDialog(
                    'Location:',
                    '${widget.client.locality}, ${widget.client.city}',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Agreed Salary
            // Text(
            //   'Agreed Monthly Salary (₹)',
            //   style: GoogleFonts.poppins(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // TextFormField(
            //   controller: _salaryController,
            //   keyboardType: TextInputType.number,
            //   decoration: InputDecoration(
            //     hintText: 'e.g. 15000',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Service Fee
            Text(
              'Service Fee (₹)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 15000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // GST & Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '+ 18% GST',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      Text(
                        '₹${gst.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Initial Payment Collection',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _paymentOption,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'half',
                  child: Text(
                    '1st Installment Paid (50% - ₹${(totalAmount / 2).toStringAsFixed(0)})',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'full',
                  child: Text(
                    'Full Payment Paid (100% - ₹${totalAmount.toStringAsFixed(0)})',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'no_payment',
                  child: Text(
                    'No Payment for Now (Pay on Candidate Drop - ₹0)',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'pending',
                  child: Text(
                    'Payment Pending (₹0)',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentOption = val);
              },
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
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.statusInterviewed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    guaranteeText,
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
                        const SnackBar(
                          content: Text('Please enter valid salary and fee'),
                        ),
                      );
                      return;
                    }

                    final totalAmount = fee + (fee * 0.18);

                    DateTime calcEndDate(String duration) {
                      final now = DateTime.now();
                      if (duration == '3 Months') {
                        return DateTime(now.year, now.month + 3, now.day);
                      }
                      if (duration == '6 Months') {
                        return DateTime(now.year, now.month + 6, now.day);
                      }
                      return DateTime(now.year + 1, now.month, now.day);
                    }

                    DateTime calcGuaranteeEndDate(String duration) {
                      final now = DateTime.now();
                      if (duration == '3 Months') {
                        return now.add(const Duration(days: 45));
                      }
                      if (duration == '6 Months') {
                        return now.add(const Duration(days: 90));
                      }
                      return now.add(const Duration(days: 180));
                    }

                    double initialPaid = 0;
                    PaymentStatus payStatus = PaymentStatus.pending;
                    if (_paymentOption == 'half') {
                      initialPaid = (totalAmount / 2).roundToDouble();
                      payStatus = PaymentStatus.partial;
                    } else if (_paymentOption == 'full') {
                      initialPaid = totalAmount;
                      payStatus = PaymentStatus.paid;
                    } else {
                      initialPaid = 0;
                      payStatus = PaymentStatus.pending;
                    }

                    final isImmediatePaid = _paymentOption == 'full';
                    final contractStatus =
                        isImmediatePaid
                            ? ContractStatus.active
                            : ContractStatus.pending;

                    final newContract = ContractModel(
                      id: 'PENDING',
                      clientId: widget.client.id,
                      clientName: widget.client.fullName,
                      candidateId: widget.candidate.id,
                      candidateName: widget.candidate.fullName,
                      placementDate: DateTime.now(),
                      contractEndDate: calcEndDate(
                        widget.client.contractDuration,
                      ),
                      guaranteeEndDate: calcGuaranteeEndDate(
                        widget.client.contractDuration,
                      ),
                      contractStatus: contractStatus,
                      serviceFee: totalAmount,
                      amountPaid: initialPaid,
                      balanceAmount: totalAmount - initialPaid,
                      paymentStatus: payStatus,
                      replacementsUsed: 0,
                      createdBy: 'System',
                    );

                    // Update contract
                    context.read<ContractBloc>().add(
                      CreateContract(newContract),
                    );

                    // Update candidate locally
                    final updatedCandidate = widget.candidate.copyWith(
                      status: CandidateStatus.pendingDrop,
                      expectedSalary: '₹$salary',
                    );
                    context.read<CandidateBloc>().add(
                      UpdateCandidateLocally(updatedCandidate),
                    );

                    // Update client locally
                    final updatedClient = widget.client.copyWith(
                      status: ClientStatus.converted,
                    );
                    context.read<ClientBloc>().add(
                      UpdateClientLocally(updatedClient),
                    );

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
                      const SnackBar(
                        content: Text(
                          'Candidate assigned! Pending Contract Generated.',
                        ),
                      ),
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
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestMaidDialog extends StatefulWidget {
  final ClientModel client;
  final bool isDark;

  const _RequestMaidDialog({
    required this.client,
    required this.isDark,
  });

  @override
  State<_RequestMaidDialog> createState() => _RequestMaidDialogState();
}

class _RequestMaidDialogState extends State<_RequestMaidDialog> {
  late String _category;
  late String _serviceType;
  late String _workTimings;
  late TextEditingController _budgetCtrl;
  late String _expectedJoining;
  late String _foodPreference;
  late String _genderPreference;
  late TextEditingController _languagesCtrl;
  late String _religionPreference;
  String _priority = 'urgent';
  final TextEditingController _notesCtrl = TextEditingController();

  final List<String> _categories = List<String>.from(CategoryConstants.categories);

  @override
  void initState() {
    super.initState();
    _category = _categories.contains(widget.client.preferredCandidateCategory)
        ? widget.client.preferredCandidateCategory
        : (widget.client.preferredCandidateCategory.isNotEmpty
            ? widget.client.preferredCandidateCategory
            : 'House Maid');

    if (!_categories.contains(_category)) {
      _categories.insert(0, _category);
    }

    _serviceType = ServiceConstants.serviceTypes.contains(widget.client.serviceType)
        ? widget.client.serviceType
        : (widget.client.serviceType.isNotEmpty
            ? widget.client.serviceType
            : ServiceConstants.serviceTypes.first);

    _workTimings = ServiceConstants.workTimingPresets.contains(widget.client.workTimings)
        ? widget.client.workTimings
        : (widget.client.workTimings.isNotEmpty
            ? widget.client.workTimings
            : ServiceConstants.workTimingPresets.first);

    _budgetCtrl = TextEditingController(text: widget.client.budgetRange);

    _expectedJoining = ServiceConstants.expectedJoiningOptions.contains(widget.client.expectedJoining)
        ? widget.client.expectedJoining
        : ServiceConstants.expectedJoiningOptions.first;

    _foodPreference = ServiceConstants.foodPreferences.contains(widget.client.foodPreference)
        ? widget.client.foodPreference
        : ServiceConstants.foodPreferences.first;

    _genderPreference = ServiceConstants.genderPreferences.contains(widget.client.genderPreference)
        ? widget.client.genderPreference
        : ServiceConstants.genderPreferences.first;

    _languagesCtrl = TextEditingController(
      text: widget.client.preferredLanguages.isNotEmpty
          ? widget.client.preferredLanguages.join(', ')
          : 'Hindi',
    );

    _religionPreference = ServiceConstants.religionPreferences.contains(widget.client.religionPreference)
        ? widget.client.religionPreference
        : ServiceConstants.religionPreferences.first;
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _languagesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 680,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.criticalRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: AppColors.criticalRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Maid (Urgent Sourcing)',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      Text(
                        'Pre-filled with ${widget.client.fullName}\'s requirements. Sourcing team will prioritize this lead.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Info Summary Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.grey100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Client: ${widget.client.fullName} (${widget.client.id})',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${widget.client.city} • ${widget.client.phone}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.grey400
                                  : AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Selector
                    Text(
                      'Request Priority',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _priorityChip('urgent', '🚨 Urgent Priority', AppColors.criticalRed),
                        const SizedBox(width: 8),
                        _priorityChip('high', '⚡ High Priority', AppColors.gold),
                        const SizedBox(width: 8),
                        _priorityChip('normal', 'Standard', AppColors.standardBlue),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Form Fields Grid
                    if (isMobile) ...[
                      _buildDropdownField(
                        'Target Role / Category',
                        _category,
                        _categories,
                        (v) => setState(() => _category = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        'Service Type / Shift',
                        _serviceType,
                        ServiceConstants.serviceTypes,
                        (v) => setState(() => _serviceType = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        'Work Timings',
                        _workTimings,
                        ServiceConstants.workTimingPresets,
                        (v) => setState(() => _workTimings = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Budget Range',
                        _budgetCtrl,
                        'e.g. ₹20,000 - ₹28,000',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        'Expected Joining Date',
                        _expectedJoining,
                        ServiceConstants.expectedJoiningOptions,
                        (v) => setState(() => _expectedJoining = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        'Food Preference',
                        _foodPreference,
                        ServiceConstants.foodPreferences,
                        (v) => setState(() => _foodPreference = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        'Gender Preference',
                        _genderPreference,
                        ServiceConstants.genderPreferences,
                        (v) => setState(() => _genderPreference = v!),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Preferred Languages',
                        _languagesCtrl,
                        'e.g. Hindi, English, Marathi',
                        isDark,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Target Role / Category',
                              _category,
                              _categories,
                              (v) => setState(() => _category = v!),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              'Service Type / Shift',
                              _serviceType,
                              ServiceConstants.serviceTypes,
                              (v) => setState(() => _serviceType = v!),
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Work Timings',
                              _workTimings,
                              ServiceConstants.workTimingPresets,
                              (v) => setState(() => _workTimings = v!),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Budget Range',
                              _budgetCtrl,
                              'e.g. ₹20,000 - ₹28,000',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Expected Joining Date',
                              _expectedJoining,
                              ServiceConstants.expectedJoiningOptions,
                              (v) => setState(() => _expectedJoining = v!),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              'Food Preference',
                              _foodPreference,
                              ServiceConstants.foodPreferences,
                              (v) => setState(() => _foodPreference = v!),
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Gender Preference',
                              _genderPreference,
                              ServiceConstants.genderPreferences,
                              (v) => setState(() => _genderPreference = v!),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Preferred Languages',
                              _languagesCtrl,
                              'e.g. Hindi, English',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Custom Notes / Instructions for Sourcing
                    Text(
                      'Special Instructions for Sourcing Team (Optional)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Client requires a vegetarian nanny with infant handling experience, willing to join within 2 days.',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey500 : AppColors.grey400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _submitUrgentRequest,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Submit Request to Sourcing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.criticalRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String value, String label, Color color) {
    final isSelected = _priority == value;
    return InkWell(
      onTap: () => setState(() => _priority = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.grey400,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    final effectiveItems = items.contains(value) ? items : [value, ...items];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: effectiveItems
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _submitUrgentRequest() {
    final authState = context.read<AuthBloc>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;

    final urgentHire = UrgentHireModel(
      id: '', // Generated on server
      clientId: widget.client.id,
      clientName: widget.client.fullName,
      clientPhone: widget.client.phone,
      clientCity: widget.client.city,
      requestedById: user?.id,
      requestedByName: user?.name ?? 'Sales Rep',
      category: _category,
      serviceType: _serviceType,
      workTimings: _workTimings,
      budgetRange: _budgetCtrl.text.trim(),
      foodPreference: _foodPreference,
      genderPreference: _genderPreference,
      preferredLanguages: _languagesCtrl.text.trim(),
      religionPreference: _religionPreference,
      expectedJoining: _expectedJoining,
      notes: _notesCtrl.text.trim(),
      priority: _priority,
      status: UrgentHireStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<UrgentHireBloc>().add(CreateUrgentHireEvent(urgentHire));

    // Also trigger audit log
    context.read<AuditLogBloc>().add(
          LogAuditEvent(
            entityType: 'client',
            targetId: widget.client.id,
            actionType: 'request_maid',
            description:
                'Urgent hiring request created for $_category ($_serviceType, Priority: $_priority)',
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.navyBlue,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.flash_on, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🚨 Urgent hiring request sent to Sourcing team for ${widget.client.fullName}!',
                style: GoogleFonts.poppins(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

