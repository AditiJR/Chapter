import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../model/app_user.dart';

/// Thrown for auth failures with a message that is safe to show to the user.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthenticationRepository {
  /// Emits the current user (or null when signed out) whenever it changes.
  Stream<AppUser?> get userChanges;
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset({required String email});
  Future<void> signOut();
}

class FirebaseAuthenticationRepository extends AuthenticationRepository {
  FirebaseAuthenticationRepository({fb.FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  static AppUser? _toAppUser(fb.User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    return AppUser(
      uid: user.uid,
      email: email,
      displayName: (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : email.split('@').first,
    );
  }

  @override
  Stream<AppUser?> get userChanges => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toAppUser(credential.user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  @override
  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      return _toAppUser(_auth.currentUser)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static String _messageFor(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
