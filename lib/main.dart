import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:practice_app/theme/theme_provider.dart';
import 'package:practice_app/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'auth/logout_timer_provider.dart';
import 'auth/user_manager.dart';
import 'routing/app_router.dart';
import 'theme/text.dart';
import 'theme/theme.dart';
import 'providers/global_app_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup Background Messaging Handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await LocalStoragePref().initPrefBox();
  await UserManager().init();
  _configLoading();

  // Initialize Foreground Messaging Service
  FirebaseMessagingService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LogoutTimerProvider()),
        ChangeNotifierProvider(
          create: (_) => GlobalAppState()..initializeData(),
        ),
      ],
      child: const MyApp(),
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Verified Maids CRM',
      theme: MaterialTheme(textTheme).light(),
      darkTheme: MaterialTheme(textTheme).dark(),
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      builder: EasyLoading.init(),
    );
  }
}
