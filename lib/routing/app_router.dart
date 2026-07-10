import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice_app/auth/login_screen.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/layouts/desktop_shell.dart';
import 'package:practice_app/layouts/mobile_shell.dart';
import 'package:practice_app/layouts/executive_shell.dart';
import 'package:practice_app/screens/admin/admin_dashboard.dart';
import 'package:practice_app/screens/admin/admin_audit_trail_screen.dart';
import 'package:practice_app/screens/sales/sales_dashboard.dart';
import 'package:practice_app/screens/sourcing/sourcing_dashboard.dart';
import 'package:practice_app/screens/shared/learning_screen.dart';
import 'package:practice_app/screens/executive/executive_dashboard.dart';
import 'package:practice_app/screens/executive/executive_tasks_screen.dart';
import 'package:practice_app/screens/executive/executive_task_detail_screen.dart';
import 'package:practice_app/screens/executive/executive_profile_screen.dart';
import 'package:practice_app/screens/candidates/candidate_directory_screen.dart';
import 'package:practice_app/screens/candidates/candidate_profile_screen.dart';
import 'package:practice_app/screens/clients/client_list_screen.dart';
import 'package:practice_app/screens/sales/client_profile_screen.dart';
import 'package:practice_app/screens/contracts/contract_list_screen.dart';
import 'package:practice_app/screens/tickets/ticket_list_screen.dart';
import 'package:practice_app/screens/sourcing/add_candidate_screen.dart';
import 'package:practice_app/screens/candidates/edit_candidate_screen.dart';

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
              path: '/admin/candidates/ready',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.readyToPlace),
            ),
            GoRoute(
              path: '/admin/candidates/new',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.newlyAdded),
            ),
            GoRoute(
              path: '/admin/candidates/verification',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.verificationPending),
            ),
            GoRoute(
              path: '/admin/candidates/medical',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.medicalPending),
            ),
            GoRoute(
              path: '/admin/candidates/hired',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.hired),
            ),
            GoRoute(
              path: '/admin/candidates/blacklisted',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.blacklisted),
            ),
            GoRoute(
              path: '/admin/candidates/:id',
              builder:
                  (context, state) =>
                      CandidateProfileScreen(candidateId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/candidates/:id/edit',
              builder: (context, state) => EditCandidateScreen(
                candidateId: state.pathParameters['id']!,
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
              path: '/sales/candidates',
              builder:
                  (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.readyToPlace, readOnly: true),
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
              path: '/sourcing/candidates/ready',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.readyToPlace),
            ),
            GoRoute(
              path: '/sourcing/candidates/new',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.newlyAdded),
            ),
            GoRoute(
              path: '/sourcing/candidates/verification',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.verificationPending),
            ),
            GoRoute(
              path: '/sourcing/candidates/medical',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.medicalPending),
            ),
            GoRoute(
              path: '/sourcing/candidates/hired',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.hired),
            ),
            GoRoute(
              path: '/sourcing/candidates/blacklisted',
              builder: (context, state) => const CandidateDirectoryScreen(type: CandidateDirectoryType.blacklisted),
            ),
            GoRoute(
              path: '/sourcing/candidates/:id',
              builder: (context, state) => CandidateProfileScreen(
                candidateId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/sourcing/candidates/:id/edit',
              builder: (context, state) => EditCandidateScreen(
                candidateId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        // Executive shell
        ShellRoute(
          builder: (context, state, child) => ExecutiveShell(child: child),
          routes: [
            GoRoute(
              path: '/executive',
              builder: (context, state) => const ExecutiveDashboard(),
            ),
            GoRoute(
              path: '/executive/tasks',
              builder: (context, state) => const ExecutiveTasksScreen(),
            ),
            GoRoute(
              path: '/executive/profile',
              builder: (context, state) => const ExecutiveProfileScreen(),
            ),
            GoRoute(
              path: '/executive/tasks/:id',
              builder: (context, state) => ExecutiveTaskDetailScreen(
                taskId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
