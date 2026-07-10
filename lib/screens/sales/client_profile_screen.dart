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
    final candidate = contract != null ? state.getCandidate(contract.candidateId) : null;

    // Get logs related to this client or their active contract
    final relevantLogs =
        state.auditLogs
            .where(
              (log) =>
                  log.targetId == client.id ||
                  (contract != null && log.targetId == contract.id),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Client Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              TextButton.icon(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                label: Text(
                  'Go Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildClientHeader(client, isDark),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildRequirements(client, isDark),
                      const SizedBox(height: 16),
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
                        _buildEmptyContractState(isDark),
                      ],
                    ],
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
            const SizedBox(height: 32),
            AuditLogWidget(
              logs: relevantLogs,
              title: 'Client & Contract History',
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.successGreen.withValues(alpha: 0.3)),
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
                  'Active Placement',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
                _buildBadge(
                  contract.paymentStatus.displayName,
                  contract.paymentStatus == PaymentStatus.paid
                      ? AppColors.successGreen
                      : AppColors.urgentAmber,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.gold),
              ),
              title: Text(
                candidate.fullName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                candidate.category,
                style: GoogleFonts.poppins(fontSize: 12),
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
            _infoRow(
              'Days Left in SLA',
              '${contract.daysRemainingInGuarantee} days',
              isDark,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value:
                  contract.daysRemainingInGuarantee /
                  180, // Assuming 6 month standard
              backgroundColor:
                  isDark ? AppColors.dividerDark : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                contract.daysRemainingInGuarantee > 30
                    ? AppColors.successGreen
                    : AppColors.urgentAmber,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
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
                      'Balance Due',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    Text(
                      '₹${contract.balanceAmount}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            contract.balanceAmount > 0
                                ? AppColors.criticalRed
                                : AppColors.successGreen,
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

  Widget _buildEmptyContractState(bool isDark) {
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
          const Icon(
            Icons.description_outlined,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Contract',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This client does not have a placed candidate currently.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractActions(
    BuildContext context,
    ContractModel contract,
    bool isDark,
  ) {
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
            'Log Payment',
            Icons.payment,
            AppColors.successGreen,
            isDark,
            () {
              // Log Payment logic
              if (contract.balanceAmount > 0) {
                Provider.of<GlobalAppState>(
                  context,
                  listen: false,
                ).updateContractPayment(contract.id, contract.balanceAmount);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment logged successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contract is already fully paid'),
                  ),
                );
              }
            },
          ),
          _actionButton(
            'Extend Guarantee (+30d)',
            Icons.date_range,
            AppColors.statusInterviewed,
            isDark,
            () {
              // Extend Guarantee logic
              Provider.of<GlobalAppState>(
                context,
                listen: false,
              ).extendContractGuarantee(contract.id, 30);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guarantee extended by 30 days')),
              );
            },
          ),
          _actionButton(
            'Initiate Replacement',
            Icons.warning_amber_rounded,
            AppColors.urgentAmber,
            isDark,
            () {
              // SLA logic
              Provider.of<GlobalAppState>(
                context,
                listen: false,
              ).initiateReplacement(
                contract.id,
                "Client requested replacement due to performance issues.",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Replacement ticket generated for Sourcing Team',
                  ),
                ),
              );
            },
          ),
          _actionButton(
            'Release to Pool',
            Icons.person_add_alt_1,
            AppColors.navyBlue,
            isDark,
            () {
              Provider.of<GlobalAppState>(context, listen: false)
                  .releaseCandidateToPool(contract.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Candidate released back to sourcing pool')),
              );
            },
          ),
          _actionButton(
            'Mark Job Left',
            Icons.exit_to_app,
            AppColors.grey600,
            isDark,
            () {
              Provider.of<GlobalAppState>(context, listen: false)
                  .markCandidateLeft(contract.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Candidate marked as Job Left')),
              );
            },
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

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.newInquiry:
        return AppColors.stageInterviewed;
      case ClientStatus.followUp:
        return AppColors.urgentAmber;
      case ClientStatus.noResponse:
        return AppColors.criticalRed;
      case ClientStatus.converted:
        return AppColors.successGreen;
      case ClientStatus.active:
        return AppColors.successGreen;
      case ClientStatus.notInterested:
        return AppColors.grey500;
      case ClientStatus.churned:
        return AppColors.statusBlacklisted;
    }
  }
}
