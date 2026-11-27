import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'blocs/authentication/authentication_bloc.dart';
import 'model/app_user.dart';
import 'blocs/library/library_cubit.dart';
import 'firebase_options.dart';
import 'navigation/my_navigator_route.dart';
import 'navigation/router.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'repositories/social/social_repository.dart';
import 'repositories/chat/chat_repository.dart';
import 'repositories/users/user_repository.dart';
import 'repositories/books/books_repository.dart';
import 'repositories/library/library_repository.dart';
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
  late final UserRepository _userRepository = FirestoreUserRepository();
  late final ChatRepository _chatRepository = FirestoreChatRepository();
  late final SocialRepository _socialRepository = FirestoreSocialRepository();
  late final BooksRepository _booksRepository = GoogleBooksRepository();
  late final LibraryRepository _libraryRepository =
      FirestoreLibraryRepository();
  late final LibraryCubit _libraryCubit = LibraryCubit(
    _libraryRepository,
    _authenticationRepository,
  );
  late final AuthenticationBloc _authenticationBloc = AuthenticationBloc(
    _authenticationRepository,
    _userRepository,
    (user) async {
      final id = NotificationService.instance.installationId;
      if (id != null) await _userRepository.removeDevice(user.uid, id);
    },
  );
  StreamSubscription<AppUser?>? _profileSub;
  late final GoRouter _router = buildRouter(_authenticationBloc);
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Make sure every signed-in user (including accounts created before
    // profiles existed) has a profile others can find.
    _profileSub = _authenticationRepository.userChanges.listen((user) {
      if (user != null) {
        _saveDevice(user.uid);
        _userRepository.ensureProfile(user).catchError((Object e) {
          debugPrint('Chapter profile setup failed: $e');
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  /// Registers this device with the signed-in user so pushes can reach it.
  void _saveDevice(String uid) {
    NotificationService.instance.listenForRegistration((id) {
      _userRepository.saveDevice(uid, id).catchError((Object e) {
        debugPrint('Chapter device save failed: $e');
      });
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
    // While the app is open, the in-app banner (driven by Firestore) already
    // announces the same event, so showing this push too would duplicate it.
  }

  void _openNotification(RemoteMessage message) {
    // Navigation is intentionally limited to the existing Notifications page.
    // go_router's auth guard will redirect if the user isn't signed in.
    _router.go(MyNavigatorRoute.notifications.path);
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    NotificationService.instance.dispose();
    _router.dispose();
    _authenticationBloc.close();
    _libraryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider<UserRepository>.value(value: _userRepository),
        RepositoryProvider<ChatRepository>.value(value: _chatRepository),
        RepositoryProvider<SocialRepository>.value(value: _socialRepository),
        RepositoryProvider<BooksRepository>.value(value: _booksRepository),
        RepositoryProvider<LibraryRepository>.value(value: _libraryRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: _authenticationBloc),
          BlocProvider<LibraryCubit>.value(value: _libraryCubit),
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
