import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:provider/provider.dart';

class ClientProfileScreen extends StatefulWidget {
  final String clientId;

  const ClientProfileScreen({super.key, required this.clientId});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final client = state.getClient(widget.clientId);
    if (client == null) {
      return const Center(child: Text('Client not found'));
    }

    final contract = state.getContractForClient(client.id);
    final candidate =
        contract != null ? state.getCandidate(contract.candidateId) : null;

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
          _buildUnifiedDetailsCard(context, client, isDark),
        ],
      );
    } else if (_activeTabIndex == 1) {
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
                          color: isDark ? AppColors.white : AppColors.navyBlue,
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
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final currentLocation =
                    GoRouterState.of(context).uri.toString();
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
                  color: (isDark ? AppColors.white : AppColors.navyBlue)
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            if (client.status == ClientStatus.followUp) ...[
              const SizedBox(width: 8),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
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

  Widget _buildUnifiedDetailsCard(
    BuildContext context,
    ClientModel client,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Service Requirements
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
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
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoRow(
                        'Looking For',
                        client.preferredCandidateCategory,
                        isDark,
                      ),
                      _infoRow('Budget', client.budgetRange, isDark),
                      _infoRow('Source', client.source, isDark),
                      _infoRow(
                        'Inquiry Date',
                        DateFormat('dd MMM yyyy').format(client.inquiryDate),
                        isDark,
                      ),
                      if (client.assignedEmployeeId != null)
                        _infoRow(
                          'Sales Rep ID',
                          client.assignedEmployeeId!,
                          isDark,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Container(
                  width: 1,
                  height: 250, // Line separator
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
                const SizedBox(width: 32),
                // Column 2: Household Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 20,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Household & Contact Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoRow('House Type', client.houseType, isDark),
                      _infoRow(
                        'Family Size',
                        '${client.familySize} Members',
                        isDark,
                      ),
                      _infoRow(
                        'Has Children',
                        client.hasChildren
                            ? 'Yes (${client.childrenCount})'
                            : 'No',
                        isDark,
                      ),
                      _infoRow(
                        'Has Elderly',
                        client.hasElderlyMembers ? 'Yes' : 'No',
                        isDark,
                      ),
                      _infoRow(
                        'Has Pets',
                        client.hasPets
                            ? 'Yes (${client.petDetails ?? ""})'
                            : 'No',
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
                      if (client.altPhone != null &&
                          client.altPhone!.isNotEmpty)
                        _infoRow('Alt Phone', client.altPhone!, isDark),
                      _infoRow('Email', client.email, isDark),
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
                        onPressed:
                            () =>
                                context.go('/sales/candidates/${candidate.id}'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
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
}

// Bottom Sheet for Assigning Candidate
class _AssignCandidateSheet extends StatelessWidget {
  final ClientModel client;

  const _AssignCandidateSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find candidates ready to place matching the requested category
    final pool =
        state.candidates
            .where(
              (c) =>
                  c.status == CandidateStatus.readyToPlace &&
                  c.category == client.preferredCandidateCategory,
            )
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
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
          const Divider(height: 1),
          Expanded(
            child:
                pool.isEmpty
                    ? const Center(
                      child: Text(
                        'No matching candidates found in Ready to Place pool.',
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: pool.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final candidate = pool[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isDark
                                      ? AppColors.dividerDark
                                      : AppColors.grey200,
                            ),
                          ),
                          color:
                              isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.navyBlue.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                candidate.fullName[0],
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  candidate.fullName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (candidate.isMedicalCleared)
                                  _smallBadge(
                                    'Medical Verified',
                                    AppColors.successGreen,
                                  )
                                else
                                  _smallBadge(
                                    'No Medical',
                                    AppColors.urgentAmber,
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${candidate.category} • ${candidate.experienceYears} yrs exp • ${candidate.expectedSalary}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Assign logic here
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
                              ),
                              child: const Text('Assign'),
                            ),
                          ),
                        );
                      },
                    ),
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
