import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/crm_user_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/screens/admin/team_data_source.dart';

class TeamListScreen extends StatefulWidget {
  final UserRole? filterRole;

  const TeamListScreen({super.key, this.filterRole});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  CrmUserStatus? _statusFilter;
  int _currentPage = 0;
  bool _showFilters = false;
  static const int _pageSize = 10;

  @override
  void didUpdateWidget(covariant TeamListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterRole != widget.filterRole) {
      setState(() => _currentPage = 0);
    }
  }

  List<CrmUserModel> _getFilteredUsers(GlobalAppState state) {
    var users = state.crmUsers.toList();
    if (widget.filterRole != null) {
      users = users.where((u) => u.role == widget.filterRole).toList();
    }
    if (_statusFilter != null) {
      users = users.where((u) => u.status == _statusFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      users =
          users
              .where(
                (u) =>
                    u.name.toLowerCase().contains(q) ||
                    u.email.toLowerCase().contains(q) ||
                    u.phone.toLowerCase().contains(q),
              )
              .toList();
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final state = Provider.of<GlobalAppState>(context);

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final allFiltered = _getFilteredUsers(state);
    final totalPages = (allFiltered.length / _pageSize).ceil();
    final pagedUsers =
        allFiltered.skip(_currentPage * _pageSize).take(_pageSize).toList();

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeAgoFormat = DateFormat('dd MMM, hh:mm a');

    final isMobile = context.media.width < 900;
    final tabs = [
      'All Members',
      ...CrmUserStatus.values.map((s) => s.displayName),
    ];
    final statuses = [null, ...CrmUserStatus.values];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      body: Column(
        children: [
          // 1. Horizontal ChoiceChip Tabs
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = _statusFilter == statuses[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              tabs[index],
                              style: GoogleFonts.poppins(
                                color:
                                    isSelected
                                        ? AppColors.navyBlue
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.gold,
                            backgroundColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _statusFilter = statuses[index];
                                _currentPage = 0;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  tooltip: 'Toggle Filters',
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
          ),

          // 2. Toolbar
          if (_showFilters || !isMobile)
            _buildToolbar(isDark, allFiltered.length, isMobile),

          // 3. Grid / Mobile List
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    isMobile
                        ? _buildMobileList(
                          pagedUsers,
                          isDark,
                          state,
                          dateFormat,
                          timeAgoFormat,
                        )
                        : _buildDataGrid(pagedUsers, isDark, state),
              ),
            ),
          ),

          // --- Pagination ---
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              // vertical: 5,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${allFiltered.isEmpty ? 0 : (_currentPage * _pageSize + 1)}-${min((_currentPage + 1) * _pageSize, allFiltered.length)} of ${allFiltered.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      splashRadius: 16,
                      color: isDark ? AppColors.grey300 : AppColors.grey600,
                      disabledColor:
                          isDark ? AppColors.grey700 : AppColors.grey300,
                    ),
                    ...List.generate(totalPages, (i) {
                      final isActive = i == _currentPage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _currentPage = i),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? AppColors.gold
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                color:
                                    isActive
                                        ? AppColors.darkNavy
                                        : (isDark
                                            ? AppColors.grey400
                                            : AppColors.grey600),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    IconButton(
                      onPressed:
                          _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                      icon: const Icon(Icons.chevron_right, size: 20),
                      splashRadius: 16,
                      color: isDark ? AppColors.grey300 : AppColors.grey600,
                      disabledColor:
                          isDark ? AppColors.grey700 : AppColors.grey300,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isDark, int count, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          isMobile
              ? _buildMobileToolbar(isDark, count)
              : _buildDesktopToolbar(isDark, count),
    );
  }

  Widget _buildMobileToolbar(bool isDark, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showFilters) ...[
          // Search Field
          SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged:
                  (v) => setState(() {
                    _search = v;
                    _currentPage = 0;
                  }),
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          onPressed: () => context.go('/admin/team/add'),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar(bool isDark, int count) {
    return Row(
      children: [
        // Total Users Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count Members',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
        ),
        const Spacer(),
        // Search Field
        SizedBox(
          width: 250,
          height: 38,
          child: TextField(
            controller: _searchController,
            onChanged:
                (v) => setState(() {
                  _search = v;
                  _currentPage = 0;
                }),
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => context.go('/admin/team/add'),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDataGrid(
    List<CrmUserModel> users,
    bool isDark,
    GlobalAppState state,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark ? AppColors.grey700 : AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No team members found.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    final dataSource = TeamDataSource(
      context: context,
      isDark: isDark,
      state: state,
      teamMembers: users,
      onViewDetails: (user) => _showUserDetailDialog(user, isDark, state),
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        child: SfDataGridTheme(
          data: SfDataGridThemeData(
            headerColor: isDark ? AppColors.darkSurface : AppColors.grey50,
            gridLineColor: isDark ? AppColors.dividerDark : AppColors.grey200,
            gridLineStrokeWidth: 1,
            rowHoverColor:
                isDark
                    ? AppColors.navyBlue.withValues(alpha: 0.1)
                    : AppColors.navyBlue.withValues(alpha: 0.04),
          ),
          child: SfDataGrid(
            source: dataSource,
            allowSorting: true,
            columnWidthMode: ColumnWidthMode.auto,
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            columns: <GridColumn>[
              GridColumn(
                columnName: 'user',
                columnWidthMode: ColumnWidthMode.auto,
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('MEMBER', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'role',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('ROLE', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'status',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('STATUS', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'joined',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('JOINED', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'lastLogin',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('LAST LOGIN', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'performance',
              width: 160,
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('PERFORMANCE', style: _headerStyle(isDark)),
              ),
            ),
            GridColumn(
              columnName: 'actions',
              width: 140,
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('ACTIONS', style: _headerStyle(isDark)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMobileList(
    List<CrmUserModel> users,
    bool isDark,
    GlobalAppState state,
    DateFormat dateFormat,
    DateFormat timeAgoFormat,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark ? AppColors.grey700 : AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No team members found.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        Color roleColor = AppColors.navyBlue;
        switch (user.role) {
          case UserRole.admin:
            roleColor = AppColors.gold;
            break;
          case UserRole.sales:
            roleColor = AppColors.stageInterviewed;
            break;
          case UserRole.sourcing:
            roleColor = AppColors.stageMedicalCheck;
            break;
          case UserRole.executive:
            roleColor = AppColors.stageDocuments;
            break;
        }

        Color statusColor = AppColors.grey500;
        switch (user.status) {
          case CrmUserStatus.active:
            statusColor = AppColors.successGreen;
            break;
          case CrmUserStatus.inactive:
            statusColor = AppColors.grey500;
            break;
          case CrmUserStatus.suspended:
            statusColor = AppColors.criticalRed;
            break;
        }

        return _MobileTeamCard(
          user: user,
          roleColor: roleColor,
          statusColor: statusColor,
          isDark: isDark,
          dateFormat: dateFormat,
          onViewDetails: () => _showUserDetailDialog(user, isDark, state),
          onEdit: () => context.push('/admin/team/${user.id}/edit'),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, int value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? AppColors.grey400 : AppColors.grey500,
          ),
        ),
      ],
    );
  }

  void _showUserDetailDialog(
    CrmUserModel user,
    bool isDark,
    GlobalAppState state,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                        child: Text(
                          user.name.split(' ').map((n) => n[0]).take(2).join(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            Text(
                              user.role.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color:
                                    isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.email, 'Email', user.email, isDark),
                  _buildDetailRow(Icons.phone, 'Phone', user.phone, isDark),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Joined',
                    dateFormat.format(user.joinedDate),
                    isDark,
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Last Login',
                    user.lastLogin != null
                        ? timeFormat.format(user.lastLogin!)
                        : 'Never',
                    isDark,
                  ),
                  _buildDetailRow(
                    Icons.circle,
                    'Status',
                    user.status.displayName,
                    isDark,
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reset Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter new password',
                            hintStyle: GoogleFonts.poppins(fontSize: 13),
                            filled: true,
                            fillColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (passwordController.text.trim().isNotEmpty) {
                            state.resetCrmUserPassword(
                              user.id,
                              passwordController.text.trim(),
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password reset for ${user.name}',
                                ),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.grey400 : AppColors.grey500,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(bool isDark) {
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: isDark ? AppColors.grey400 : AppColors.grey600,
    );
  }
}

class _MobileTeamCard extends StatefulWidget {
  final CrmUserModel user;
  final Color roleColor;
  final Color statusColor;
  final bool isDark;
  final DateFormat dateFormat;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;

  const _MobileTeamCard({
    required this.user,
    required this.roleColor,
    required this.statusColor,
    required this.isDark,
    required this.dateFormat,
    required this.onViewDetails,
    required this.onEdit,
  });

  @override
  State<_MobileTeamCard> createState() => _MobileTeamCardState();
}

class _MobileTeamCardState extends State<_MobileTeamCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isDark = widget.isDark;
    final roleColor = widget.roleColor;
    final statusColor = widget.statusColor;
    final dateFormat = widget.dateFormat;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row (Always visible)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: roleColor.withValues(alpha: 0.15),
                    child: Text(
                      user.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        Text(
                          user.role.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      user.status.displayName,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
              // Expanded Area
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey500)),
                          const SizedBox(height: 2),
                          Text(user.email, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.navyBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey500)),
                          const SizedBox(height: 2),
                          Text(user.phone, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.navyBlue)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Joined Date', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey500)),
                          const SizedBox(height: 2),
                          Text(dateFormat.format(user.joinedDate), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.navyBlue)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (user.role == UserRole.sales) ...[
                            _buildMiniStat('Clients', user.clientsConverted, isDark),
                            const SizedBox(width: 16),
                            _buildMiniStat('Contracts', user.contractsClosed, isDark),
                          ] else if (user.role == UserRole.sourcing) ...[
                            _buildMiniStat('Added', user.candidatesAdded, isDark),
                          ] else ...[
                            Text(
                              '—',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? AppColors.grey500 : AppColors.grey400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.call,
                        label: 'Call',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${user.phone}...'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.visibility,
                        label: 'View',
                        isDark: isDark,
                        baseColor: AppColors.gold,
                        onTap: widget.onViewDetails,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        isDark: isDark,
                        baseColor: AppColors.navyBlue,
                        onTap: widget.onEdit,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? AppColors.grey400 : AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? baseColor,
  }) {
    final effectiveColor =
        baseColor ?? (isDark ? AppColors.white : AppColors.gold);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: isDark ? 0.1 : 0.08),
              border: Border.all(
                color: effectiveColor.withValues(alpha: isDark ? 0.2 : 0.15),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: effectiveColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
