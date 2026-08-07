import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:practice_app/theme/theme_provider.dart';
import 'package:practice_app/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'auth/user_manager.dart';
import 'routing/app_router.dart';
import 'theme/text.dart';
import 'theme/theme.dart';
import 'package:practice_app/widgets/session_timeout_manager.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/repositories/auth_repository.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_event.dart';

import 'package:practice_app/repositories/analytics_repository.dart';
import 'package:practice_app/blocs/dashboard/dashboard_bloc.dart';

import 'package:practice_app/repositories/candidate_repository.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';

import 'package:practice_app/repositories/client_repository.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';

import 'package:practice_app/repositories/contract_repository.dart';
import 'package:practice_app/blocs/contract/contract_bloc.dart';

import 'package:practice_app/repositories/task_repository.dart';
import 'package:practice_app/blocs/task/task_bloc.dart';

import 'package:practice_app/repositories/replacement_repository.dart';
import 'package:practice_app/blocs/replacement/replacement_bloc.dart';
import 'package:practice_app/blocs/audit_log/audit_log_bloc.dart';
import 'package:practice_app/repositories/audit_log_repository.dart';

import 'package:practice_app/repositories/user_repository.dart';
import 'package:practice_app/blocs/user/user_bloc.dart';
import 'package:practice_app/blocs/user/user_event.dart';

import 'package:practice_app/repositories/ticket_repository.dart';
import 'package:practice_app/blocs/ticket/ticket_bloc.dart';

import 'package:practice_app/api/api_client.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup Background Messaging Handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await LocalStoragePref().initPrefBox();
  await UserManager().init();
  _configLoading();

  // Initialize Foreground Messaging Service
  FirebaseMessagingService().init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => AnalyticsRepository()),
        RepositoryProvider(
          create: (context) => CandidateRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => ClientRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => ContractRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => TaskRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => ReplacementRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(apiClient: ApiClient()),
        ),
        RepositoryProvider(
          create: (context) => TicketRepository(apiClient: ApiClient()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    UserBloc(userRepository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AppStarted()),
          ),
          BlocProvider(
            create:
                (context) => DashboardBloc(
                  repository: context.read<AnalyticsRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => CandidateBloc(
                  candidateRepository: context.read<CandidateRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => ClientBloc(
                  clientRepository: context.read<ClientRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => ContractBloc(
                  contractRepository: context.read<ContractRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) =>
                    TaskBloc(taskRepository: context.read<TaskRepository>()),
          ),
          BlocProvider(
            create:
                (context) => ReplacementBloc(
                  replacementRepository: context.read<ReplacementRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) =>
                    AuditLogBloc(auditLogRepository: AuditLogRepository()),
          ),
          BlocProvider(
            create:
                (context) => TicketBloc(
                  ticketRepository: context.read<TicketRepository>(),
                ),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

void _configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.black
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

    return SessionTimeoutManager(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Verified Maids CRM',
        theme: MaterialTheme(textTheme).light(),
        darkTheme: MaterialTheme(textTheme).dark(),
        themeMode: themeProvider.themeMode,
        routerConfig: _router,
        builder: EasyLoading.init(),
      ),
    );
  }
}
