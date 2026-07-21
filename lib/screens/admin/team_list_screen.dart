import 'dart:math';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // --- Table Card ---
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Column(
                children: [
                  // --- Table Toolbar ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey200,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left: Title + count
                        Text(
                          widget.filterRole != null
                              ? '${widget.filterRole!.displayName} Team'
                              : 'All Members',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${allFiltered.length} members',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Search
                        SizedBox(
                          width: 260,
                          height: 38,
                          child: TextField(
                            controller: _searchController,
                            onChanged:
                                (v) => setState(() {
                                  _search = v;
                                  _currentPage = 0;
                                }),
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? AppColors.grey500
                                        : AppColors.grey400,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.grey50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status filter
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CrmUserStatus?>(
                              value: _statusFilter,
                              hint: Text(
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      isDark
                                          ? AppColors.grey400
                                          : AppColors.grey600,
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color:
                                    isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                              ),
                              isDense: true,
                              dropdownColor:
                                  isDark
                                      ? AppColors.darkSurface
                                      : AppColors.white,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                              items: [
                                DropdownMenuItem<CrmUserStatus?>(
                                  value: null,
                                  child: Text(
                                    'All',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                                ...CrmUserStatus.values.map(
                                  (s) => DropdownMenuItem<CrmUserStatus?>(
                                    value: s,
                                    child: Text(
                                      s.displayName,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(() {
                                    _statusFilter = v;
                                    _currentPage = 0;
                                  }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Add member
                        ElevatedButton.icon(
                          onPressed: () => context.go('/admin/team/add'),
                          icon: const Icon(Icons.person_add, size: 16),
                          label: Text(
                            'Add Member',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Table Header ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.grey50,
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey200,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text('MEMBER', style: _headerStyle(isDark)),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text('ROLE', style: _headerStyle(isDark)),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text('STATUS', style: _headerStyle(isDark)),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text('JOINED', style: _headerStyle(isDark)),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text(
                            'LAST LOGIN',
                            style: _headerStyle(isDark),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'PERFORMANCE',
                            style: _headerStyle(isDark),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text('ACTIONS', style: _headerStyle(isDark)),
                        ),
                      ],
                    ),
                  ),

                  // --- Table Rows ---
                  Expanded(
                    child:
                        pagedUsers.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color:
                                        isDark
                                            ? AppColors.grey700
                                            : AppColors.grey300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team members found.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color:
                                          isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.separated(
                              itemCount: pagedUsers.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color:
                                        isDark
                                            ? AppColors.dividerDark
                                            : AppColors.grey200,
                                  ),
                              itemBuilder: (context, index) {
                                final user = pagedUsers[index];
                                return _buildUserRow(
                                  user,
                                  dateFormat,
                                  timeAgoFormat,
                                  isDark,
                                  state,
                                );
                              },
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
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey200,
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
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
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
                              color:
                                  isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                              disabledColor:
                                  isDark
                                      ? AppColors.grey700
                                      : AppColors.grey300,
                            ),
                            ...List.generate(totalPages, (i) {
                              final isActive = i == _currentPage;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
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
                              color:
                                  isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                              disabledColor:
                                  isDark
                                      ? AppColors.grey700
                                      : AppColors.grey300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(
    CrmUserModel user,
    DateFormat dateFormat,
    DateFormat timeAgoFormat,
    bool isDark,
    GlobalAppState state,
  ) {
    Color roleColor;
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

    Color statusColor;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Name + Email
          SizedBox(
            width: 200,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Text(
                    user.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.grey500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.role.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ),
          ),

          // Status
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.status.displayName,
                  style: GoogleFonts.poppins(fontSize: 12, color: statusColor),
                ),
              ],
            ),
          ),

          // Joined
          SizedBox(
            width: 120,
            child: Text(
              dateFormat.format(user.joinedDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),

          // Last Login
          SizedBox(
            width: 140,
            child: Text(
              user.lastLogin != null
                  ? timeAgoFormat.format(user.lastLogin!)
                  : 'Never',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),

          // Performance
          Expanded(
            child: Row(
              children: [
                if (user.role == UserRole.sales) ...[
                  _buildMiniStat('Clients', user.clientsConverted, isDark),
                  const SizedBox(width: 12),
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

          // Actions
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showUserDetailDialog(user, isDark, state),
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'View Details',
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                  splashRadius: 16,
                ),
                IconButton(
                  onPressed: () => context.go('/admin/team/${user.id}/edit'),
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Edit',
                  color: AppColors.gold,
                  splashRadius: 16,
                ),
                IconButton(
                  onPressed: () => state.toggleCrmUserStatus(user.id),
                  icon: Icon(
                    user.status == CrmUserStatus.active
                        ? Icons.person_off
                        : Icons.person,
                    size: 18,
                  ),
                  tooltip:
                      user.status == CrmUserStatus.active
                          ? 'Deactivate'
                          : 'Activate',
                  color:
                      user.status == CrmUserStatus.active
                          ? AppColors.criticalRed
                          : AppColors.successGreen,
                  splashRadius: 16,
                ),
              ],
            ),
          ),
        ],
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
