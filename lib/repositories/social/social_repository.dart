import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/social.dart';

/// Follows, notifications and the activity feed, all stored in Firestore.
///
/// `users/{me}/following/{other}` and `users/{other}/followers/{me}` are
/// written together so both lists can be read without a collection-group query.
abstract class SocialRepository {
  Stream<Set<String>> watchFollowing(String uid);
  Stream<Set<String>> watchFollowers(String uid);

  Future<void> follow({
    required String myUid,
    required String myName,
    required String otherUid,
  });
  Future<void> unfollow({required String myUid, required String otherUid});

  /// Leaves a notification for [toUid]. A repeated call with the same
  /// [docId] replaces the earlier one (e.g. one "new message" per sender).
  Future<void> notify({
    required String toUid,
    required String docId,
    required NotificationType type,
    required String fromUid,
    required String fromName,
    required String body,
  });
  Stream<List<AppNotification>> watchNotifications(String uid);
  Future<void> markRead(String uid, String notificationId);
  Future<void> markAllRead(String uid);

  /// Recent shelf activity from [people] (uid -> display name), newest first.
  Future<List<ActivityItem>> loadActivity(Map<String, String> people);
}

class FirestoreSocialRepository extends SocialRepository {
  FirestoreSocialRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  Stream<Set<String>> _ids(String uid, String sub) => _user(
    uid,
  ).collection(sub).snapshots().map((s) => {for (final d in s.docs) d.id});

  @override
  Stream<Set<String>> watchFollowing(String uid) => _ids(uid, 'following');

  @override
  Stream<Set<String>> watchFollowers(String uid) => _ids(uid, 'followers');

  @override
  Future<void> follow({
    required String myUid,
    required String myName,
    required String otherUid,
  }) async {
    if (myUid == otherUid) return;
    final mine = _user(myUid).collection('following').doc(otherUid);
    final already = (await mine.get()).exists;
    final batch = _db.batch();
    batch.set(mine, {'followedAt': FieldValue.serverTimestamp()});
    batch.set(_user(otherUid).collection('followers').doc(myUid), {
      'followedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    if (!already) {
      await notify(
        toUid: otherUid,
        docId: 'follow_$myUid',
        type: NotificationType.follow,
        fromUid: myUid,
        fromName: myName,
        body: 'Tap to see their profile',
      );
    }
  }

  @override
  Future<void> unfollow({
    required String myUid,
    required String otherUid,
  }) async {
    final batch = _db.batch();
    batch.delete(_user(myUid).collection('following').doc(otherUid));
    batch.delete(_user(otherUid).collection('followers').doc(myUid));
    await batch.commit();
  }

  @override
  Future<void> notify({
    required String toUid,
    required String docId,
    required NotificationType type,
    required String fromUid,
    required String fromName,
    required String body,
  }) {
    return _user(toUid).collection('notifications').doc(docId).set({
      'type': type.name,
      'fromUid': fromUid,
      'fromName': fromName,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _user(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (s) => [
            for (final d in s.docs) AppNotification.fromMap(d.id, d.data()),
          ],
        );
  }

  @override
  Future<void> markRead(String uid, String notificationId) => _user(
    uid,
  ).collection('notifications').doc(notificationId).update({'read': true});

  @override
  Future<void> markAllRead(String uid) async {
    final unread = await _user(
      uid,
    ).collection('notifications').where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  @override
  Future<List<ActivityItem>> loadActivity(Map<String, String> people) async {
    final lists = await Future.wait([
      for (final e in people.entries)
        _user(e.key)
            .collection('books')
            .orderBy('addedAt', descending: true)
            .limit(3)
            .get()
            .then(
              (snap) => [
                for (final d in snap.docs)
                  ActivityItem(
                    uid: e.key,
                    name: e.value,
                    bookTitle: (d['title'] as String?) ?? 'Untitled',
                    bookAuthor: (d['author'] as String?) ?? '',
                    coverColor: Color((d['coverColor'] as int?) ?? 0xff7b2d3b),
                    shelfId: (d['shelfId'] as String?) ?? '',
                    at: (d['addedAt'] as Timestamp?)?.toDate(),
                  ),
              ],
            ),
    ]);
    final all = [for (final l in lists) ...l];
    all.sort(
      (a, b) => (b.at ?? DateTime.now()).compareTo(a.at ?? DateTime.now()),
    );
    return all.take(20).toList();
  }
}
