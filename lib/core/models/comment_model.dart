import 'package:cloud_firestore/cloud_firestore.dart';


class CommentModel {
  final String id;
  final String userId;
  final String username; // hızlı gösterim için yazıyoruz
  final String? photoUrl; // opsiyonel
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    this.photoUrl,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: (map['username'] as String?) ?? 'user',
      photoUrl: map['photoUrl'] as String?,
      text: (map['text'] as String?)?.trim() ?? '',
      createdAt: (map['createdAt'] as DateTime?) ??
          DateTime.fromMillisecondsSinceEpoch(
            (map['createdAt'] as int?) ?? 0,
          ),
    );
  }

  factory CommentModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CommentModel(
      id: id,
      userId: data['userId'] as String,
      username: (data['username'] as String?) ?? 'user',
      photoUrl: data['photoUrl'] as String?,
      text: (data['text'] as String?)?.trim() ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse('${data['createdAt']}') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
