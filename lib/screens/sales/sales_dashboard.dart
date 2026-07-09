import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';

class SalesDashboard extends StatelessWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inFmt = NumberFormat('#,##,###', 'en_IN');

    // Calculate dynamic stats based on role
    // If sales rep, only show their leads. If admin, show all.
    final myClients = state.currentUser?.role == UserRole.sales
        ? state.clients.where((c) => c.assignedEmployeeId == '2').toList() // mock id 2 is sales
        : state.clients;

    final myContracts = state.currentUser?.role == UserRole.sales
        ? state.contracts.where((c) => c.createdBy == 'Priya Mehta').toList()
        : state.contracts;

    final totalLeads = myClients.length;
    final newInquiries = myClients.where((c) => c.status == ClientStatus.newInquiry).length;
    final followUps = myClients.where((c) => c.status == ClientStatus.followUp).length;
    final noResponse = myClients.where((c) => c.status == ClientStatus.noResponse).length;
    final converted = myClients.where((c) => c.status == ClientStatus.converted || c.status == ClientStatus.active).length;
    
    final activeContracts = myContracts.where((c) => c.contractStatus == ContractStatus.active).length;
    
    // Revenue from my contracts
    final monthlyRevenue = myContracts
        .where((c) => c.placementDate.month == DateTime.now().month)
        .fold<double>(0, (sum, c) => sum + c.amountPaid);
    
    // SLA Countdowns (e.g. guarantee ending soon)
    final slaCountdowns = myContracts
        .where((c) => c.isGuaranteeActive && c.daysRemainingInGuarantee < 30)
        .length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Customer-Side Operations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.grey400 : AppColors.grey600)),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  _buildStatCard('Lead Pipeline', inFmt.format(newInquiries),
                      Icons.leaderboard, AppColors.gold, 'New Inquiries', isDark),
                  _buildStatCard('Active Contracts', inFmt.format(activeContracts),
                      Icons.description, AppColors.successGreen, 'Currently running', isDark),
                  _buildStatCard('SLA Countdowns', '$slaCountdowns',
                      Icons.timer, AppColors.urgentAmber, 'Replacement deadlines <30d', isDark),
                ],
              );
            }),
            const SizedBox(height: 32),
            Text('Lead Funnel', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _FunnelCard(label: 'Total Leads', value: inFmt.format(totalLeads), color: AppColors.navyBlue, isDark: isDark),
                _FunnelCard(label: 'Follow Up', value: inFmt.format(followUps), color: AppColors.urgentAmber, isDark: isDark),
                _FunnelCard(label: 'No Response', value: inFmt.format(noResponse), color: AppColors.criticalRed, isDark: isDark),
                _FunnelCard(label: 'Converted', value: inFmt.format(converted), color: AppColors.successGreen, isDark: isDark),
              ],
            ),
            const SizedBox(height: 32),
            Card(
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
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.currency_rupee, color: AppColors.gold, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue Generated (This Month)', style: TextStyle(fontSize: 13,
                            color: isDark ? AppColors.grey400 : AppColors.grey600)),
                        const SizedBox(height: 4),
                        Text('₹${inFmt.format(monthlyRevenue)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          )),
        ]),
      ),
    );
  }
}

class _FunnelCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _FunnelCard({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ]),
    );
  }
}
