import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/utils/extensions.dart';

class MobileShell extends StatefulWidget {
  final Widget child;

  const MobileShell({super.key, required this.child});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/sourcing',
    ),
    _TabItem(
      icon: Icons.person_search_outlined,
      activeIcon: Icons.person_search,
      label: 'Available Candidates',
      route: '/sourcing/candidates',
    ),
    _TabItem(
      icon: Icons.assignment_ind_outlined,
      activeIcon: Icons.assignment_ind,
      label: 'Placed Candidates',
      route: '/sourcing/candidates/placed',
    ),
    _TabItem(
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel,
      label: 'Disputes & Issues',
      route: '/sourcing/candidates/disputes',
    ),
    _TabItem(
      icon: Icons.person_add_outlined,
      activeIcon: Icons.person_add,
      label: 'Add Candidate',
      route: '/sourcing/add_candidate',
    ),
    _TabItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'Learning',
      route: '/sourcing/learning',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].route) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.navyBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/assets/applogo.png', width: 32, height: 32),
            const SizedBox(width: 10),
            Text(
              'Verified Maids',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () async {
              await UserManager().clearUser();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(width: 4),
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
          indicatorColor:
              isDark
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.navyBlue,
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
