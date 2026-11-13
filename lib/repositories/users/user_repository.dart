import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/app_user.dart';
import '../../model/user_profile.dart';

abstract class UserRepository {
  /// Creates the profile document if it does not exist yet.
  Future<void> ensureProfile(AppUser user);

  /// Writes the profile for a brand-new account, overwriting any default.
  Future<void> createProfile(AppUser user);

  Future<UserProfile?> getProfile(String uid);
  Stream<UserProfile?> watchProfile(String uid);
  Future<void> updateProfile(UserProfile profile);

  /// Every other user, for picking someone to message.
  Future<List<UserProfile>> listUsers({required String excludeUid});
}

class FirestoreUserRepository extends UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<void> ensureProfile(AppUser user) async {
    final ref = _doc(user.uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) tx.set(ref, UserProfile.fromUser(user).toMap());
    });
  }

  @override
  Future<void> createProfile(AppUser user) =>
      _doc(user.uid).set(UserProfile.fromUser(user).toMap());

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    return data == null ? null : UserProfile.fromMap(uid, data);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      _doc(uid).snapshots().map((snap) {
        final data = snap.data();
        return data == null ? null : UserProfile.fromMap(uid, data);
      });

  @override
  Future<void> updateProfile(UserProfile profile) =>
      _doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));

  @override
  Future<List<UserProfile>> listUsers({required String excludeUid}) async {
    final snap = await _db.collection('users').get();
    final users = [
      for (final d in snap.docs)
        if (d.id != excludeUid) UserProfile.fromMap(d.id, d.data()),
    ];
    users.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return users;
  }
}
