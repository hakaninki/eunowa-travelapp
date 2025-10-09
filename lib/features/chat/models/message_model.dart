import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class MessageModel {
  final String id;
  final String fromUid;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;

  MessageModel({
    required this.id,
    required this.fromUid,
    required this.text,
    required this.createdAt,
    required this.readBy,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> m) {
    DateTime _toDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.now();
    }

    return MessageModel(
      id: id,
      fromUid: m['fromUid'] as String,
      text: m['text'] as String,
      createdAt: _toDate(m['createdAt']),
      readBy: List<String>.from(m['readBy'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'text': text,
        'createdAt': createdAt,
        'readBy': readBy,
      };
}
