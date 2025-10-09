import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class ConversationModel {
  final String id;
  final List<String> participants; // length = 2
  final String? lastMessage;
  final DateTime? lastAt;
  final Map<String, int> unread; // {uid: count}

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastAt,
    Map<String, int>? unread,
  }) : unread = unread ?? const {};

  String otherUid(String myUid) {
    return participants.firstWhere((u) => u != myUid, orElse: () => myUid);
  }

  int unreadFor(String uid) => unread[uid] ?? 0;

  factory ConversationModel.fromMap(String id, Map<String, dynamic> m) {
    DateTime? _toDate(dynamic raw) {
      if (raw == null) return null;
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return null;
    }

    final Map<String, int> unreadMap =
        (m['unread'] is Map<String, dynamic>)
            ? (m['unread'] as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, (v is num) ? v.toInt() : 0))
            : const {};

    return ConversationModel(
      id: id,
      participants: List<String>.from(m['participants'] ?? const []),
      lastMessage: m['lastMessage'] as String?,
      lastAt: _toDate(m['lastAt']),
      unread: unreadMap,
    );
  }

  Map<String, dynamic> toMap() => {
        'participants': participants,
        if (lastMessage != null) 'lastMessage': lastMessage,
        if (lastAt != null) 'lastAt': lastAt,
        if (unread.isNotEmpty) 'unread': unread,
      };
}
