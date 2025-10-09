// lib/features/notifications/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType { like, comment, follow }

AppNotificationType _parseType(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'like':
      return AppNotificationType.like;
    case 'comment':
      return AppNotificationType.comment;
    case 'follow':
      return AppNotificationType.follow;
    default:
      return AppNotificationType.comment;
  }
}

String _typeToString(AppNotificationType t) {
  switch (t) {
    case AppNotificationType.like:
      return 'like';
    case AppNotificationType.comment:
      return 'comment';
    case AppNotificationType.follow:
      return 'follow';
  }
}

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String fromUid;
  final String? fromUsername;      // denormalized
  final String? postId;
  final String? commentText;       // denormalized short preview
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.fromUid,
    this.fromUsername,
    this.postId,
    this.commentText,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final ts = m['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();
    if (ts is DateTime) created = ts;

    return AppNotification(
      id: d.id,
      type: _parseType(m['type'] as String?),
      fromUid: (m['fromUid'] ?? '') as String,
      fromUsername: m['fromUsername'] as String?,
      postId: m['postId'] as String?,
      commentText: m['commentText'] as String?,
      read: (m['read'] ?? false) as bool,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': _typeToString(type),
        'fromUid': fromUid,
        if (fromUsername != null) 'fromUsername': fromUsername,
        if (postId != null) 'postId': postId,
        if (commentText != null) 'commentText': commentText,
        'createdAt': createdAt,
        'read': read,
      };
}
