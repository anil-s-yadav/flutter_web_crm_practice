import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:provider/provider.dart';

class ClientProfileScreen extends StatelessWidget {
  final String clientId;

  const ClientProfileScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final client = state.getClient(clientId);
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              labelColor: AppColors.gold,
              unselectedLabelColor:
                  isDark ? AppColors.grey400 : AppColors.grey600,
              indicatorColor: AppColors.gold,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Candidates & Contracts'),
                Tab(text: 'Documents'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Details Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClientHeader(client, isDark),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [_buildRequirements(client, isDark)],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [_buildClientDetails(client, isDark)],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Candidates & Contracts Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contract != null && candidate != null) ...[
                        _buildActiveContractCard(
                          context,
                          contract,
                          candidate,
                          isDark,
                        ),
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
                  ),

                  // Documents Tab
                  _buildDocumentsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientHeader(ClientModel client, bool isDark) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements(ClientModel client, bool isDark) {
    return _buildSectionCard('Service Requirements', isDark, [
      _infoRow('Looking For', client.preferredCandidateCategory, isDark),
      _infoRow('Budget', client.budgetRange, isDark),
      const SizedBox(height: 8),
      Text(
        'Required Skills:',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children:
            client.requiredSkills
                .map(
                  (s) => Chip(
                    label: Text(s),
                    labelStyle: GoogleFonts.poppins(fontSize: 11),
                    backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
      ),
    ]);
  }

  Widget _buildClientDetails(ClientModel client, bool isDark) {
    return _buildSectionCard('Household Details', isDark, [
      _infoRow('House Type', client.houseType, isDark),
      _infoRow('Family Size', '${client.familySize} Members', isDark),
      _infoRow(
        'Has Children',
        client.hasChildren ? 'Yes (${client.childrenCount})' : 'No',
        isDark,
      ),
      _infoRow('Has Elderly', client.hasElderlyMembers ? 'Yes' : 'No', isDark),
      _infoRow(
        'Has Pets',
        client.hasPets ? 'Yes (${client.petDetails ?? ""})' : 'No',
        isDark,
      ),
      const Divider(height: 24),
      _infoRow('Phone', client.phone, isDark),
      _infoRow('Email', client.email, isDark),
      _infoRow('Source', client.source, isDark),
    ]);
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.gold),
              ),
              title: Row(
                children: [
                  Text(
                    candidate.fullName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (candidate.isMedicalCleared)
                    _buildBadge('Medical Checked', AppColors.successGreen)
                  else
                    _buildBadge('No Medical', AppColors.urgentAmber),
                ],
              ),
              subtitle: Text(
                candidate.category,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed:
                    () => context.go('/sales/candidates/${candidate.id}'),
                tooltip: 'View Candidate Profile',
              ),
            ),
            const Divider(height: 24),
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
                'Days Left in SLA',
                '${contract.daysRemainingInGuarantee} days',
                isDark,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: contract.daysRemainingInGuarantee / 180,
                backgroundColor:
                    isDark ? AppColors.dividerDark : AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  contract.daysRemainingInGuarantee > 30
                      ? AppColors.successGreen
                      : AppColors.urgentAmber,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    Text(
                      '₹${contract.serviceFee}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Payment Status',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    Text(
                      contract.paymentStatus.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            contract.paymentStatus == PaymentStatus.paid
                                ? AppColors.successGreen
                                : AppColors.criticalRed,
                      ),
                    ),
                  ],
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

  Widget _buildDocumentsTab(bool isDark) {
    return _buildSectionCard('Client Documents', isDark, [
      _documentRow('Aadhaar Card / ID Proof', null, isDark),
      _documentRow('Address Proof', null, isDark),
      _documentRow('Agreement Signoff', null, isDark),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
          foregroundColor: AppColors.navyBlue,
          elevation: 0,
        ),
      ),
    ]);
  }

  Widget _documentRow(String name, String? url, bool isDark) {
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
      case ClientStatus.newInquiry:
        return AppColors.standardBlue;
      case ClientStatus.followUp:
        return AppColors.urgentAmber;
      case ClientStatus.active:
      case ClientStatus.converted:
        return AppColors.successGreen;
      default:
        return AppColors.criticalRed;
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
