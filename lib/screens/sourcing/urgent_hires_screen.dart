import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_state.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_bloc.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_event.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_state.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/blocs/audit_log/audit_log_bloc.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/urgent_hire_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/candidate_avatar.dart';

class UrgentHiresScreen extends StatefulWidget {
  const UrgentHiresScreen({super.key});

  @override
  State<UrgentHiresScreen> createState() => _UrgentHiresScreenState();
}

class _UrgentHiresScreenState extends State<UrgentHiresScreen> {
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UrgentHireBloc>().add(const LoadUrgentHires());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<UrgentHireBloc>().add(LoadUrgentHires(
          status: _selectedStatus == 'all' ? null : _selectedStatus,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _onSearch(String query) {
    context.read<UrgentHireBloc>().add(LoadUrgentHires(
          status: _selectedStatus == 'all' ? null : _selectedStatus,
          search: query.trim().isEmpty ? null : query.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final width = context.media.width;
    final isDesktop = width > 950;

    return Scaffold(
      body: BlocConsumer<UrgentHireBloc, UrgentHireState>(
        listener: (context, state) {
          if (state is UrgentHireActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is UrgentHireError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.criticalRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final urgentHires = state is UrgentHireLoaded
              ? state.urgentHires
              : <UrgentHireModel>[];

          final pendingCount = state is UrgentHireLoaded ? state.pendingCount : 0;
          final inProgressCount =
              state is UrgentHireLoaded ? state.inProgressCount : 0;
          final fulfilledCount =
              state is UrgentHireLoaded ? state.fulfilledCount : 0;

          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                _buildHeader(isDark, pendingCount),
                const SizedBox(height: 16),

                // Summary metric cards
                _buildMetricCards(
                  isDark,
                  total: urgentHires.length,
                  pending: pendingCount,
                  inProgress: inProgressCount,
                  fulfilled: fulfilledCount,
                ),
                const SizedBox(height: 16),

                // Filter & Search bar
                _buildFilterBar(isDark),
                const SizedBox(height: 16),

                // Main content
                Expanded(
                  child: state is UrgentHireLoading && urgentHires.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : urgentHires.isEmpty
                          ? _buildEmptyState(isDark)
                          : isDesktop
                              ? _buildDesktopTable(urgentHires, isDark)
                              : _buildMobileList(urgentHires, isDark),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, int pendingCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flash_on, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Urgent Hiring Requests',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.criticalRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount PENDING',
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'High-priority maid sourcing requests initiated directly by Sales team',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            context.read<UrgentHireBloc>().add(LoadUrgentHires(
                  status: _selectedStatus == 'all' ? null : _selectedStatus,
                  search: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                ));
          },
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildMetricCards(
    bool isDark, {
    required int total,
    required int pending,
    required int inProgress,
    required int fulfilled,
  }) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            'Total Requests',
            total.toString(),
            Icons.list_alt,
            AppColors.standardBlue,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            'Pending Action',
            pending.toString(),
            Icons.hourglass_top,
            AppColors.criticalRed,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            'In Progress',
            inProgress.toString(),
            Icons.run_circle_outlined,
            AppColors.gold,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            'Fulfilled',
            fulfilled.toString(),
            Icons.check_circle_outline,
            AppColors.successGreen,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    String title,
    String count,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 820;
        final searchWidget = SizedBox(
          width: isNarrow ? double.infinity : 340,
          height: 42,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search client, role, phone, ID...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey500,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.white,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
          ),
        );

        final chipsWidget = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterChip('All', 'all', isDark),
              const SizedBox(width: 6),
              _filterChip('Pending', 'pending', isDark),
              const SizedBox(width: 6),
              _filterChip('In Progress', 'in_progress', isDark),
              const SizedBox(width: 6),
              _filterChip('Fulfilled', 'fulfilled', isDark),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchWidget,
              const SizedBox(height: 10),
              chipsWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            searchWidget,
            const SizedBox(width: 16),
            Flexible(child: chipsWidget),
          ],
        );
      },
    );
  }

  Widget _filterChip(String label, String value, bool isDark) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.navyBlue
              : (isDark ? AppColors.grey300 : AppColors.grey700),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.gold,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      onSelected: (_) => _onFilterChanged(value),
      side: BorderSide(
        color: isSelected
            ? AppColors.gold
            : (isDark ? AppColors.dividerDark : AppColors.grey300),
      ),
    );
  }

  Widget _buildDesktopTable(List<UrgentHireModel> list, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableMinWidth = math.max(constraints.maxWidth, 950.0);
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
            ),
          ),
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: tableMinWidth),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 20,
                  headingRowHeight: 46,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                  ),
            columns: [
              DataColumn(
                label: Text(
                  'REQUEST ID',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'CLIENT DETAILS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'TARGET ROLE & SHIFT',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'BUDGET & JOINING',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'REQUESTED BY',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'STATUS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTIONS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            rows: list.map((item) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.id,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(item.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    InkWell(
                      onTap: () => _navigateToClient(context, item.clientId),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.clientName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.navyBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Text(
                            '${item.clientCity} • ${item.clientPhone}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.grey400
                                  : AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.category,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item.serviceType,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.grey400
                                : AppColors.grey600,
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
                          item.budgetRange.isNotEmpty
                              ? item.budgetRange
                              : 'Standard',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item.expectedJoining,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.grey400
                                : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      item.requestedByName.isNotEmpty
                          ? item.requestedByName
                          : 'Sales Rep',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  DataCell(_buildStatusBadge(item.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.status == UrgentHireStatus.pending)
                          OutlinedButton(
                            onPressed: () {
                              context.read<UrgentHireBloc>().add(
                                    UpdateUrgentHireStatusEvent(
                                      id: item.id,
                                      status: UrgentHireStatus.inProgress,
                                    ),
                                  );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: const BorderSide(color: AppColors.gold),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                            child: const Text('Start Sourcing',
                                style: TextStyle(fontSize: 11)),
                          ),
                        if (item.status == UrgentHireStatus.pending ||
                            item.status == UrgentHireStatus.inProgress) ...[
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showFulfillDialog(context, item, isDark),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 14),
                            label: const Text('Mark Fulfilled',
                                style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                        if (item.status == UrgentHireStatus.fulfilled &&
                            item.fulfilledCandidateName != null &&
                            item.fulfilledCandidateName!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 13,
                                  color: AppColors.successGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.fulfilledCandidateName!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          tooltip: 'View Full Request Details',
                          onPressed: () =>
                              _showDetailsModal(context, item, isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
      },
    );
  }

  Widget _buildMobileList(List<UrgentHireModel> list, bool isDark) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
            ),
          ),
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.id,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(item.status),
                      ],
                    ),
                    Text(
                      DateFormat('dd MMM').format(item.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _navigateToClient(context, item.clientId),
                  child: Text(
                    item.clientName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  '${item.category} • ${item.serviceType}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                if (item.budgetRange.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Budget: ${item.budgetRange} • Joining: ${item.expectedJoining}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By: ${item.requestedByName}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    Row(
                      children: [
                        if (item.status == UrgentHireStatus.pending)
                          OutlinedButton(
                            onPressed: () {
                              context.read<UrgentHireBloc>().add(
                                    UpdateUrgentHireStatusEvent(
                                      id: item.id,
                                      status: UrgentHireStatus.inProgress,
                                    ),
                                  );
                            },
                            child: const Text('Start',
                                style: TextStyle(fontSize: 11)),
                          ),
                        if (item.status == UrgentHireStatus.pending ||
                            item.status == UrgentHireStatus.inProgress) ...[
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () =>
                                _showFulfillDialog(context, item, isDark),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Fulfill',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () =>
                              _showDetailsModal(context, item, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(UrgentHireStatus status) {
    Color bg;
    Color fg;
    Color dot;
    switch (status) {
      case UrgentHireStatus.pending:
        bg = AppColors.criticalRed.withValues(alpha: 0.12);
        fg = AppColors.criticalRed;
        dot = AppColors.criticalRed;
        break;
      case UrgentHireStatus.inProgress:
        bg = AppColors.gold.withValues(alpha: 0.12);
        fg = AppColors.gold;
        dot = AppColors.gold;
        break;
      case UrgentHireStatus.fulfilled:
        bg = AppColors.successGreen.withValues(alpha: 0.12);
        fg = AppColors.successGreen;
        dot = AppColors.successGreen;
        break;
      case UrgentHireStatus.cancelled:
        bg = AppColors.grey400.withValues(alpha: 0.12);
        fg = AppColors.grey500;
        dot = AppColors.grey500;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 54, color: AppColors.successGreen),
          const SizedBox(height: 12),
          Text(
            'All caught up!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No urgent hiring requests found matching this filter.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToClient(BuildContext context, String clientId) {
    final authState = context.read<AuthBloc>().state;
    final role = ((authState is AuthAuthenticated) ? authState.user : null)?.role;
    final prefix = role == UserRole.admin ? '/admin' : '/sales';
    context.go('$prefix/clients/$clientId');
  }

  void _showFulfillDialog(
    BuildContext context,
    UrgentHireModel item,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _SelectCandidateFulfillDialog(
        request: item,
        isDark: isDark,
      ),
    );
  }

  void _showDetailsModal(
    BuildContext context,
    UrgentHireModel item,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Urgent Hire Request Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Client Name', item.clientName, isDark),
            _detailRow('Client City & Phone',
                '${item.clientCity} (${item.clientPhone})', isDark),
            _detailRow('Target Category', item.category, isDark),
            _detailRow('Service Type / Shift', item.serviceType, isDark),
            _detailRow('Work Timings', item.workTimings, isDark),
            _detailRow('Budget Range', item.budgetRange, isDark),
            _detailRow('Expected Joining', item.expectedJoining, isDark),
            _detailRow('Food Preference', item.foodPreference, isDark),
            _detailRow('Gender Preference', item.genderPreference, isDark),
            _detailRow('Languages', item.preferredLanguages, isDark),
            _detailRow('Religion Preference', item.religionPreference, isDark),
            if (item.fulfilledCandidateName != null &&
                item.fulfilledCandidateName!.isNotEmpty)
              _detailRow(
                'Fulfilled By',
                '${item.fulfilledCandidateName} (${item.fulfilledCandidateId ?? ''})',
                isDark,
              ),
            if (item.notes.isNotEmpty)
              _detailRow('Sales Remarks / Notes', item.notes, isDark),
            _detailRow('Requested By', item.requestedByName, isDark),
            _detailRow('Requested On',
                DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt), isDark),
            const SizedBox(height: 16),
            if (item.status == UrgentHireStatus.pending ||
                item.status == UrgentHireStatus.inProgress) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showFulfillDialog(context, item, isDark);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Select Candidate & Mark Fulfilled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _navigateToClient(context, item.clientId);
                },
                icon: const Icon(Icons.person),
                label: const Text('Open Client Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectCandidateFulfillDialog extends StatefulWidget {
  final UrgentHireModel request;
  final bool isDark;

  const _SelectCandidateFulfillDialog({
    required this.request,
    required this.isDark,
  });

  @override
  State<_SelectCandidateFulfillDialog> createState() =>
      _SelectCandidateFulfillDialogState();
}

class _SelectCandidateFulfillDialogState
    extends State<_SelectCandidateFulfillDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterMode = 'category'; // 'category' or 'all'

  @override
  void initState() {
    super.initState();
    context.read<CandidateBloc>().add(const LoadCandidates());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final reqCat = widget.request.category.toLowerCase().trim();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        height: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.how_to_reg,
                    color: AppColors.successGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Candidate & Mark Fulfilled',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      Text(
                        'Fulfill urgent requirement for ${widget.request.clientName} • Target Role: ${widget.request.category}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
            const Divider(height: 20),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Search candidate by name, ID (e.g. CN00000001), phone, or skill...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchCtrl.clear()),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.grey50,
              ),
            ),
            const SizedBox(height: 12),

            // Filter Toggle: Category Match vs All Ready to Place
            BlocBuilder<CandidateBloc, CandidateState>(
              builder: (context, state) {
                final allCandidates = state is CandidateLoaded
                    ? state.candidates
                    : <CandidateModel>[];
                final readyCandidates = allCandidates
                    .where((c) => c.status == CandidateStatus.readyToPlace)
                    .toList();
                final categoryMatchingCount = readyCandidates.where((c) {
                  final cat = c.category.toLowerCase().trim();
                  return cat == reqCat ||
                      (reqCat.contains('house') && cat.contains('house')) ||
                      (reqCat.contains('cook') && cat.contains('cook')) ||
                      (reqCat.contains('nanny') && cat.contains('nanny'));
                }).length;

                return Row(
                  children: [
                    FilterChip(
                      selected: _filterMode == 'category',
                      onSelected: (selected) {
                        setState(() => _filterMode = 'category');
                      },
                      label: Text(
                        'Target Category: ${widget.request.category} ($categoryMatchingCount)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selectedColor: AppColors.gold.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _filterMode == 'all',
                      onSelected: (selected) {
                        setState(() => _filterMode = 'all');
                      },
                      label: Text(
                        'All Ready to Place (${readyCandidates.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selectedColor: AppColors.gold.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.gold,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Candidate List Pool
            Expanded(
              child: BlocBuilder<CandidateBloc, CandidateState>(
                builder: (context, state) {
                  if (state is CandidateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allCandidates = state is CandidateLoaded
                      ? state.candidates
                      : <CandidateModel>[];

                  // Filter to only ready to place candidates
                  var pool = allCandidates
                      .where((c) => c.status == CandidateStatus.readyToPlace)
                      .toList();

                  // Filter by category mode
                  if (_filterMode == 'category') {
                    pool = pool.where((c) {
                      final cat = c.category.toLowerCase().trim();
                      return cat == reqCat ||
                          (reqCat.contains('house') && cat.contains('house')) ||
                          (reqCat.contains('cook') && cat.contains('cook')) ||
                          (reqCat.contains('nanny') && cat.contains('nanny'));
                    }).toList();
                  }

                  // Filter by search query
                  final query = _searchCtrl.text.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    pool = pool.where((c) {
                      return c.fullName.toLowerCase().contains(query) ||
                          c.id.toLowerCase().contains(query) ||
                          c.phone.contains(query) ||
                          c.category.toLowerCase().contains(query) ||
                          c.city.toLowerCase().contains(query);
                    }).toList();
                  }

                  if (pool.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_search_outlined,
                              size: 48,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _filterMode == 'category'
                                  ? 'No Ready to Place candidates in "${widget.request.category}"'
                                  : 'No candidates match your search',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _filterMode == 'category'
                                  ? 'Switch to "All Ready to Place" to select an available candidate from another category, or add a candidate to the pool.'
                                  : 'Try adjusting your search keywords.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.grey400
                                    : AppColors.grey600,
                              ),
                            ),
                            if (_filterMode == 'category') ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() => _filterMode = 'all');
                                },
                                child: const Text(
                                    'Show All Ready to Place Candidates'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: pool.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final candidate = pool[index];
                      final isExactCat = candidate.category
                              .toLowerCase()
                              .trim() ==
                          reqCat;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.grey50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isExactCat
                                ? AppColors.gold.withValues(alpha: 0.5)
                                : (isDark
                                    ? AppColors.dividerDark
                                    : AppColors.grey200),
                            width: isExactCat ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CandidateAvatar(
                              name: candidate.fullName,
                              photoUrl: candidate.photoUrl,
                              radius: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        candidate.fullName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.white
                                              : AppColors.navyBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          candidate.id,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                      ),
                                      if (isExactCat) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.successGreen
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '🎯 Direct Match',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.successGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        '${candidate.category} • ${candidate.city}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.grey300
                                              : AppColors.grey700,
                                        ),
                                      ),
                                      Text(
                                        '${candidate.age} yrs • ${candidate.experienceYears} yrs exp',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600,
                                        ),
                                      ),
                                      if (candidate.aadhaarNumber != null &&
                                          candidate.aadhaarNumber!.isNotEmpty)
                                        Text(
                                          'Aadhaar: ${candidate.maskedAadhaar}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.grey400
                                                : AppColors.grey600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _assignAndFulfill(candidate),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 16),
                              label: const Text('Select & Fulfill'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignAndFulfill(CandidateModel candidate) {
    context.read<UrgentHireBloc>().add(
          UpdateUrgentHireStatusEvent(
            id: widget.request.id,
            status: UrgentHireStatus.fulfilled,
            fulfilledCandidateId: candidate.id,
          ),
        );

    // Audit log
    context.read<AuditLogBloc>().add(
          LogAuditEvent(
            entityType: 'urgent_hire',
            targetId: widget.request.id,
            actionType: 'fulfilled',
            description:
                'Urgent hiring request for ${widget.request.clientName} (${widget.request.category}) fulfilled with candidate ${candidate.fullName} (${candidate.id})',
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✅ Urgent hire request ${widget.request.id} fulfilled with ${candidate.fullName} (${candidate.id})!',
                style: GoogleFonts.poppins(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
