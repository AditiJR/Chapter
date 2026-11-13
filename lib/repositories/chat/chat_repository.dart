import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/chat.dart';

abstract class ChatRepository {
  /// Stable id for the conversation between two users.
  String chatId(String uidA, String uidB);

  /// The signed-in user's conversations, most recent first.
  Stream<List<ChatThread>> watchChats(String uid);

  /// Creates the conversation document if needed so messages can be read.
  Future<void> openChat({
    required String myUid,
    required String myName,
    required String otherUid,
    required String otherName,
  });

  Stream<List<ChatMessage>> watchMessages(String chatId);

  Future<void> send({
    required String chatId,
    required String senderId,
    required String text,
  });
}

class FirestoreChatRepository extends ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  String chatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return sorted.join('_');
  }

  @override
  Stream<List<ChatThread>> watchChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final threads = [
            for (final d in snap.docs)
              ChatThread(
                id: d.id,
                participants: List<String>.from(
                  d.data()['participants'] as List,
                ),
                names: Map<String, String>.from(
                  (d.data()['names'] as Map?) ?? const {},
                ),
                lastMessage: (d.data()['lastMessage'] as String?) ?? '',
                lastMessageAt: (d.data()['lastMessageAt'] as Timestamp?)
                    ?.toDate(),
              ),
          ];
          // Only chats that have at least one message belong in the list.
          threads.removeWhere((t) => t.lastMessageAt == null);
          threads.sort((a, b) => b.lastMessageAt!.compareTo(a.lastMessageAt!));
          return threads;
        });
  }

  @override
  Future<void> openChat({
    required String myUid,
    required String myName,
    required String otherUid,
    required String otherName,
  }) {
    return _db.collection('chats').doc(chatId(myUid, otherUid)).set({
      'participants': [myUid, otherUid],
      'names': {myUid: myName, otherUid: otherName},
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snap) => [
            for (final d in snap.docs)
              ChatMessage(
                id: d.id,
                senderId: (d.data()['senderId'] as String?) ?? '',
                text: (d.data()['text'] as String?) ?? '',
                sentAt: (d.data()['sentAt'] as Timestamp?)?.toDate(),
              ),
          ],
        );
  }

  @override
  Future<void> send({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chat = _db.collection('chats').doc(chatId);
    await chat.collection('messages').add({
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });
    await chat.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }
}
