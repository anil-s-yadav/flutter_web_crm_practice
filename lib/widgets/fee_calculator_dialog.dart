import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/theme/app_colors.dart';

class FeeCalculatorDialog extends StatefulWidget {
  const FeeCalculatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const FeeCalculatorDialog(),
    );
  }

  @override
  State<FeeCalculatorDialog> createState() => _FeeCalculatorDialogState();
}

class _FeeCalculatorDialogState extends State<FeeCalculatorDialog> {
  final TextEditingController _salaryController = TextEditingController(
    text: '20000',
  );
  String _selectedRole = 'Cook';
  final double _gstPercentage = 18.0;

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  double get _monthlySalary {
    final clean = _salaryController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  double get _baseAgencyFee => _monthlySalary; // 1 month candidate salary

  double get _gstAmount => _baseAgencyFee * (_gstPercentage / 100);

  double get _totalFeeWithGst => _baseAgencyFee + _gstAmount;

  double get _installment1Total => (_totalFeeWithGst / 2).roundToDouble();

  double get _installment1Base => (_baseAgencyFee / 2).roundToDouble();

  double get _installment1Gst => (_gstAmount / 2).roundToDouble();

  double get _installment2Total => _totalFeeWithGst - _installment1Total;

  double get _installment2Base => _baseAgencyFee - _installment1Base;

  double get _installment2Gst => _gstAmount - _installment1Gst;

  double get _perDaySalary => _monthlySalary > 0 ? _monthlySalary / 30 : 0;

  String _formatNumber(double val) {
    return currencyFormatter.format(val);
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _setQuickSalary(int amount) {
    setState(() {
      _salaryController.text = amount.toString();
    });
  }

  String _generateClientQuotationText() {
    final roleName = _selectedRole.isNotEmpty ? _selectedRole : 'Candidate';
    final salaryStr = _formatNumber(_monthlySalary);
    final baseFeeStr = _formatNumber(_baseAgencyFee);
    final gstStr = _formatNumber(_gstAmount);
    final totalFeeStr = _formatNumber(_totalFeeWithGst);
    final inst1Str = _formatNumber(_installment1Total);
    final inst1BaseStr = _formatNumber(_installment1Base);
    final inst1GstStr = _formatNumber(_installment1Gst);
    final inst2Str = _formatNumber(_installment2Total);
    final inst2BaseStr = _formatNumber(_installment2Base);
    final inst2GstStr = _formatNumber(_installment2Gst);

    return '''💼 *Verified Maids - Service & Agency Fee Quotation*
━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 *Target Role:* $roleName
💵 *Candidate Monthly Salary:* $salaryStr / month
*(Paid directly to candidate monthly)*

📑 *One-Time Agency Placement Fee:*
• Base Placement Fee (1 Month Salary): $baseFeeStr
• Applicable GST (18%): $gstStr
• *Total One-Time Fee (incl. GST):* *$totalFeeStr*

💳 *Payment in 2 Easy Installments:*
1️⃣ *1st Installment (50%):* *$inst1Str* ($inst1BaseStr + $inst1GstStr GST)
   👉 *Payable at:* Candidate Shortlisting / Trial Confirmation

2️⃣ *2nd Installment (50%):* *$inst2Str* ($inst2BaseStr + $inst2GstStr GST)
   👉 *Payable on:* Final Joining & Contract Execution

✨ *Agency Fee Inclusions:*
✅ Comprehensive Background Verification
✅ Aadhaar & Police Clearance Check
✅ 100% Free Replacement Guarantee
✅ Dedicated Relationship Manager Support
━━━━━━━━━━━━━━━━━━━━━━━━━━
*Verified Maids Platform* | www.verifiedmaids.com''';
  }

  void _copyQuotationToClipboard() {
    final text = _generateClientQuotationText();
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
                'Quotation copied to clipboard! Ready to paste to client on WhatsApp / SMS.',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 850;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 860,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calculate_outlined,
                      color: AppColors.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Salary & Agency Fee Calculator',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sales & Admin Tool',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '1 Month Salary One-Time Agency Fee + 18% GST in 2 Installments',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
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

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child:
                    isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildInputsSection(isDark),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 5,
                              child: _buildResultsSection(isDark),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            _buildInputsSection(isDark),
                            const SizedBox(height: 20),
                            _buildResultsSection(isDark),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Selector
        Text(
          'Select Service Category',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue:
              CategoryConstants.categories.contains(_selectedRole)
                  ? _selectedRole
                  : CategoryConstants.categories.first,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
          ),
          items: [
            ...CategoryConstants.categories.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role, style: GoogleFonts.poppins(fontSize: 13)),
              );
            }),
          ],
          onChanged: (val) {
            if (val != null) _onRoleSelected(val);
          },
        ),
        const SizedBox(height: 16),

        // Monthly Salary Input
        Text(
          'Candidate Monthly Salary (₹)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _salaryController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: (val) => setState(() {}),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            hintText: 'e.g. 20000',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Salary Selector Chips
        Text(
          'Quick Presets:',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              [
                12000,
                15000,
                20000,
                25000,
                30000,
                35000,
                40000,
                50000,
                60000,
              ].map((amount) {
                final isSelected = _monthlySalary == amount;
                return InkWell(
                  onTap: () => _setQuickSalary(amount),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.gold
                              : (isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.grey100),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.gold
                                : (isDark
                                    ? AppColors.dividerDark
                                    : AppColors.grey300),
                      ),
                    ),
                    child: Text(
                      '₹${amount ~/ 1000}k',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.navyBlue
                                : (isDark
                                    ? AppColors.white
                                    : AppColors.grey800),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),

        // Daily Salary Helper
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.standardBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.standardBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.standardBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Per-day equivalent: ~${_formatNumber(_perDaySalary)} / day (based on 30 calendar days).',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Fee Hero Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL AGENCY CHARGES',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.gold,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                _formatNumber(_totalFeeWithGst),
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Base Fee: ${_formatNumber(_baseAgencyFee)} + GST (18%): ${_formatNumber(_gstAmount)}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2 Installments Split Header
        Row(
          children: [
            const Icon(Icons.payment, size: 16, color: AppColors.successGreen),
            const SizedBox(width: 6),
            Text(
              'PAYMENT IN 2 INSTALLMENTS (50% - 50%)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? AppColors.grey300 : AppColors.grey700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Installment Cards
        Row(
          children: [
            // 1st Installment
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '1st Installment (50%)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatNumber(_installment1Total),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'Base: ${_formatNumber(_installment1Base)} + GST: ${_formatNumber(_installment1Gst)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🎯 Due on Shortlisting / Trial',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.successGreen,
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
                  color:
                      isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '2nd Installment (50%)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatNumber(_installment2Total),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'Base: ${_formatNumber(_installment2Base)} + GST: ${_formatNumber(_installment2Gst)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🤝 Due on Joining & Agreement',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action: Copy WhatsApp Quotation Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _copyQuotationToClipboard,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy WhatsApp Quotation for Client'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
