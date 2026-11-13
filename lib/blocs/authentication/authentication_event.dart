part of 'authentication_bloc.dart';

sealed class AuthenticationEvent {}

class AuthenticationUserChangedEvent extends AuthenticationEvent {
  AuthenticationUserChangedEvent(this.user);
  final AppUser? user;
}

class AuthenticationSignInEvent extends AuthenticationEvent {
  AuthenticationSignInEvent({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthenticationSignUpEvent extends AuthenticationEvent {
  AuthenticationSignUpEvent({
    required this.displayName,
    required this.email,
    required this.password,
  });
  final String displayName;
  final String email;
  final String password;
}

class AuthenticationPasswordResetEvent extends AuthenticationEvent {
  AuthenticationPasswordResetEvent({required this.email});
  final String email;
}

class AuthenticationSignOutEvent extends AuthenticationEvent {}
