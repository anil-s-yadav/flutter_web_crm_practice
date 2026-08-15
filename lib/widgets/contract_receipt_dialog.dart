import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/blocs/contract/contract_bloc.dart';
import 'package:practice_app/blocs/contract/contract_event.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/theme/app_colors.dart';

class ContractReceiptDialog extends StatefulWidget {
  final ContractModel contract;

  const ContractReceiptDialog({super.key, required this.contract});

  static Future<void> show(BuildContext context, ContractModel contract) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ContractReceiptDialog(contract: contract),
    );
  }

  @override
  State<ContractReceiptDialog> createState() => _ContractReceiptDialogState();
}

class _ContractReceiptDialogState extends State<ContractReceiptDialog> {
  late ContractModel _contract;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
  }

  double get _totalFee => _contract.serviceFee;
  double get _amountPaid => _contract.amountPaid;
  double get _balance => _contract.balanceAmount > 0 ? _contract.balanceAmount : (_totalFee - _amountPaid);
  bool get _isHalfPaid => _amountPaid > 0 && _balance > 0;
  bool get _isFullyPaid => _amountPaid >= _totalFee && _totalFee > 0;

  // Base and GST calculations (18% inclusive in total fee)
  double get _paidBase => (_amountPaid / 1.18);
  double get _paidGst => _amountPaid - _paidBase;
  double get _paidCgst => _paidGst / 2;
  double get _paidSgst => _paidGst / 2;

  String _generateReceiptText() {
    final dateStr = _dateFormat.format(_contract.placementDate);
    final receiptType = _isFullyPaid
        ? 'FINAL TAX INVOICE & RECEIPT'
        : (_isHalfPaid
            ? 'ADVANCE RECEIPT (1st Installment - 50%)'
            : 'PAYMENT DEMAND / QUOTATION');

    return '''🧾 *VERIFIED MAIDS - OFFICIAL PAYMENT RECEIPT*
━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 *Receipt Type:* $receiptType
🆔 *Contract ID:* ${_contract.id}
📅 *Date:* $dateStr
👤 *Client Name:* ${_contract.clientName}
👩‍🍳 *Assigned Candidate:* ${_contract.candidateName}

💰 *FEE & TAX BREAKDOWN (INR):*
• Base Placement Fee (1 Month Salary): ${_currencyFormat.format(_paidBase)}
• CGST @ 9%: ${_currencyFormat.format(_paidCgst)}
• SGST @ 9%: ${_currencyFormat.format(_paidSgst)}
• *Total Amount Paid:* *${_currencyFormat.format(_amountPaid)}*

📊 *PAYMENT MILESTONE STATUS:*
• 1st Installment (50% - Shortlisting): ${_amountPaid > 0 ? '✅ PAID' : '⏳ PENDING'}
• 2nd Installment (50% - Joining): ${_isFullyPaid ? '✅ PAID' : '⏳ BALANCE PENDING (${_currencyFormat.format(_balance)})'}

🔒 *GST Compliance Note:*
Tax is charged and reported strictly on actual payment collected (${_currencyFormat.format(_amountPaid)}). No additional tax liability applies on unbilled balance if contract is cancelled early.
━━━━━━━━━━━━━━━━━━━━━━━━━━
*Verified Maids Services Pvt Ltd* | support@verifiedmaids.com''';
  }

  void _copyReceiptToClipboard() {
    final text = _generateReceiptText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Receipt copied to clipboard! Ready to share with client on WhatsApp.',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordSecondInstallment() async {
    final remaining = _balance;
    final newPaid = _totalFee;
    final updatedContract = _contract.copyWith(
      amountPaid: newPaid,
      balanceAmount: 0,
      paymentStatus: PaymentStatus.paid,
      contractStatus: ContractStatus.active,
    );

    context.read<ContractBloc>().add(UpdateContract(updatedContract));
    setState(() {
      _contract = updatedContract;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Text(
          '2nd Installment (${_currencyFormat.format(remaining)}) recorded successfully! Contract marked fully paid.',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _cancelAndCloseContract() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Close / Cancel Contract?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Customer broke the contract. The contract will be marked as Cancelled.\n\n'
          '• Total Collected & Retained: ${_currencyFormat.format(_amountPaid)}\n'
          '• GST Liability: Only ${_currencyFormat.format(_paidGst)} on collected amount.\n'
          '• Unpaid Balance (${_currencyFormat.format(_balance)}) will be closed with 0 tax liability.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel & Close Balance'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final updatedContract = _contract.copyWith(
      balanceAmount: 0,
      contractStatus: ContractStatus.cancelled,
      remarks: 'Contract cancelled after 1st installment. Closed with 0 remaining liability.',
    );

    if (!mounted) return;
    context.read<ContractBloc>().add(UpdateContract(updatedContract));
    setState(() {
      _contract = updatedContract;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Contract marked Cancelled. Account and GST liability settled cleanly.',
          style: GoogleFonts.poppins(color: AppColors.navyBlue, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFullyPaid
                              ? 'Final Tax Invoice & Receipt'
                              : (_isHalfPaid
                                  ? 'Advance Payment Receipt (1st Installment)'
                                  : 'Contract Payment Schedule'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        Text(
                          'Contract #${_contract.id} • ${_dateFormat.format(_contract.placementDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
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
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parties Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                        borderRadius: BorderRadius.circular(10),
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
                                  'CLIENT',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _contract.clientName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.white : AppColors.navyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: isDark ? AppColors.dividerDark : AppColors.grey300,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ASSIGNED CANDIDATE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _contract.candidateName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.white : AppColors.navyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2-Installments Progress Track
                    Text(
                      '2-INSTALLMENTS PAYMENT TRACKER',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // 1st Installment
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _amountPaid > 0
                                  ? AppColors.successGreen.withValues(alpha: 0.1)
                                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _amountPaid > 0
                                    ? AppColors.successGreen.withValues(alpha: 0.4)
                                    : (isDark ? AppColors.dividerDark : AppColors.grey300),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1st Installment (50%)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _amountPaid > 0 ? AppColors.successGreen : AppColors.grey500,
                                      ),
                                    ),
                                    Icon(
                                      _amountPaid > 0 ? Icons.check_circle : Icons.hourglass_top,
                                      size: 16,
                                      color: _amountPaid > 0 ? AppColors.successGreen : AppColors.grey500,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(_totalFee / 2),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.white : AppColors.navyBlue,
                                  ),
                                ),
                                Text(
                                  _amountPaid > 0 ? 'Paid on Trial/Booking' : 'Due on Shortlisting',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: _amountPaid > 0 ? AppColors.successGreen : AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 2nd Installment
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isFullyPaid
                                  ? AppColors.successGreen.withValues(alpha: 0.1)
                                  : (_contract.contractStatus == ContractStatus.cancelled
                                      ? AppColors.grey400.withValues(alpha: 0.1)
                                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isFullyPaid
                                    ? AppColors.successGreen.withValues(alpha: 0.4)
                                    : (_contract.contractStatus == ContractStatus.cancelled
                                        ? AppColors.grey400.withValues(alpha: 0.3)
                                        : AppColors.gold.withValues(alpha: 0.4)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '2nd Installment (50%)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _isFullyPaid
                                            ? AppColors.successGreen
                                            : (_contract.contractStatus == ContractStatus.cancelled
                                                ? AppColors.grey500
                                                : AppColors.gold),
                                      ),
                                    ),
                                    Icon(
                                      _isFullyPaid
                                          ? Icons.check_circle
                                          : (_contract.contractStatus == ContractStatus.cancelled
                                              ? Icons.cancel_outlined
                                              : Icons.pending_actions),
                                      size: 16,
                                      color: _isFullyPaid
                                          ? AppColors.successGreen
                                          : (_contract.contractStatus == ContractStatus.cancelled
                                              ? AppColors.grey500
                                              : AppColors.gold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(_totalFee / 2),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.white : AppColors.navyBlue,
                                  ),
                                ),
                                Text(
                                  _isFullyPaid
                                      ? 'Paid on Joining'
                                      : (_contract.contractStatus == ContractStatus.cancelled
                                          ? 'Contract Cancelled (0 Tax)'
                                          : 'Due on Final Joining'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: _isFullyPaid
                                        ? AppColors.successGreen
                                        : (_contract.contractStatus == ContractStatus.cancelled
                                            ? AppColors.grey500
                                            : AppColors.gold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Financial Itemization Table
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.dividerDark : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        children: [
                          _itemRow('Base Agency Placement Fee', _currencyFormat.format(_paidBase), isDark),
                          const Divider(height: 14),
                          _itemRow('CGST (9%)', _currencyFormat.format(_paidCgst), isDark),
                          const SizedBox(height: 4),
                          _itemRow('SGST (9%)', _currencyFormat.format(_paidSgst), isDark),
                          const Divider(height: 14),
                          _itemRow('Total Amount Collected', _currencyFormat.format(_amountPaid), isDark, isBold: true, isGold: true),
                          if (_balance > 0 && _contract.contractStatus != ContractStatus.cancelled) ...[
                            const SizedBox(height: 4),
                            _itemRow('Balance Remaining', _currencyFormat.format(_balance), isDark, isWarning: true),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // GST Note
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.standardBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppColors.standardBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'GST is computed and payable strictly on the actual collected amount (${_currencyFormat.format(_amountPaid)}). If contract cancels, unpaid balance carries 0 GST liability.',
                              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey300 : AppColors.grey700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _copyReceiptToClipboard,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy WhatsApp Receipt'),
                  ),
                  if (_balance > 0 && _contract.contractStatus != ContractStatus.cancelled) ...[
                    OutlinedButton.icon(
                      onPressed: _cancelAndCloseContract,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Customer Broke Contract'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.criticalRed,
                        side: const BorderSide(color: AppColors.criticalRed),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _recordSecondInstallment,
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Record 2nd Installment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(String label, String value, bool isDark, {bool isBold = false, bool isGold = false, bool isWarning = false}) {
    Color valColor = isDark ? AppColors.white : AppColors.navyBlue;
    if (isGold) valColor = AppColors.gold;
    if (isWarning) valColor = AppColors.criticalRed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valColor,
          ),
        ),
      ],
    );
  }
}
