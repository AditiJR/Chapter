import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'blocs/authentication/authentication_bloc.dart';
import 'firebase_options.dart';
import 'navigation/my_navigator_route.dart';
import 'navigation/router.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'services/notification_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthenticationRepository _authenticationRepository =
      FirebaseAuthenticationRepository();
  late final AuthenticationBloc _authenticationBloc = AuthenticationBloc(
    _authenticationRepository,
  );
  late final GoRouter _router = buildRouter(_authenticationBloc);
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.instance.initialize(
        onForegroundMessage: _showForegroundNotification,
        onOpenedMessage: _openNotification,
      );
    } catch (e) {
      debugPrint('Chapter FCM initialization failed: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    if (!mounted) return;
    final title = message.notification?.title ?? 'Chapter';
    final body = message.notification?.body ?? 'You have a new notification.';
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _openNotification(message),
          ),
        ),
      );
  }

  void _openNotification(RemoteMessage message) {
    // Navigation is intentionally limited to the existing Notifications page.
    // go_router's auth guard will redirect if the user isn't signed in.
    _router.go(MyNavigatorRoute.notifications.path);
  }

  @override
  void dispose() {
    NotificationService.instance.dispose();
    _router.dispose();
    _authenticationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>.value(
          value: _authenticationRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: _authenticationBloc),
        ],
        child: MaterialApp.router(
          title: 'Chapter',
          debugShowCheckedModeBanner: false,
          theme: chapterTheme(),
          routerConfig: _router,
          scaffoldMessengerKey: _messengerKey,
        ),
      ),
    );
  }
}
