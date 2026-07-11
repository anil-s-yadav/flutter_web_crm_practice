import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/utils/extensions.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isDesktop = width > 1100;
    final isTablet = width > 700;

    // Filter data for Sales user
    final myClients = state.currentUser?.role == UserRole.sales
        ? state.clients.where((c) => c.assignedEmployeeId == '2').toList()
        : state.clients;

    final myContracts = state.currentUser?.role == UserRole.sales
        ? state.contracts.where((c) => c.createdBy == 'Priya Mehta').toList()
        : state.contracts;

    // Pipeline Stats
    final newInquiries = myClients.where((c) => c.status == ClientStatus.newInquiry).length;
    final followUps = myClients.where((c) => c.status == ClientStatus.followUp).length;
    final negotiating = 0; // Assuming we use followUps or define a negotiating stage later
    final converted = myClients.where((c) => c.status == ClientStatus.converted || c.status == ClientStatus.active).length;
    final totalPipeline = newInquiries + followUps + negotiating;

    // Other Stats
    final activeContracts = myContracts.where((c) => c.contractStatus == ContractStatus.active).length;
    final slaCountdowns = myContracts.where((c) => c.isGuaranteeActive && c.daysRemainingInGuarantee < 30).length;
    final monthlyRevenue = myContracts
        .where((c) => c.placementDate.month == DateTime.now().month)
        .fold<double>(0, (sum, c) => sum + c.amountPaid);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Pipeline Visualization
            Text(
              'Sales Funnel Pipeline',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 12),
            Card(
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
                child: isTablet
                    ? Row(children: _buildPipelineSteps(isDark, true, newInquiries, followUps, converted, totalPipeline))
                    : Column(children: _buildPipelineSteps(isDark, false, newInquiries, followUps, converted, totalPipeline)),
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final isTablet = constraints.maxWidth > 600 && !isDesktop;
                
                final revenueCard = _buildStatCard(
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.gold,
                  title: 'Monthly Revenue',
                  value: '₹${_indianFormat.format(monthlyRevenue)}',
                  isDark: isDark,
                  subtitle: 'Generated this month',
                );

                final contractsCard = _buildStatCard(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.successGreen,
                  title: 'Active Contracts',
                  value: _indianFormat.format(activeContracts),
                  isDark: isDark,
                  subtitle: 'Currently running',
                );

                final slaCard = _buildStatCard(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.urgentAmber,
                  title: 'Expiring Guarantees',
                  value: _indianFormat.format(slaCountdowns),
                  isDark: isDark,
                  subtitle: '< 30 days left',
                );

                if (isDesktop) {
                  return Row(
                    children: [
                      Expanded(child: revenueCard),
                      const SizedBox(width: 16),
                      Expanded(child: contractsCard),
                      const SizedBox(width: 16),
                      Expanded(child: slaCard),
                    ],
                  );
                } else if (isTablet) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: revenueCard),
                          const SizedBox(width: 16),
                          Expanded(child: contractsCard),
                        ],
                      ),
                      const SizedBox(height: 16),
                      slaCard,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      revenueCard,
                      const SizedBox(height: 16),
                      contractsCard,
                      const SizedBox(height: 16),
                      slaCard,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // Main Content Area: Recent Inquiries Table
            Text(
              'Recent Inquiries',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 16),
            _RecentInquiriesTable(clients: myClients),
            
            const SizedBox(height: 32),
            _buildUpcomingRenewals(context, myContracts, isDark),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPipelineSteps(
    bool isDark,
    bool isHorizontal,
    int newInquiries,
    int followUps,
    int converted,
    int totalPipeline,
  ) {
    final steps = [
      _PipelineStep(
        title: 'New Inquiries',
        count: newInquiries,
        total: totalPipeline,
        color: AppColors.standardBlue,
        icon: Icons.person_add_alt_1,
      ),
      _PipelineStep(
        title: 'Follow Up',
        count: followUps,
        total: totalPipeline,
        color: AppColors.urgentAmber,
        icon: Icons.phone_in_talk,
      ),
      _PipelineStep(
        title: 'Converted',
        count: converted,
        total: totalPipeline > 0 ? totalPipeline : 1, // Avoid div/0 but keep logic simple
        color: AppColors.successGreen,
        icon: Icons.handshake,
      ),
    ];

    List<Widget> children = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      children.add(
        isHorizontal
            ? Expanded(child: _buildPipelineCard(step, isDark))
            : _buildPipelineCard(step, isDark),
      );

      if (i < steps.length - 1) {
        children.add(
          isHorizontal
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    size: 20,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Icon(
                    Icons.arrow_downward,
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    size: 20,
                  ),
                ),
        );
      }
    }
    return children;
  }

  Widget _buildPipelineCard(_PipelineStep step, bool isDark) {
    final double percentage = step.total > 0 ? step.count / step.total : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: step.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(step.icon, color: step.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _indianFormat.format(step.count),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(step.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    String? subtitle,
  }) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey500 : AppColors.grey500,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRenewals(
    BuildContext context,
    List<ContractModel> myContracts,
    bool isDark,
  ) {
    final upcomingRenewals = myContracts.where((c) {
      if (c.contractStatus != ContractStatus.active) return false;
      final expiryDate = DateTime(c.placementDate.year, c.placementDate.month + 11, c.placementDate.day);
      final daysToExpiry = expiryDate.difference(DateTime.now()).inDays;
      return daysToExpiry >= 0 && daysToExpiry <= 30;
    }).toList();

    if (upcomingRenewals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_busy, color: AppColors.urgentAmber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Upcoming Renewals (30 Days)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.urgentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${upcomingRenewals.length}',
                style: const TextStyle(
                  color: AppColors.urgentAmber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingRenewals.length,
          itemBuilder: (context, index) {
            final contract = upcomingRenewals[index];
            final expiryDate = DateTime(contract.placementDate.year, contract.placementDate.month + 11, contract.placementDate.day);
            final daysLeft = expiryDate.difference(DateTime.now()).inDays;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
              ),
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.urgentAmber.withValues(alpha: 0.1),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.urgentAmber, size: 20),
                ),
                title: Text(
                  contract.clientName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Candidate: ${contract.candidateName} • Expires in $daysLeft days'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Follow Up'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PipelineStep {
  final String title;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _PipelineStep({
    required this.title,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });
}

// ---------------------------------------------------------
// RECENT INQUIRIES TABLE
// ---------------------------------------------------------

class _RecentInquiriesTable extends StatefulWidget {
  final List<ClientModel> clients;
  const _RecentInquiriesTable({required this.clients});

  @override
  State<_RecentInquiriesTable> createState() => _RecentInquiriesTableState();
}

class _RecentInquiriesTableState extends State<_RecentInquiriesTable> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sort descending by inquiry date (newest first)
    final sortedClients = List<ClientModel>.from(widget.clients)
      ..sort((a, b) => b.inquiryDate.compareTo(a.inquiryDate));

    // Filter logic
    final filtered = sortedClients.where((c) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!c.fullName.toLowerCase().contains(query) &&
            !c.phone.contains(query) &&
            !c.city.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search clients by name, phone, or location...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.grey500,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.dividerDark : AppColors.grey300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.dividerDark : AppColors.grey300,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.grey300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Data Table
          SizedBox(
            width: double.infinity,
            child: Theme(
              data: Theme.of(context).copyWith(
                cardColor: Colors.transparent,
                dividerColor: isDark ? AppColors.dividerDark : AppColors.grey200,
              ),
              child: PaginatedDataTable(
                columns: const [
                  DataColumn(label: Text('Client Info')),
                  DataColumn(label: Text('Requirement')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Inquiry Date')),
                  DataColumn(label: Text('Actions')),
                ],
                source: _ClientDataSource(
                  clients: filtered,
                  context: context,
                  isDark: isDark,
                ),
                rowsPerPage: filtered.length > 5 ? 5 : (filtered.isEmpty ? 1 : filtered.length),
                columnSpacing: 24,
                horizontalMargin: 24,
                showCheckboxColumn: false,
                headingRowHeight: 56,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientDataSource extends DataTableSource {
  final List<ClientModel> clients;
  final BuildContext context;
  final bool isDark;

  _ClientDataSource({
    required this.clients,
    required this.context,
    required this.isDark,
  });

  Color _getStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.newInquiry:
        return AppColors.standardBlue;
      case ClientStatus.followUp:
        return AppColors.urgentAmber;
      case ClientStatus.converted:
      case ClientStatus.active:
        return AppColors.successGreen;
      case ClientStatus.noResponse:
      case ClientStatus.notInterested:
      case ClientStatus.churned:
        return AppColors.criticalRed;
    }
  }

  String _getStatusDisplay(ClientStatus status) {
    switch (status) {
      case ClientStatus.newInquiry: return 'New';
      case ClientStatus.followUp: return 'Follow Up';
      case ClientStatus.converted: return 'Converted';
      case ClientStatus.active: return 'Active';
      case ClientStatus.noResponse: return 'No Response';
      case ClientStatus.notInterested: return 'Not Interested';
      case ClientStatus.churned: return 'Churned';
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= clients.length) return null;
    final client = clients[index];
    final statusColor = _getStatusColor(client.status);

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                client.fullName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              Text(
                '${client.locality}, ${client.city}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                client.preferredCandidateCategory,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: isDark ? AppColors.grey300 : AppColors.grey800,
                ),
              ),
              Text(
                client.budgetRange,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              _getStatusDisplay(client.status),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            DateFormat('dd MMM yyyy').format(client.inquiryDate),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                tooltip: 'View Profile',
                color: AppColors.standardBlue,
                onPressed: () {
                  context.go('/sales/clients/${client.id}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined, size: 20),
                tooltip: 'Call',
                color: AppColors.successGreen,
                onPressed: () {
                  // Integration logic here
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clients.length;

  @override
  int get selectedRowCount => 0;
}
