import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/theme/theme_provider.dart';
import 'package:practice_app/screens/shared/notification_panel.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:provider/provider.dart';

class ExecutiveShell extends StatefulWidget {
  final Widget child;
  const ExecutiveShell({super.key, required this.child});

  @override
  State<ExecutiveShell> createState() => _ExecutiveShellState();
}

class _ExecutiveShellState extends State<ExecutiveShell> {
  int _currentIndex = 0;

  final List<_TabItem> _tabs = [
    const _TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Data',
      route: '/executive',
    ),
    const _TabItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Tasks',
      route: '/executive/tasks',
    ),
    const _TabItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/executive/profile',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere(
      (t) =>
          location.startsWith(t.route) &&
          (t.route == '/executive' ? location == '/executive' : true),
    );
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  String _getPageTitle(String location) {
    if (location == '/executive') return 'Executive Dashboard';
    if (location == '/executive/tasks') return 'My Tasks';
    if (location == '/executive/profile') return 'Profile';
    if (location.startsWith('/executive/tasks/')) return 'Task Details';
    return 'Verified Maids';
  }

  bool _isRootRoute(String location) {
    return location == '/executive' ||
        location == '/executive/tasks' ||
        location == '/executive/profile';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final appState = Provider.of<GlobalAppState>(context);

    return Scaffold(
      endDrawer: const NotificationPanel(),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.goldDark,
        foregroundColor: isDark ? AppColors.white : AppColors.goldDark,
        title: Text(
          _getPageTitle(currentLocation),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: !_isRootRoute(currentLocation),
        leading:
            !_isRootRoute(currentLocation)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/executive/tasks');
                    }
                  },
                )
                : null,
        actions: [
          IconButton(
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 22),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme(!isDark);
            },
          ),
          Builder(
            builder: (context) {
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
          const SizedBox(width: 16),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            context.go(_tabs[index].route);
          },
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          indicatorColor: AppColors.gold.withValues(alpha: 0.15),

          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations:
              _tabs.map((tab) {
                return NavigationDestination(
                  icon: Icon(tab.icon, color: AppColors.grey500),
                  selectedIcon: Icon(tab.activeIcon, color: AppColors.gold),
                  label: tab.label,
                );
              }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
