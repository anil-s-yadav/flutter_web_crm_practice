import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice_app/auth/login_screen.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/layouts/desktop_shell.dart';
import 'package:practice_app/layouts/mobile_shell.dart';
import 'package:practice_app/screens/admin/admin_dashboard.dart';
import 'package:practice_app/screens/admin/admin_audit_trail_screen.dart';
import 'package:practice_app/screens/sales/sales_dashboard.dart';
import 'package:practice_app/screens/sourcing/sourcing_dashboard.dart';
import 'package:practice_app/screens/shared/learning_screen.dart';
import 'package:practice_app/screens/executive/executive_dashboard.dart';
import 'package:practice_app/screens/maids/maid_directory_screen.dart';
import 'package:practice_app/screens/maids/maid_profile_screen.dart';
import 'package:practice_app/screens/clients/client_list_screen.dart';
import 'package:practice_app/screens/sales/client_profile_screen.dart';
import 'package:practice_app/screens/contracts/contract_list_screen.dart';
import 'package:practice_app/screens/tickets/ticket_list_screen.dart';
import 'package:practice_app/screens/sourcing/add_candidate_screen.dart';
import 'package:practice_app/screens/maids/edit_maid_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = UserManager().isLoggedIn;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoginRoute) return '/login';
        if (isLoggedIn && isLoginRoute) return UserManager().homeRoute;
        if (isLoggedIn && state.matchedLocation == '/') {
          return UserManager().homeRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        // Admin shell
        ShellRoute(
          builder: (context, state, child) => DesktopShell(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboard(),
            ),
            GoRoute(
              path: '/admin/maids/ready',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.readyToPlace),
            ),
            GoRoute(
              path: '/admin/maids/new',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.newlyAdded),
            ),
            GoRoute(
              path: '/admin/maids/verification',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.verificationPending),
            ),
            GoRoute(
              path: '/admin/maids/medical',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.medicalPending),
            ),
            GoRoute(
              path: '/admin/maids/hired',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.hired),
            ),
            GoRoute(
              path: '/admin/maids/blacklisted',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.blacklisted),
            ),
            GoRoute(
              path: '/admin/maids/:id',
              builder:
                  (context, state) =>
                      MaidProfileScreen(maidId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/maids/:id/edit',
              builder: (context, state) => EditMaidScreen(
                maidId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/admin/clients',
              builder: (context, state) => const ClientListScreen(),
            ),
            GoRoute(
              path: '/admin/audit',
              builder: (context, state) => const AdminAuditTrailScreen(),
            ),
            GoRoute(
              path: '/admin/clients/:id',
              builder:
                  (context, state) =>
                      ClientProfileScreen(clientId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/contracts',
              builder: (context, state) => const ContractListScreen(),
            ),
            GoRoute(
              path: '/admin/tickets',
              builder: (context, state) => const TicketListScreen(),
            ),
            GoRoute(
              path: '/admin/settings',
              builder:
                  (context, state) => const Scaffold(
                    body: Center(child: Text('Settings - Coming Soon')),
                  ),
            ),
            GoRoute(
              path: '/admin/learning',
              builder: (context, state) => const LearningScreen(),
            ),
          ],
        ),
        // Sales shell
        ShellRoute(
          builder: (context, state, child) => DesktopShell(child: child),
          routes: [
            GoRoute(
              path: '/sales',
              builder: (context, state) => const SalesDashboard(),
            ),
            GoRoute(
              path: '/sales/clients',
              builder: (context, state) => const ClientListScreen(),
            ),
            GoRoute(
              path: '/sales/clients/:id',
              builder:
                  (context, state) =>
                      ClientProfileScreen(clientId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/sales/maids',
              builder:
                  (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.readyToPlace, readOnly: true),
            ),
            GoRoute(
              path: '/sales/contracts',
              builder: (context, state) => const ContractListScreen(),
            ),
            GoRoute(
              path: '/sales/tickets',
              builder: (context, state) => const TicketListScreen(),
            ),
            GoRoute(
              path: '/sales/learning',
              builder: (context, state) => const LearningScreen(),
            ),
          ],
        ),
        // Sourcing shell
        ShellRoute(
          builder: (context, state, child) => DesktopShell(child: child),
          routes: [
            GoRoute(
              path: '/sourcing',
              builder: (context, state) => const SourcingDashboard(),
            ),
            GoRoute(
              path: '/sourcing/add_candidate',
              builder: (context, state) => const AddCandidateScreen(),
            ),
            GoRoute(
              path: '/sourcing/learning',
              builder: (context, state) => const LearningScreen(),
            ),
            GoRoute(
              path: '/sourcing/maids/ready',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.readyToPlace),
            ),
            GoRoute(
              path: '/sourcing/maids/new',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.newlyAdded),
            ),
            GoRoute(
              path: '/sourcing/maids/verification',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.verificationPending),
            ),
            GoRoute(
              path: '/sourcing/maids/medical',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.medicalPending),
            ),
            GoRoute(
              path: '/sourcing/maids/hired',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.hired),
            ),
            GoRoute(
              path: '/sourcing/maids/blacklisted',
              builder: (context, state) => const MaidDirectoryScreen(type: MaidDirectoryType.blacklisted),
            ),
            GoRoute(
              path: '/sourcing/maids/:id',
              builder: (context, state) => MaidProfileScreen(
                maidId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/sourcing/maids/:id/edit',
              builder: (context, state) => EditMaidScreen(
                maidId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        // Executive shell (mobile)
        ShellRoute(
          builder: (context, state, child) => MobileShell(child: child),
          routes: [
            GoRoute(
              path: '/executive',
              builder: (context, state) => const ExecutiveDashboard(),
            ),
            GoRoute(
              path: '/executive/tasks',
              builder:
                  (context, state) =>
                      const Scaffold(body: Center(child: Text('All Tasks'))),
            ),
            GoRoute(
              path: '/executive/rewards',
              builder:
                  (context, state) => const Scaffold(
                    body: Center(child: Text('Rewards & Bonuses')),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
