/// The signed-in user, independent of the Firebase SDK's own `User` type.
class AppUser {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  /// First word of the display name, used in greetings.
  String get firstName => displayName.trim().split(' ').first;

  /// Single uppercase letter for avatar placeholders.
  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  /// Handle shown under the name, e.g. "@aditi".
  String get handle => '@${firstName.toLowerCase()}';
}
