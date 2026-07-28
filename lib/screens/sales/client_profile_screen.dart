import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_event.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/blocs/contract/contract_bloc.dart';
import 'package:practice_app/blocs/contract/contract_event.dart';
import 'package:practice_app/blocs/contract/contract_state.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, clientState) {
        return BlocBuilder<ContractBloc, ContractState>(
          builder: (context, contractState) {
            return BlocBuilder<CandidateBloc, CandidateState>(
              builder: (context, candidateState) {
                if (clientState is ClientLoading ||
                    contractState is ContractLoading ||
                    candidateState is CandidateLoading) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                if (clientState is ClientError) {
                  return Scaffold(body: Center(child: Text('Error: ${clientState.message}')));
                }
                if (contractState is ContractError) {
                  return Scaffold(body: Center(child: Text('Error: ${contractState.message}')));
                }
                if (candidateState is CandidateError) {
                  return Scaffold(body: Center(child: Text('Error: ${candidateState.message}')));
                }

                if (clientState is ClientLoaded &&
                    contractState is ContractLoaded &&
                    candidateState is CandidateLoaded) {
                  final clientList = clientState.clients.where((c) => c.id == widget.clientId).toList();
                  if (clientList.isEmpty) {
                    return const Scaffold(body: Center(child: Text('Client not found')));
                  }
                  final client = clientList.first;

                  final contractList = contractState.contracts.where((c) => c.clientId == client.id).toList();
                  contractList.sort((a, b) => b.placementDate.compareTo(a.placementDate));
                  final contract = contractList.isNotEmpty ? contractList.first : null;

                  final candidateList = contract != null
                      ? candidateState.candidates.where((c) => c.id == contract.candidateId).toList()
                      : [];
                  final candidate = candidateList.isNotEmpty ? candidateList.first : null;

                  final relevantLogs =
                      state.auditLogs
                          .where(
                            (log) =>
                                log.targetId == client.id ||
                                (contract != null && log.targetId == contract.id),
                          )
                          .toList();

                  final tabs = ['Details', 'Candidates & Contracts', 'Documents'];

                  return Scaffold(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                                    ? AppColors.textSecondaryDark
                                                    : AppColors.textSecondaryLight),
                                        fontWeight:
                                            isSelected ? FontWeight.w600 : FontWeight.normal,
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
                            padding: const EdgeInsets.all(16),
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

                return const Scaffold(body: Center(child: Text('Unknown state')));
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
      final state = Provider.of<GlobalAppState>(context, listen: false);
      final contractState = context.read<ContractBloc>().state;
      final allContracts = contractState is ContractLoaded ? contractState.contracts : <ContractModel>[];
      
      // All contracts for this client, sorted by date descending
      final allClientContracts =
          allContracts.where((c) => c.clientId == client.id).toList()
            ..sort((a, b) => b.placementDate.compareTo(a.placementDate));
      // Replacement requests for this client
      final clientReplacements =
          state.replacementRequests
              .where((r) => r.clientId == client.id)
              .toList()
            ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contract != null && candidate != null) ...[
            _buildActiveContractCard(context, contract, candidate, isDark),
            const SizedBox(height: 16),
            _buildContractActions(context, contract, isDark),
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
        if (client.status == ClientStatus.followUp) ...[
          ElevatedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.interested,
                  'Client promoted to Interested',
                ),
            icon: const Icon(Icons.arrow_upward, size: 18),
            label: const Text('Promote to Interested'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ] else if (client.status == ClientStatus.interested)
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          )
        else if (client.status == ClientStatus.notInterested)
          ElevatedButton.icon(
            onPressed:
                () => _showStatusChangeDialog(
                  context,
                  client,
                  ClientStatus.followUp,
                  'Client reactivated to Follow Up',
                ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reactivate to Follow Up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
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
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Status Change Note',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please add a note explaining why this client is being moved to ${nextStatus.displayName}.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mandatory Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyBlue,
              ),
              child: Text(
                'Update Status',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                final note = noteController.text.trim();
                if (note.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'A note is absolutely required to change status.',
                      ),
                    ),
                  );
                  return;
                }

                final state = Provider.of<GlobalAppState>(
                  context,
                  listen: false,
                );
                final timestamp = DateFormat(
                  'dd MMM yyyy, HH:mm',
                ).format(DateTime.now());

                final newRemarks =
                    (client.remarks == null || client.remarks!.isEmpty)
                        ? '[$timestamp] Status changed to ${nextStatus.displayName}: $note'
                        : '${client.remarks}\n\n[$timestamp] Status changed to ${nextStatus.displayName}: $note';

                state.updateClient(
                  client.copyWith(status: nextStatus, remarks: newRemarks),
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(successMessage)));
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
        _infoRow('Budget', client.budgetRange, isDark),
        _infoRow('Source', client.source, isDark),
        _infoRow(
          'Inquiry Date',
          DateFormat('dd MMM yyyy').format(client.inquiryDate),
          isDark,
        ),
        if (client.assignedEmployeeId != null)
          _infoRow('Sales Rep ID', client.assignedEmployeeId!, isDark),
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
              children: [
                const Icon(Icons.notes, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Detailed Notes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                  fontSize: 14,
                  color: isDark ? AppColors.grey300 : AppColors.grey700,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 32),
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
                          final state = Provider.of<GlobalAppState>(
                            context,
                            listen: false,
                          );
                          final routePrefix =
                              state.currentUser?.role == UserRole.admin
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search, size: 48, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No Candidate Assigned',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assign a verified candidate to generate a pending contract.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAssignCandidateModal(context, client),
            icon: const Icon(Icons.handshake),
            label: const Text('Assign Candidate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
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
    final allCandidates = candidateState is CandidateLoaded ? candidateState.candidates : <CandidateModel>[];

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
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                    final state = Provider.of<GlobalAppState>(context, listen: false);
                    state.createContract(widget.client, candidate);

                    Navigator.pop(context);
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
