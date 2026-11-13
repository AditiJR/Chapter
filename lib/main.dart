import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/library/library_cubit.dart';
import 'firebase_options.dart';
import 'navigation/router.dart';
import 'repositories/authentication/authentication_repository.dart';
import 'repositories/books/books_repository.dart';
import 'repositories/library/library_repository.dart';
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
  late final BooksRepository _booksRepository = GoogleBooksRepository();
  late final LibraryRepository _libraryRepository =
      FirestoreLibraryRepository();
  late final LibraryCubit _libraryCubit = LibraryCubit(
    _libraryRepository,
    _authenticationRepository,
  );
  late final AuthenticationBloc _authenticationBloc = AuthenticationBloc(
    _authenticationRepository,
  );
  late final GoRouter _router = buildRouter(_authenticationBloc);

  @override
  void dispose() {
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
        ),
      ),
    );
  }
}
