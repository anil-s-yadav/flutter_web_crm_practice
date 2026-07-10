import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String _selectedFilter = 'Leads Pipeline';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final allMyClients = state.currentUser?.role == UserRole.sales
        ? state.clients.where((c) => c.assignedEmployeeId == '2').toList()
        : state.clients;

    final leads = allMyClients.where((c) => 
        c.status == ClientStatus.newInquiry || 
        c.status == ClientStatus.followUp || 
        c.status == ClientStatus.noResponse).toList();
        
    final active = allMyClients.where((c) => 
        c.status == ClientStatus.active || 
        c.status == ClientStatus.converted).toList();

    final filterOptions = [
      'Leads Pipeline (${leads.length})',
      'Active Customers (${active.length})'
    ];

    // Ensure selected filter exists
    if (!filterOptions.contains(_selectedFilter) && _selectedFilter.startsWith('Leads Pipeline')) {
      _selectedFilter = filterOptions[0];
    } else if (!filterOptions.contains(_selectedFilter) && _selectedFilter.startsWith('Active Customers')) {
      _selectedFilter = filterOptions[1];
    } else if (!filterOptions.contains(_selectedFilter)) {
      _selectedFilter = filterOptions[0];
    }

    return Column(
      children: [
        Container(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? AppColors.navyBlue
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.gold,
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: _selectedFilter.startsWith('Leads Pipeline')
              ? _ClientListView(clients: leads, isDark: isDark)
              : _ClientListView(clients: active, isDark: isDark),
        ),
      ],
    );
  }
}

class _ClientListView extends StatelessWidget {
  final List<ClientModel> clients;
  final bool isDark;

  const _ClientListView({required this.clients, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return Center(
        child: Text('No clients found in this category.',
            style: GoogleFonts.poppins(color: isDark ? AppColors.grey400 : AppColors.grey600)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final client = clients[index];
        final state = Provider.of<GlobalAppState>(context, listen: false);
        final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sales';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
          ),
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('$routePrefix/clients/${client.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDark 
                        ? AppColors.white.withValues(alpha: 0.1)
                        : AppColors.navyBlue.withValues(alpha: 0.1),
                    child: Text(
                      client.fullName[0],
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColors.navyBlue, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[VMC${client.id.padLeft(3, '0')}] ${client.fullName}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '${client.locality}, ${client.city} • ${client.preferredCandidateCategory} • ${DateFormat('MMM dd, yyyy').format(client.inquiryDate)}',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  _buildBadge(client.status.displayName, _statusColor(client.status)),
                ],
              ),
            ),
          ),
        );
      },
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
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.newInquiry: return AppColors.stageInterviewed;
      case ClientStatus.followUp: return AppColors.urgentAmber;
      case ClientStatus.noResponse: return AppColors.criticalRed;
      case ClientStatus.converted: return AppColors.successGreen;
      case ClientStatus.active: return AppColors.successGreen;
      case ClientStatus.notInterested: return AppColors.grey500;
      case ClientStatus.churned: return AppColors.statusBlacklisted;
    }
  }
}
