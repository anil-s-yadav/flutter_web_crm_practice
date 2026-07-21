import 'package:go_router/go_router.dart';
import 'package:practice_app/auth/login_screen.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/layouts/desktop_shell.dart';
import 'package:practice_app/layouts/executive_shell.dart';
import 'package:practice_app/screens/admin/admin_dashboard.dart';
import 'package:practice_app/screens/admin/admin_audit_trail_screen.dart';
import 'package:practice_app/screens/admin/admin_settings_screen.dart';
import 'package:practice_app/screens/admin/team_list_screen.dart';
import 'package:practice_app/screens/admin/add_edit_crm_user_screen.dart';
import 'package:practice_app/screens/sales/sales_dashboard.dart';
import 'package:practice_app/screens/sales/add_client_screen.dart';
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
import 'package:practice_app/screens/tickets/ticket_details_screen.dart';
import 'package:practice_app/screens/sourcing/add_candidate_screen.dart';
import 'package:practice_app/screens/candidates/edit_candidate_screen.dart';
import 'package:practice_app/screens/sales/edit_client_screen.dart';
import 'package:practice_app/screens/sales/financials_screen.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/user_model.dart';

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
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.readyToPlace,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/new',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.newlyAdded,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/verification',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.verificationPending,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/medical',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.medicalPending,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/placed',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.placed,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/blacklisted',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.blacklisted,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/:id',
              builder:
                  (context, state) => CandidateProfileScreen(
                    candidateId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/admin/candidates/:id/edit',
              builder:
                  (context, state) => EditCandidateScreen(
                    candidateId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/admin/clients',
              builder: (context, state) => const ClientListScreen(),
            ),
            GoRoute(
              path: '/admin/clients/followup',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.followUp,
                  ),
            ),
            GoRoute(
              path: '/admin/clients/interested',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.interested,
                  ),
            ),
            GoRoute(
              path: '/admin/clients/not_interested',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.notInterested,
                  ),
            ),
            GoRoute(
              path: '/admin/clients/active',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.converted,
                  ),
            ),
            GoRoute(
              path: '/admin/clients/past',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.inactive,
                  ),
            ),
            GoRoute(
              path: '/admin/audit',
              builder: (context, state) => const AdminAuditTrailScreen(),
            ),
            GoRoute(
              path: '/admin/clients/:id',
              builder:
                  (context, state) => ClientProfileScreen(
                    clientId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/admin/clients/:id/edit',
              builder:
                  (context, state) =>
                      EditClientScreen(clientId: state.pathParameters['id']!),
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
              path: '/admin/tickets/:id',
              builder:
                  (context, state) => TicketDetailsScreen(
                    ticketId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/admin/settings',
              builder: (context, state) => const AdminSettingsScreen(),
            ),
            GoRoute(
              path: '/admin/learning',
              builder: (context, state) => const LearningScreen(),
            ),
            GoRoute(
              path: '/admin/team',
              builder: (context, state) => const TeamListScreen(),
            ),
            GoRoute(
              path: '/admin/team/sales',
              builder: (context, state) => const TeamListScreen(filterRole: UserRole.sales),
            ),
            GoRoute(
              path: '/admin/team/sourcing',
              builder: (context, state) => const TeamListScreen(filterRole: UserRole.sourcing),
            ),
            GoRoute(
              path: '/admin/team/executives',
              builder: (context, state) => const TeamListScreen(filterRole: UserRole.executive),
            ),
            GoRoute(
              path: '/admin/team/add',
              builder: (context, state) => const AddEditCrmUserScreen(),
            ),
            GoRoute(
              path: '/admin/team/:id/edit',
              builder: (context, state) => AddEditCrmUserScreen(
                userId: state.pathParameters['id']!,
              ),
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
              path: '/sales/add_client',
              builder: (context, state) => const AddClientScreen(),
            ),
            GoRoute(
              path: '/sales/clients',
              builder: (context, state) => const ClientListScreen(),
            ),
            GoRoute(
              path: '/sales/clients/followup',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.followUp,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/interested',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.interested,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/not_interested',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.notInterested,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/active',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.converted,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/past',
              builder:
                  (context, state) => const ClientListScreen(
                    initialStatus: ClientStatus.inactive,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/:id',
              builder:
                  (context, state) => ClientProfileScreen(
                    clientId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/sales/clients/:id/edit',
              builder:
                  (context, state) =>
                      EditClientScreen(clientId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/sales/candidates',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.readyToPlace,
                    readOnly: true,
                  ),
            ),
            GoRoute(
              path: '/sales/candidates/:id',
              builder:
                  (context, state) => CandidateProfileScreen(
                    candidateId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/sales/contracts',
              builder: (context, state) => const ContractListScreen(),
            ),
            GoRoute(
              path: '/sales/contracts/active',
              builder:
                  (context, state) =>
                      const ContractListScreen(initialViewMode: 'active'),
            ),
            GoRoute(
              path: '/sales/contracts/renewals',
              builder:
                  (context, state) =>
                      const ContractListScreen(initialViewMode: 'renewals'),
            ),
            GoRoute(
              path: '/sales/contracts/replacements',
              builder:
                  (context, state) =>
                      const ContractListScreen(initialViewMode: 'replacements'),
            ),
            GoRoute(
              path: '/sales/tickets',
              builder: (context, state) => const TicketListScreen(),
            ),
            GoRoute(
              path: '/sales/tickets/:id',
              builder:
                  (context, state) => TicketDetailsScreen(
                    ticketId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/sales/learning',
              builder: (context, state) => const LearningScreen(),
            ),
            GoRoute(
              path: '/sales/financials',
              builder: (context, state) => const FinancialsScreen(),
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
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.readyToPlace,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/new',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.newlyAdded,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/verification',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.verificationPending,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/medical',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.medicalPending,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/placed',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.placed,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/blacklisted',
              builder:
                  (context, state) => const CandidateDirectoryScreen(
                    type: CandidateDirectoryType.blacklisted,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/:id',
              builder:
                  (context, state) => CandidateProfileScreen(
                    candidateId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/sourcing/candidates/:id/edit',
              builder:
                  (context, state) => EditCandidateScreen(
                    candidateId: state.pathParameters['id']!,
                  ),
            ),
            GoRoute(
              path: '/sourcing/tickets',
              builder: (context, state) => const TicketListScreen(),
            ),
            GoRoute(
              path: '/sourcing/tickets/:id',
              builder:
                  (context, state) => TicketDetailsScreen(
                    ticketId: state.pathParameters['id']!,
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
              builder:
                  (context, state) => ExecutiveTaskDetailScreen(
                    taskId: state.pathParameters['id']!,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
