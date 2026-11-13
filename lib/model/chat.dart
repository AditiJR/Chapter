/// One conversation between two users, shown in the Messages list.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participants,
    required this.names,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  final String id;
  final List<String> participants;

  /// Display name for each participant, keyed by uid.
  final Map<String, String> names;
  final String lastMessage;
  final DateTime? lastMessageAt;

  String otherUid(String myUid) =>
      participants.firstWhere((p) => p != myUid, orElse: () => myUid);

  String otherName(String myUid) => names[otherUid(myUid)] ?? 'Reader';
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;

  /// Null briefly while the server timestamp is still being resolved.
  final DateTime? sentAt;
}
