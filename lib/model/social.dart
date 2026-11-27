import 'package:flutter/material.dart';

import 'book.dart';

enum NotificationType { follow, message }

/// One entry in `users/{uid}/notifications`, written by the other user.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.fromUid,
    required this.fromName,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final NotificationType type;
  final String fromUid;
  final String fromName;
  final String body;
  final DateTime? createdAt;
  final bool read;

  String get title => switch (type) {
    NotificationType.follow => '$fromName followed you',
    NotificationType.message => '$fromName sent a message',
  };

  factory AppNotification.fromMap(String id, Map<String, dynamic> d) =>
      AppNotification(
        id: id,
        type: d['type'] == 'message'
            ? NotificationType.message
            : NotificationType.follow,
        fromUid: (d['fromUid'] as String?) ?? '',
        fromName: (d['fromName'] as String?) ?? 'Someone',
        body: (d['body'] as String?) ?? '',
        createdAt: d['createdAt'] == null
            ? null
            : (d['createdAt'] as dynamic).toDate() as DateTime,
        read: (d['read'] as bool?) ?? false,
      );
}

/// A book someone you follow recently put on a shelf.
class ActivityItem {
  const ActivityItem({
    required this.uid,
    required this.name,
    required this.bookTitle,
    required this.bookAuthor,
    required this.coverColor,
    required this.shelfId,
    required this.at,
  });

  final String uid;
  final String name;
  final String bookTitle;
  final String bookAuthor;
  final Color coverColor;
  final String shelfId;
  final DateTime? at;

  String get title {
    final status = ReadingStatus.fromShelfId(shelfId);
    final what = switch (status) {
      ReadingStatus.finished => 'finished a book',
      ReadingStatus.reading => 'started reading',
      ReadingStatus.toBeRead => 'wants to read',
      ReadingStatus.dnf => 'put a book down',
      null => 'shelved a book',
    };
    return '$name $what';
  }
}

/// "now", "5m", "3h", "Tue", or "12 Oct".
String timeAgo(DateTime? t) {
  if (t == null) return 'now';
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[t.weekday - 1];
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${t.day} ${months[t.month - 1]}';
}
