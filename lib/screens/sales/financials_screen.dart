import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/models/invoice_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final state = Provider.of<GlobalAppState>(context);
    final invoices = state.invoices;
    final isMobile = MediaQuery.of(context).size.width < 800;

    // Calculate metrics
    final totalRevenue = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold(0.0, (sum, i) => sum + i.amount);
        
    final pendingCollections = invoices
        .where((i) => i.status == InvoiceStatus.pending || i.status == InvoiceStatus.overdue)
        .fold(0.0, (sum, i) => sum + i.amount);
        
    // Assuming 10% commission on paid invoices
    final expectedCommission = totalRevenue * 0.10;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 24),
            _buildKPIs(isDark, totalRevenue, pendingCollections, expectedCommission, isMobile),
            const SizedBox(height: 24),
            if (isMobile)
              Column(
                children: [
                  _buildRevenueChart(isDark),
                  const SizedBox(height: 24),
                  _buildStatusBreakdown(isDark, invoices),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRevenueChart(isDark)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildStatusBreakdown(isDark, invoices)),
                ],
              ),
            const SizedBox(height: 24),
            _buildTransactionsList(isDark, invoices, state),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIs(bool isDark, double revenue, double pending, double commission, bool isMobile) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    if (isMobile) {
      return Column(
        children: [
          _buildKPICard('Total Revenue (MTD)', currency.format(revenue), Icons.account_balance_wallet, AppColors.gold, isDark),
          const SizedBox(height: 16),
          _buildKPICard('Pending Collections', currency.format(pending), Icons.pending_actions, AppColors.warningOrange, isDark),
          const SizedBox(height: 16),
          _buildKPICard('Expected Commission', currency.format(commission), Icons.card_giftcard, AppColors.successGreen, isDark),
        ],
      );
    }
    
    return Row(
      children: [
        Expanded(child: _buildKPICard('Total Revenue (MTD)', currency.format(revenue), Icons.account_balance_wallet, AppColors.gold, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildKPICard('Pending Collections', currency.format(pending), Icons.pending_actions, AppColors.warningOrange, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildKPICard('Expected Commission', currency.format(commission), Icons.card_giftcard, AppColors.successGreen, isDark)),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color iconColor, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
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
    );
  }

  Widget _buildRevenueChart(bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend (Last 6 Months)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar('Feb', 0.4, isDark),
                  _buildChartBar('Mar', 0.6, isDark),
                  _buildChartBar('Apr', 0.5, isDark),
                  _buildChartBar('May', 0.8, isDark),
                  _buildChartBar('Jun', 0.7, isDark),
                  _buildChartBar('Jul', 1.0, isDark, isCurrent: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double fillPct, bool isDark, {bool isCurrent = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 40,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              heightFactor: fillPct,
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.gold : (isDark ? AppColors.grey700 : AppColors.grey300),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: isDark ? AppColors.grey300 : AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(bool isDark, List<InvoiceModel> invoices) {
    final paidCount = invoices.where((i) => i.status == InvoiceStatus.paid).length;
    final pendingCount = invoices.where((i) => i.status == InvoiceStatus.pending).length;
    final overdueCount = invoices.where((i) => i.status == InvoiceStatus.overdue).length;
    final total = invoices.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 32),
            _buildStatusRow('Paid', paidCount, total, AppColors.successGreen, isDark),
            const SizedBox(height: 16),
            _buildStatusRow('Pending', pendingCount, total, AppColors.warningOrange, isDark),
            const SizedBox(height: 16),
            _buildStatusRow('Overdue', overdueCount, total, AppColors.criticalRed, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color, bool isDark) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.grey300 : AppColors.grey700)),
            Text(count.toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildTransactionsList(bool isDark, List<InvoiceModel> invoices, GlobalAppState state) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Transactions & Invoices',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Invoice'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                  ),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
              dataTextStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
              columns: const [
                DataColumn(label: Text('INVOICE ID')),
                DataColumn(label: Text('CLIENT')),
                DataColumn(label: Text('PLACED CANDIDATE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: invoices.map((inv) {
                return DataRow(
                  cells: [
                    DataCell(Text(inv.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(inv.clientName)),
                    DataCell(Text(inv.candidateName)),
                    DataCell(Text(currencyFormat.format(inv.amount))),
                    DataCell(Text(dateFormat.format(inv.date))),
                    DataCell(_buildStatusChip(inv.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, size: 18),
                            tooltip: 'Download PDF',
                            onPressed: () {},
                          ),
                          if (inv.status != InvoiceStatus.paid)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              color: AppColors.successGreen,
                              tooltip: 'Mark as Paid',
                              onPressed: () {
                                state.updateInvoiceStatus(inv.id, InvoiceStatus.paid);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invoice ${inv.id} marked as Paid.')),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case InvoiceStatus.paid:
        bg = AppColors.successGreen.withValues(alpha: 0.1);
        fg = AppColors.successGreen;
        break;
      case InvoiceStatus.pending:
        bg = AppColors.warningOrange.withValues(alpha: 0.1);
        fg = AppColors.warningOrange;
        break;
      case InvoiceStatus.overdue:
        bg = AppColors.criticalRed.withValues(alpha: 0.1);
        fg = AppColors.criticalRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
