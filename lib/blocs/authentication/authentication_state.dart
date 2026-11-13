part of 'authentication_bloc.dart';

sealed class AuthenticationState {}

/// Waiting for Firebase to report whether someone is signed in.
final class AuthenticationInitial extends AuthenticationState {}

/// A sign in / sign up / reset request is in flight.
final class AuthenticationWaiting extends AuthenticationState {}

final class AuthenticationAuthenticated extends AuthenticationState {
  AuthenticationAuthenticated(this.user);
  final AppUser user;
}

final class AuthenticationUnauthenticated extends AuthenticationState {}

final class AuthenticationError extends AuthenticationState {
  AuthenticationError({required this.errorText});
  final String errorText;
}

final class AuthenticationPasswordResetSent extends AuthenticationState {}
