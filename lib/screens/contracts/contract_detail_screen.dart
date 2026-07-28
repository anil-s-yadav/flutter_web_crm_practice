import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/candidate_picker_dialog.dart';
import 'package:provider/provider.dart';

class ContractDetailScreen extends StatelessWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    final contract =
        state.contracts.where((c) => c.id == contractId).firstOrNull;

    if (contract == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contract Details')),
        body: const Center(child: Text('Contract not found')),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    final clientContracts =
        state.contracts.where((c) => c.clientId == contract.clientId).toList()
          ..sort((a, b) => b.placementDate.compareTo(a.placementDate));

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
                  context.go('/sales/contracts/active');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Contracts',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Card
            _buildHeaderCard(contract, isDark),
            const SizedBox(height: 20),

            // Info Grid
            _buildInfoGrid(contract, currencyFormat, dateFormat, isDark),
            const SizedBox(height: 20),

            // Loyalty Card (if isRenewal and has history)
            if (contract.isRenewal && clientContracts.length > 1) ...[
              _buildLoyaltyCard(clientContracts, isDark),
              const SizedBox(height: 20),
            ],

            // Contract History Section
            _buildSectionCard(
              title: 'Contract History',
              icon: Icons.history,
              isDark: isDark,
              child: _buildContractHistory(clientContracts, dateFormat, isDark),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context, contract, state, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ContractModel contract, bool isDark) {
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
                'Contract ID: ${contract.id}',
                style: GoogleFonts.poppins(
                  color: isDark ? AppColors.grey300 : AppColors.grey700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildStatusBadge(
                contract.contractStatus.displayName,
                _getContractStatusColor(contract.contractStatus),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contract.clientName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            contract.candidateName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? AppColors.grey300 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(
    ContractModel contract,
    NumberFormat currencyFormat,
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
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        children: [
          _buildInfoItem(
            'Placement Date',
            dateFormat.format(contract.placementDate),
            Icons.calendar_today,
            isDark,
          ),
          _buildInfoItem(
            'Guarantee End',
            dateFormat.format(contract.guaranteeEndDate),
            Icons.security,
            isDark,
            isWarning: !contract.isGuaranteeActive,
          ),
          _buildInfoItem(
            'Contract Expiry',
            dateFormat.format(contract.contractExpiryDate),
            Icons.event_busy,
            isDark,
          ),
          _buildInfoItem(
            'Warranty',
            '${contract.replacementsUsed}/3',
            Icons.autorenew,
            isDark,
          ),
          _buildInfoItem(
            'Service Fee',
            currencyFormat.format(contract.serviceFee),
            Icons.monetization_on,
            isDark,
          ),
          _buildInfoItem(
            'Amount Paid',
            currencyFormat.format(contract.amountPaid),
            Icons.payment,
            isDark,
          ),
          _buildInfoItem(
            'Balance',
            currencyFormat.format(contract.balanceAmount),
            Icons.account_balance_wallet,
            isDark,
            isWarning: contract.balanceAmount > 0,
          ),
          _buildBadgeItem(
            'Payment Status',
            contract.paymentStatus.displayName,
            _getPaymentStatusColor(contract.paymentStatus),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(List<ContractModel> clientContracts, bool isDark) {
    final firstContract = clientContracts.last;
    final yearsPassed =
        (DateTime.now().difference(firstContract.placementDate).inDays / 365.25)
            .floor();
    final joinedDateStr = DateFormat(
      'dd MMM yyyy',
    ).format(firstContract.placementDate);
    final renewalsCount = clientContracts.where((c) => c.isRenewal).length;

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
            children: [
              const Icon(Icons.stars, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'Loyalty Card',
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
              _buildInfoItem(
                'Joined',
                joinedDateStr,
                Icons.calendar_today,
                isDark,
              ),
              _buildInfoItem(
                'Years as Customer',
                yearsPassed.toString(),
                Icons.hourglass_bottom,
                isDark,
              ),
              _buildInfoItem(
                'Times Renewed',
                renewalsCount.toString(),
                Icons.autorenew,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractHistory(
    List<ContractModel> clientContracts,
    DateFormat dateFormat,
    bool isDark,
  ) {
    return Column(
      children:
          clientContracts.map((c) {
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
                          c.id,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.candidateName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(c.placementDate),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(
                    c.contractStatus.displayName,
                    _getContractStatusColor(c.contractStatus),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ContractModel contract,
    dynamic state,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () => _handleRenewSameStaff(context, contract, state),
          icon: const Icon(Icons.autorenew),
          label: Text(
            'Renew Same Staff',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _handleRenewNewStaff(context, contract, state),
          icon: const Icon(Icons.person_add),
          label: Text(
            'Renew New Staff',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.standardBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        Tooltip(
          message:
              contract.replacementsUsed >= 3
                  ? "Maximum replacements reached"
                  : "",
          child: OutlinedButton.icon(
            onPressed:
                contract.replacementsUsed >= 3
                    ? null
                    : () =>
                        _handleInitiateReplacement(context, contract, state),
            icon: const Icon(Icons.find_replace),
            label: Text(
              'Initiate Replacement',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.urgentAmber,
              side: const BorderSide(color: AppColors.urgentAmber),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed:
              () => _showDispatchExecutiveSheet(context, contract, state),
          icon: const Icon(Icons.delivery_dining),
          label: Text(
            'Dispatch Executive',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navyBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRenewSameStaff(
    BuildContext context,
    ContractModel contract,
    dynamic state,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Renewal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to renew this contract with ${contract.candidateName}?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                ),
                child: Text(
                  'Confirm',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // ignore: undefined_method
      state.renewContract(contract.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract renewed successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleRenewNewStaff(
    BuildContext context,
    ContractModel contract,
    dynamic state,
  ) async {
    final selectedCandidate = await CandidatePickerDialog.show(context);
    if (selectedCandidate != null) {
      // ignore: undefined_method
      state.renewContract(
        contract.id,
        newCandidateId: selectedCandidate['id'],
        newCandidateName: selectedCandidate['name'],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract renewed with new staff')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleInitiateReplacement(
    BuildContext context,
    ContractModel contract,
    dynamic state,
  ) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Initiate Replacement',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for replacement',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop(reasonController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.urgentAmber,
                  foregroundColor: AppColors.white,
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );

    if (reason != null && reason.isNotEmpty) {
      // ignore: undefined_method
      state.requestReplacement(contract.id, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Replacement initiated')));
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
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
              Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool isWarning = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color:
              isWarning
                  ? AppColors.criticalRed
                  : (isDark ? AppColors.grey400 : AppColors.grey600),
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
                    isWarning
                        ? AppColors.criticalRed
                        : (isDark ? AppColors.white : AppColors.navyBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String label, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? AppColors.grey500 : AppColors.grey600,
          ),
        ),
        const SizedBox(height: 2),
        _buildStatusBadge(value, color),
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

  Color _getContractStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return AppColors.statusPending;
      case ContractStatus.active:
        return AppColors.statusVerified;
      case ContractStatus.completed:
        return AppColors.infoBlue;
      case ContractStatus.rePlaced:
        return AppColors.urgentAmber;
      case ContractStatus.cancelled:
        return AppColors.criticalRed;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.statusPending;
      case PaymentStatus.partial:
        return AppColors.urgentAmber;
      case PaymentStatus.paid:
        return AppColors.successGreen;
      case PaymentStatus.overdue:
        return AppColors.criticalRed;
    }
  }

  void _showDispatchExecutiveSheet(
    BuildContext context,
    ContractModel contract,
    GlobalAppState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _DispatchExecutiveSheet(contract: contract),
    );
  }
}

class _DispatchExecutiveSheet extends StatefulWidget {
  final ContractModel contract;

  const _DispatchExecutiveSheet({required this.contract});

  @override
  State<_DispatchExecutiveSheet> createState() =>
      _DispatchExecutiveSheetState();
}

class _DispatchExecutiveSheetState extends State<_DispatchExecutiveSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTaskType = 'documentPickup';
  String _selectedExecutive = '';
  String _remarks = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final executives =
        state.crmUsers.where((u) => u.role == UserRole.executive).toList();

    if (_selectedExecutive.isEmpty && executives.isNotEmpty) {
      _selectedExecutive = executives.first.id;
    }

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
                'Dispatch Executive',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Assign a task to an executive for client ${widget.contract.clientName}.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedTaskType,
                decoration: InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'documentPickup',
                    child: Text('Physical Contract Collection'),
                  ),
                  DropdownMenuItem(
                    value: 'paymentCollection',
                    child: Text('Offline Payment Collection'),
                  ),
                  DropdownMenuItem(
                    value: 'clientVisit',
                    child: Text('Client Visit / Verification'),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedTaskType = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedExecutive,
                decoration: InputDecoration(
                  labelText: 'Assign To Executive',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    executives
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text('${e.name} (${e.phone})'),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedExecutive = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Instructions / Remarks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                onSaved: (val) => _remarks = val ?? '',
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
                    onPressed: _dispatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Dispatch'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dispatch() {
    _formKey.currentState!.save();
    final state = Provider.of<GlobalAppState>(context, listen: false);

    final taskTypeEnum = TaskTypeExtension.fromString(_selectedTaskType);

    final newTask = ExecutiveTaskModel(
      id: 'TSK${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      title: taskTypeEnum.displayName,
      description:
          _remarks.isEmpty
              ? 'Scheduled ${taskTypeEnum.displayName} for ${widget.contract.clientName}'
              : _remarks,
      type: taskTypeEnum,
      status: TaskStatus.pending,
      assignedTo: _selectedExecutive,
      clientName: widget.contract.clientName,
      clientAddress: 'Address on file',
      clientPhone: 'Phone on file',
      scheduledDate: DateTime.now().add(const Duration(hours: 1)),
    );

    state.addTask(newTask);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${taskTypeEnum.displayName} Task dispatched successfully!',
        ),
      ),
    );
  }
}
