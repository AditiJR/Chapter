import 'app_user.dart';

/// Public profile stored at `users/{uid}`; other users can read it.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    this.bio = '',
  });

  final String uid;
  final String displayName;
  final String username;
  final String bio;

  String get handle => '@$username';

  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  /// Default profile for a freshly created account.
  factory UserProfile.fromUser(AppUser user) => UserProfile(
    uid: user.uid,
    displayName: user.displayName,
    username: user.handle.substring(1),
  );

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    final name = (data['displayName'] as String?) ?? '';
    return UserProfile(
      uid: uid,
      displayName: name,
      username: (data['username'] as String?) ?? name.toLowerCase(),
      bio: (data['bio'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'username': username,
    'bio': bio,
  };

  UserProfile copyWith({String? displayName, String? username, String? bio}) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        username: username ?? this.username,
        bio: bio ?? this.bio,
      );
}
