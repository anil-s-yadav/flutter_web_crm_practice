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
            route: '/admin/candidates',
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'Clients',
            route: '/admin/clients',
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
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/sales',
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
            label: 'Clients',
            route: '/sales/clients',
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Candidate Pool',
            route: '/sales/candidates',
          ),
          _SidebarItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Contracts',
            route: '/sales/contracts',
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
            label: 'Hired Candidates',
            route: '/sourcing/candidates/hired',
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
        ];
      case UserRole.executive:
        return [];
    }
  }

  bool _isRouteActive(String route, String currentLocation) {
    if (route == '/admin' || route == '/sales' || route == '/sourcing') {
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

    if (isNarrow) {
      return Scaffold(
        appBar: _buildAppBar(isDark, currentLocation, timerProvider),
        drawer: _buildDrawer(isDark, currentLocation, user),
        body: widget.child,
      );
    }

    return Scaffold(
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

  PreferredSizeWidget _buildAppBar(
    bool isDark,
    String currentLocation,
    LogoutTimerProvider timerProvider,
  ) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.navyBlue,
      foregroundColor: AppColors.white,
      title: Text(
        _getPageTitle(currentLocation),
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        // _buildTimerChip(timerProvider),
        _buildThemeToggle(isDark),
        IconButton(
          icon: const Icon(Icons.fullscreen, size: 22),
          onPressed: toggleFullScreen,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          onPressed: () {},
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
        color: isDark ? AppColors.darkSurface : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
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
              'Verified Candidates',
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
                      ? (isDark
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : AppColors.navyBlue.withValues(alpha: 0.08))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border:
                  isActive && isDark
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
                          color:
                              isActive
                                  ? (isDark
                                      ? AppColors.gold
                                      : AppColors.navyBlue)
                                  : (isDark
                                      ? AppColors.grey400
                                      : AppColors.grey600),
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
                                      ? (isDark
                                          ? AppColors.gold
                                          : AppColors.navyBlue)
                                      : (isDark
                                          ? AppColors.grey300
                                          : AppColors.grey600),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Tooltip(
                        message: item.label,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color:
                              isActive
                                  ? (isDark
                                      ? AppColors.gold
                                      : AppColors.navyBlue)
                                  : (isDark
                                      ? AppColors.grey400
                                      : AppColors.grey600),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
          const SizedBox(width: 16),

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
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: Icon(
                Icons.notifications_outlined,
                size: 22,
                color: isDark ? AppColors.grey300 : AppColors.navyBlue,
              ),
            ),
            onPressed: () {},
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
        color: isDark ? AppColors.grey300 : AppColors.grey600,
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
    if (location.endsWith('/candidates/ready')) return 'Ready to Place';
    if (location.endsWith('/candidates/new')) return 'Newly Added';
    if (location.endsWith('/candidates/verification')) return 'Verification Pending';
    if (location.endsWith('/candidates/medical')) return 'Medical Pending';
    if (location.endsWith('/candidates/hired')) return 'Hired Candidates';
    if (location.endsWith('/candidates/blacklisted'))
      return 'Blacklisted Candidates';

    // Generic sub-routes
    if (location.endsWith('/candidates')) return 'Candidate Directory';
    if (location.contains('/candidates/')) return 'Candidate Profile';
    if (location.endsWith('/clients')) return 'Clients';
    if (location.contains('/clients/')) return 'Client Profile';
    if (location.endsWith('/contracts')) return 'Contracts';
    if (location.endsWith('/tickets')) return 'Tickets';
    if (location.endsWith('/settings')) return 'Settings';
    if (location.endsWith('/audit')) return 'Audit Trail';

    // Dashboards
    if (location == '/admin') return 'Admin Dashboard';
    if (location == '/sales') return 'Sales Dashboard';
    if (location == '/sourcing') return 'Sourcing Dashboard';
    if (location == '/executive') return 'Executive Dashboard';

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

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
