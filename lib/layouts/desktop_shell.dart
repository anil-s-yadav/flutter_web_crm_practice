import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/auth/logout_timer_provider.dart';
import 'package:practice_app/theme/theme_provider.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/utils/fullscreen.dart';
import 'package:practice_app/screens/shared/notification_panel.dart';
import 'package:practice_app/providers/global_app_state.dart';

class DesktopShell extends StatefulWidget {
  final Widget child;

  const DesktopShell({super.key, required this.child});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  bool _sidebarExpanded = true;

  List<_SidebarItem> get _menuItems {
    final role = UserManager().currentUser?.role ?? UserRole.admin;
    switch (role) {
      case UserRole.admin:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/admin',
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Candidates',
            route: '/admin/candidates/ready',
            children: [
              _SidebarItem(
                icon: Icons.fiber_new_outlined,
                activeIcon: Icons.fiber_new,
                label: 'Newly Added',
                route: '/admin/candidates/new',
              ),
              _SidebarItem(
                icon: Icons.fact_check_outlined,
                activeIcon: Icons.fact_check,
                label: 'Verification',
                route: '/admin/candidates/verification',
              ),
              _SidebarItem(
                icon: Icons.medical_services_outlined,
                activeIcon: Icons.medical_services,
                label: 'Medical',
                route: '/admin/candidates/medical',
              ),
              _SidebarItem(
                icon: Icons.check_circle_outline,
                activeIcon: Icons.check_circle,
                label: 'Ready to Place',
                route: '/admin/candidates/ready',
              ),
              _SidebarItem(
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: 'Placed',
                route: '/admin/candidates/placed',
              ),
              _SidebarItem(
                icon: Icons.block_outlined,
                activeIcon: Icons.block,
                label: 'Blacklisted',
                route: '/admin/candidates/blacklisted',
              ),
            ],
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'Clients',
            route: '/admin/clients',
            children: [
              _SidebarItem(
                icon: Icons.record_voice_over_outlined,
                activeIcon: Icons.record_voice_over,
                label: 'Follow Ups',
                route: '/admin/clients/followup',
              ),
              _SidebarItem(
                icon: Icons.lightbulb_outline,
                activeIcon: Icons.lightbulb,
                label: 'Interested',
                route: '/admin/clients/interested',
              ),
              _SidebarItem(
                icon: Icons.thumb_down_outlined,
                activeIcon: Icons.thumb_down,
                label: 'Not Interested',
                route: '/admin/clients/not_interested',
              ),
              _SidebarItem(
                icon: Icons.handshake_outlined,
                activeIcon: Icons.handshake,
                label: 'Converted (Active)',
                route: '/admin/clients/active',
              ),
              _SidebarItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'Inactive / Past',
                route: '/admin/clients/past',
              ),
            ],
          ),
          _SidebarItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Contracts',
            route: '/admin/contracts',
          ),
          _SidebarItem(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number,
            label: 'Tickets',
            route: '/admin/tickets',
          ),
          _SidebarItem(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Team',
            route: '/admin/team',
            children: [
              _SidebarItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'All Members',
                route: '/admin/team',
              ),
              _SidebarItem(
                icon: Icons.handshake_outlined,
                activeIcon: Icons.handshake,
                label: 'Sales Team',
                route: '/admin/team/sales',
              ),
              _SidebarItem(
                icon: Icons.person_search_outlined,
                activeIcon: Icons.person_search,
                label: 'Sourcing Team',
                route: '/admin/team/sourcing',
              ),
              _SidebarItem(
                icon: Icons.directions_run_outlined,
                activeIcon: Icons.directions_run,
                label: 'Executives',
                route: '/admin/team/executives',
              ),
            ],
          ),
          _SidebarItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'Audit Trail',
            route: '/admin/audit',
          ),
          _SidebarItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Learning',
            route: '/admin/learning',
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            route: '/admin/settings',
          ),
        ];
      case UserRole.sales:
        return [
          _SidebarItem(
            icon: Icons.person_add_alt_1_outlined,
            activeIcon: Icons.person_add_alt_1,
            label: 'Add Client',
            route: '/sales/add_client',
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/sales',
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'All Clients',
            route: '/sales/clients',
            children: [
              _SidebarItem(
                icon: Icons.record_voice_over_outlined,
                activeIcon: Icons.record_voice_over,
                label: 'Follow Ups',
                route: '/sales/clients/followup',
              ),
              _SidebarItem(
                icon: Icons.lightbulb_outline,
                activeIcon: Icons.lightbulb,
                label: 'Interested',
                route: '/sales/clients/interested',
              ),
              _SidebarItem(
                icon: Icons.thumb_down_outlined,
                activeIcon: Icons.thumb_down,
                label: 'Not Interested',
                route: '/sales/clients/not_interested',
              ),
              _SidebarItem(
                icon: Icons.check_circle_outline,
                activeIcon: Icons.check_circle,
                label: 'Converted (Active)',
                route: '/sales/clients/active',
              ),
              _SidebarItem(
                icon: Icons.person_off_outlined,
                activeIcon: Icons.person_off,
                label: 'Inactive / Past',
                route: '/sales/clients/past',
              ),
            ],
          ),
          _SidebarItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Contracts',
            route: '/sales/contracts',
            children: [
              _SidebarItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'Active Contracts',
                route: '/sales/contracts/active',
              ),
              _SidebarItem(
                icon: Icons.autorenew_outlined,
                activeIcon: Icons.autorenew,
                label: 'Renewals',
                route: '/sales/contracts/renewals',
              ),
              _SidebarItem(
                icon: Icons.swap_horiz_outlined,
                activeIcon: Icons.swap_horiz,
                label: 'Replacements',
                route: '/sales/contracts/replacements',
              ),
            ],
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Candidate Pool',
            route: '/sales/candidates',
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Financials',
            route: '/sales/financials',
          ),
          _SidebarItem(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number,
            label: 'Tickets',
            route: '/sales/tickets',
          ),
          _SidebarItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Learning',
            route: '/sales/learning',
          ),
        ];
      case UserRole.sourcing:
        return [
          _SidebarItem(
            icon: Icons.person_add_outlined,
            activeIcon: Icons.person_add,
            label: 'Add Candidate',
            route: '/sourcing/add_candidate',
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/sourcing',
          ),
          _SidebarItem(
            icon: Icons.verified_outlined,
            activeIcon: Icons.verified,
            label: 'Ready to Place',
            route: '/sourcing/candidates/ready',
          ),
          _SidebarItem(
            icon: Icons.new_releases_outlined,
            activeIcon: Icons.new_releases,
            label: 'Newly Added',
            route: '/sourcing/candidates/new',
          ),
          _SidebarItem(
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check,
            label: 'Verification Pending',
            route: '/sourcing/candidates/verification',
          ),
          _SidebarItem(
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services,
            label: 'Medical Pending',
            route: '/sourcing/candidates/medical',
          ),
          _SidebarItem(
            icon: Icons.assignment_ind_outlined,
            activeIcon: Icons.assignment_ind,
            label: 'Placed Candidates',
            route: '/sourcing/candidates/placed',
          ),
          _SidebarItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Learning',
            route: '/sourcing/learning',
          ),
          _SidebarItem(
            icon: Icons.block_outlined,
            activeIcon: Icons.block,
            label: 'Blacklisted',
            route: '/sourcing/candidates/blacklisted',
          ),
          _SidebarItem(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number,
            label: 'Tickets',
            route: '/sourcing/tickets',
          ),
        ];
      case UserRole.executive:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/executive',
          ),
          _SidebarItem(
            icon: Icons.task_outlined,
            activeIcon: Icons.task,
            label: 'My Tasks',
            route: '/executive/tasks',
          ),
          _SidebarItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            label: 'Rewards & Bonus',
            route: '/executive/rewards',
          ),
        ];
    }
  }

  bool _isRouteActive(String route, String currentLocation) {
    if (route == '/admin' ||
        route == '/sales' ||
        route == '/sourcing' ||
        route == '/executive') {
      return currentLocation == route;
    }

    if (route == '/sales/clients/followup') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=followUp');
    }
    if (route == '/sales/clients/interested') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=interested');
    }
    if (route == '/sales/clients/not_interested') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=notInterested');
    }
    if (route == '/sales/clients/active') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=converted');
    }
    if (route == '/sales/clients/past') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=past');
    }

    if (route == '/sales/contracts/active') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('fromContractMode=active');
    }
    if (route == '/sales/contracts/renewals') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('fromContractMode=renewals');
    }
    if (route == '/sales/contracts/replacements') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('fromContractMode=replacements');
    }

    if (route == '/sourcing/candidates/ready') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=readyToPlace');
    }
    if (route == '/sourcing/candidates/new') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=newlyAdded');
    }
    if (route == '/sourcing/candidates/verification') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=verificationPending');
    }
    if (route == '/sourcing/candidates/medical') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=medicalPending');
    }
    if (route == '/sourcing/candidates/placed') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=placed');
    }
    if (route == '/sourcing/candidates/blacklisted') {
      return currentLocation.startsWith(route) ||
          currentLocation.contains('from=blacklisted');
    }

    if (route == '/sales/clients') {
      return currentLocation == route ||
          (currentLocation.startsWith('/sales/clients/') &&
              !currentLocation.startsWith('/sales/clients/followup') &&
              !currentLocation.startsWith('/sales/clients/interested') &&
              !currentLocation.startsWith('/sales/clients/not_interested') &&
              !currentLocation.startsWith('/sales/clients/active') &&
              !currentLocation.startsWith('/sales/clients/past') &&
              !currentLocation.contains('from=') &&
              !currentLocation.contains('fromContractMode='));
    }

    if (route == '/sales/contracts') {
      return currentLocation == route ||
          (currentLocation.startsWith('/sales/contracts/') &&
              !currentLocation.startsWith('/sales/contracts/active') &&
              !currentLocation.startsWith('/sales/contracts/renewals') &&
              !currentLocation.startsWith('/sales/contracts/replacements') &&
              !currentLocation.contains('fromContractMode='));
    }

    if (route == '/admin/team') {
      return currentLocation == route;
    }
    if (route == '/admin/team/sales') {
      return currentLocation == route;
    }
    if (route == '/admin/team/sourcing') {
      return currentLocation == route;
    }
    if (route == '/admin/team/executives') {
      return currentLocation == route;
    }

    return currentLocation.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isNarrow = context.media.width < 800;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final user = UserManager().currentUser;
    final timerProvider = context.watch<LogoutTimerProvider>();

    String dashboardPath = '/login';
    if (currentLocation.startsWith('/admin')) {
      dashboardPath = '/admin';
    } else if (currentLocation.startsWith('/sales')) {
      dashboardPath = '/sales';
    } else if (currentLocation.startsWith('/sourcing')) {
      dashboardPath = '/sourcing';
    } else if (currentLocation.startsWith('/executive')) {
      dashboardPath = '/executive';
    }

    final bool isDashboard = currentLocation == dashboardPath;

    Widget mainScaffold;

    if (isNarrow) {
      mainScaffold = Scaffold(
        endDrawer: const NotificationPanel(),
        appBar: _buildAppBar(context, isDark, currentLocation, timerProvider),
        drawer: _buildDrawer(isDark, currentLocation, user),
        body: widget.child,
      );
    } else {

      mainScaffold = Scaffold(
      endDrawer: const NotificationPanel(),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(isDark, currentLocation, user),
          // Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDark, currentLocation, timerProvider),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
    }

    return PopScope(
      canPop: isDashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!isDashboard) {
          context.go(dashboardPath);
        }
      },
      child: mainScaffold,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    String currentLocation,
    LogoutTimerProvider timerProvider,
  ) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.gold,
      title: Text(
        _getPageTitle(currentLocation),
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        // _buildTimerChip(timerProvider),
        _buildThemeToggle(isDark),
        if (context.media.width >= 600)
          IconButton(
            icon: const Icon(Icons.fullscreen, size: 22),
            onPressed: toggleFullScreen,
          ),
        Builder(
          builder: (context) {
            final appState = Provider.of<GlobalAppState>(context);
            return Badge(
              isLabelVisible: appState.unreadNotificationCount > 0,
              label: Text(
                appState.unreadNotificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.errorRed,
              offset: const Offset(-8, 8),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(bool isDark, String currentLocation, UserModel? user) {
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildBrandHeader(true, isDark),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children:
                  _menuItems.map((item) {
                    final isActive = _isRouteActive(
                      item.route,
                      currentLocation,
                    );
                    return _buildMenuItem(item, isActive, true, isDark);
                  }).toList(),
            ),
          ),
          _buildUserSection(user, true, isDark),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark, String currentLocation, UserModel? user) {
    final width = _sidebarExpanded ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.grey50,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBrandHeader(_sidebarExpanded, isDark),
          const SizedBox(height: 8),

          // Toggle button
          Align(
            alignment:
                _sidebarExpanded ? Alignment.centerRight : Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: AppColors.grey500,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _sidebarExpanded = !_sidebarExpanded);
                },
              ),
            ),
          ),
          Divider(
            color: isDark ? AppColors.grey700 : AppColors.grey200,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(height: 8),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children:
                  _menuItems.map((item) {
                    final isActive = _isRouteActive(
                      item.route,
                      currentLocation,
                    );
                    return _buildMenuItem(
                      item,
                      isActive,
                      _sidebarExpanded,
                      isDark,
                    );
                  }).toList(),
            ),
          ),

          // User section
          _buildUserSection(user, _sidebarExpanded, isDark),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(bool expanded, bool isDark) {
    if (!expanded) {
      return Image.asset('lib/assets/applogo.png', width: 40, height: 40);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset('lib/assets/applogo.png', width: 36, height: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Verified Maids',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.gold : AppColors.navyBlue,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    _SidebarItem item,
    bool isActive,
    bool expanded,
    bool isDark,
  ) {
    if (item.children != null && item.children!.isNotEmpty) {
      bool isAnyChildActive =
          isActive ||
          item.children!.any(
            (c) => _isRouteActive(
              c.route,
              GoRouterState.of(context).uri.toString(),
            ),
          );

      return Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isAnyChildActive || expanded,
            tilePadding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
            collapsedIconColor:
                isAnyChildActive ? AppColors.gold : AppColors.grey400,
            iconColor: AppColors.gold,
            title:
                expanded
                    ? Row(
                      children: [
                        Icon(
                          isAnyChildActive ? item.activeIcon : item.icon,
                          size: 20,
                          color:
                              isAnyChildActive
                                  ? AppColors.gold
                                  : AppColors.grey400,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight:
                                  isAnyChildActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  isAnyChildActive
                                      ? AppColors.gold
                                      : (isDark
                                          ? AppColors.grey300
                                          : AppColors.navyBlue),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                    : Icon(
                      isAnyChildActive ? item.activeIcon : item.icon,
                      size: 20,
                      color:
                          isAnyChildActive ? AppColors.gold : AppColors.grey400,
                    ),
            children:
                expanded
                    ? item.children!.map((child) {
                      final isChildActive = _isRouteActive(
                        child.route,
                        GoRouterState.of(context).uri.toString(),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(left: 24.0, bottom: 4.0),
                        child: _buildMenuItem(
                          child,
                          isChildActive,
                          expanded,
                          isDark,
                        ),
                      );
                    }).toList()
                    : [],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.go(item.route);
            if (context.media.width < 800) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 14 : 0,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColors.gold.withValues(alpha: 0.12)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border:
                  isActive
                      ? Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        width: 1,
                      )
                      : null,
            ),
            child:
                expanded
                    ? Row(
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 20,
                          color: isActive ? AppColors.gold : AppColors.grey400,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isActive
                                      ? AppColors.gold
                                      : (isDark
                                          ? AppColors.grey300
                                          : AppColors.navyBlue),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                    : Tooltip(
                      message: item.label,
                      child: Center(
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? AppColors.gold : AppColors.grey400,
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(UserModel? user, bool expanded, bool isDark) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                isDark
                    ? AppColors.grey700.withValues(alpha: 0.5)
                    : AppColors.grey200,
          ),
        ),
      ),
      child:
          expanded
              ? Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.gold : AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.role.name.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark
                                    ? AppColors.gold.withValues(alpha: 0.7)
                                    : AppColors.navyBlue.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      size: 18,
                      color: AppColors.grey400,
                    ),
                    tooltip: 'Logout',
                    onPressed: () => _handleLogout(),
                  ),
                ],
              )
              : IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.grey400,
                ),
                tooltip: 'Logout',
                onPressed: () => _handleLogout(),
              ),
    );
  }

  Widget _buildTopBar(
    bool isDark,
    String currentLocation,
    LogoutTimerProvider timerProvider,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Page title
          Text(
            _getPageTitle(currentLocation),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const Spacer(),

          // Search bar
          Container(
            width: 240,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, size: 18, color: AppColors.grey500),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.grey500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (currentLocation.startsWith('/sales/clients') ||
              currentLocation.startsWith('/admin/clients'))
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/sales/add_client'),
                icon: const Icon(Icons.add),
                label: const Text('Add Client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          if (currentLocation.startsWith('/sales/tickets') ||
              currentLocation.startsWith('/sourcing/tickets') ||
              currentLocation.startsWith('/admin/tickets'))
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  /* TODO: Add ticket logic */
                },
                icon: const Icon(Icons.add),
                label: const Text('New Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          const SizedBox(width: 24),

          // Timer
          // _buildTimerChip(timerProvider),
          const SizedBox(width: 8),

          // Theme toggle
          _buildThemeToggle(isDark),
          const SizedBox(width: 4),

          // Fullscreen toggle
          IconButton(
            icon: Icon(
              Icons.fullscreen,
              size: 22,
              color: isDark ? AppColors.grey300 : AppColors.navyBlue,
            ),
            onPressed: toggleFullScreen,
          ),
          const SizedBox(width: 4),

          // Notifications
          Builder(
            builder: (context) {
              final appState = Provider.of<GlobalAppState>(context);
              return Badge(
                isLabelVisible: appState.unreadNotificationCount > 0,
                label: Text(
                  appState.unreadNotificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.errorRed,
                offset: const Offset(-8, 8),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: isDark ? AppColors.grey300 : AppColors.navyBlue,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildTimerChip(LogoutTimerProvider timerProvider) {
  //   final remaining = timerProvider.remaining;
  //   final hours = remaining.inHours.toString().padLeft(2, '0');
  //   final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
  //   final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: AppColors.gold.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const Icon(Icons.timer_outlined, size: 14, color: AppColors.gold),
  //         const SizedBox(width: 4),
  //         Text(
  //           '$hours:$minutes:$seconds',
  //           style: GoogleFonts.poppins(
  //             fontSize: 11,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.gold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildThemeToggle(bool isDark) {
    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 20,
        // color: isDark ? AppColors.grey300 : AppColors.grey600,
      ),
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      onPressed: () {
        context.read<ThemeProvider>().toggleTheme(!isDark);
      },
    );
  }

  String _getPageTitle(String location) {
    // Sourcing / Admin specific routes
    if (location.endsWith('/learning')) return 'Learning Center';
    if (location.endsWith('/add_candidate')) return 'Add Candidate';
    if (location.endsWith('/add_client')) return 'Add Client';
    if (location.endsWith('/candidates/ready')) return 'Ready to Place';
    if (location.endsWith('/candidates/new')) return 'Newly Added';
    if (location.endsWith('/candidates/verification')) {
      return 'Verification Pending';
    }
    if (location.endsWith('/candidates/medical')) return 'Medical Pending';
    if (location.endsWith('/candidates/placed')) return 'PlacedCandidates';
    if (location.endsWith('/candidates/blacklisted')) {
      return 'Blacklisted Candidates';
    }

    // Generic sub-routes
    if (location.endsWith('/candidates')) return 'Candidate Directory';
    if (location.contains('/candidates/') && location.endsWith('/edit')) {
      return 'Edit Candidate Details';
    }
    if (location.contains('/candidates/')) return 'Candidate Profile';
    if (location.endsWith('/clients')) return 'Clients';
    if (location.endsWith('/clients/new')) return 'New Inquiries';
    if (location.endsWith('/clients/followup')) return 'Follow Ups';
    if (location.endsWith('/clients/active')) return 'Converted (Active)';
    if (location.contains('/clients/') && location.endsWith('/edit')) {
      return 'Edit Client Details';
    }
    if (location.contains('/clients/')) return 'Client Profile';
    if (location.endsWith('/contracts')) return 'Contracts';
    if (location.endsWith('/tickets')) return 'Tickets';
    if (location.contains('/tickets/')) return 'Ticket Details';
    if (location.endsWith('/settings')) return 'Settings';
    if (location.endsWith('/audit')) return 'Audit Trail';

    // Dashboards
    if (location == '/admin') return 'Admin Dashboard';
    if (location == '/sales') return 'Sales Dashboard';
    if (location == '/sourcing') return 'Sourcing Dashboard';
    if (location == '/executive') return 'Executive Dashboard';
    if (location == '/executive/tasks') return 'My Tasks';
    if (location == '/executive/rewards') return 'Rewards & Bonus';

    if (location.endsWith('/clients/interested')) return 'Interested Clients';
    if (location.endsWith('/clients/not_interested')) return 'Not Interested';
    if (location.endsWith('/clients/active')) return 'Active Clients';
    if (location.endsWith('/clients/past')) return 'Inactive / Past Clients';
    if (location.endsWith('/clients')) return 'All Clients';

    if (location.endsWith('/contracts/active')) return 'Active Contracts';
    if (location.endsWith('/contracts/renewals')) return 'Renewals';
    if (location.endsWith('/contracts/replacements')) return 'Replacements';
    if (location.endsWith('/contracts')) return 'Contracts';

    if (location.endsWith('/financials')) return 'Financials & Payments';

    if (location == '/admin/team') return 'Team Management';
    if (location == '/admin/team/sales') return 'Sales Team';
    if (location == '/admin/team/sourcing') return 'Sourcing Team';
    if (location == '/admin/team/executives') return 'Executives';
    if (location == '/admin/team/add') return 'Add Team Member';
    if (location.contains('/admin/team/') && location.endsWith('/edit')) {
      return 'Edit Team Member';
    }

    return 'Dashboard';
  }

  Future<void> _handleLogout() async {
    await UserManager().clearUser();
    context.read<LogoutTimerProvider>().stopCountdown();
    if (mounted) {
      context.go('/login');
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final List<_SidebarItem>? children;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.children,
  });
}
