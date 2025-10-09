import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class PostModel {
  final String id;
  final String uid;
  final String username;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime createdAt;

  /// ✅ yeni alanlar
  final double? lat;
  final double? lng;

  /// ✅ güncelleme zamanı (opsiyonel)
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
    this.lat,
    this.lng,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'username': username,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
        'createdAt': createdAt,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  factory PostModel.fromMap(Map<String, dynamic> m) {
    DateTime _toDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.now();
    }

    return PostModel(
      id: m['id'] as String,
      uid: m['uid'] as String,
      username: m['username'] as String,
      description: m['description'] as String,
      imageUrl: m['imageUrl'] as String,
      location: m['location'] as String,
      createdAt: _toDate(m['createdAt']),
      lat: (m['lat'] is num) ? (m['lat'] as num).toDouble() : null,
      lng: (m['lng'] is num) ? (m['lng'] as num).toDouble() : null,
      updatedAt: m['updatedAt'] != null ? _toDate(m['updatedAt']) : null,
    );
  }
}
