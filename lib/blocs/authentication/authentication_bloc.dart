import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/app_user.dart';
import '../../repositories/authentication/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(this.authenticationRepository)
    : super(AuthenticationInitial()) {
    on<AuthenticationUserChangedEvent>(_handleUserChanged);
    on<AuthenticationSignInEvent>(_handleSignIn);
    on<AuthenticationSignUpEvent>(_handleSignUp);
    on<AuthenticationPasswordResetEvent>(_handlePasswordReset);
    on<AuthenticationSignOutEvent>(_handleSignOut);

    _subscription = authenticationRepository.userChanges.listen(
      (user) => add(AuthenticationUserChangedEvent(user)),
    );
  }

  final AuthenticationRepository authenticationRepository;
  late final StreamSubscription<AppUser?> _subscription;

  /// The signed-in user, or null.
  AppUser? get user => switch (state) {
    AuthenticationAuthenticated(:final user) => user,
    _ => authenticationRepository.currentUser,
  };

  bool get isAuthenticated => authenticationRepository.currentUser != null;

  void _handleUserChanged(
    AuthenticationUserChangedEvent event,
    Emitter<AuthenticationState> emit,
  ) {
    // Ignore the stream while a request is in flight; the request handler
    // emits the final state itself.
    if (state is AuthenticationWaiting) return;
    final user = event.user;
    emit(
      user == null
          ? AuthenticationUnauthenticated()
          : AuthenticationAuthenticated(user),
    );
  }

  Future<void> _handleSignIn(
    AuthenticationSignInEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationWaiting());
    try {
      final user = await authenticationRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthenticationError(errorText: e.message));
    } catch (e) {
      emit(AuthenticationError(errorText: 'Something went wrong. $e'));
    }
  }

  Future<void> _handleSignUp(
    AuthenticationSignUpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationWaiting());
    try {
      final user = await authenticationRepository.signUp(
        displayName: event.displayName,
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthenticationError(errorText: e.message));
    } catch (e) {
      emit(AuthenticationError(errorText: 'Something went wrong. $e'));
    }
  }

  Future<void> _handlePasswordReset(
    AuthenticationPasswordResetEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationWaiting());
    try {
      await authenticationRepository.sendPasswordReset(email: event.email);
      emit(AuthenticationPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthenticationError(errorText: e.message));
    } catch (e) {
      emit(AuthenticationError(errorText: 'Something went wrong. $e'));
    }
  }

  Future<void> _handleSignOut(
    AuthenticationSignOutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationWaiting());
    await authenticationRepository.signOut();
    emit(AuthenticationUnauthenticated());
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
