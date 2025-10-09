// lib/features/notifications/services/notifications_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';

class NotificationsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// notifications/{me}/items stream
  Stream<List<AppNotification>> watchMyNotifications({int limit = 100}) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    final col = _db.collection('notifications').doc(uid).collection('items');

    return col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  /// read == false sayacı
  Stream<int> unreadCountStream() {
    final uid = _uid;
    if (uid == null) return const Stream<int>.empty();
    final col = _db.collection('notifications').doc(uid).collection('items');
    return col.where('read', isEqualTo: false).snapshots().map((s) => s.size);
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notifId)
        .update({'read': true});
  }

  /// Tüm unread'leri okundu
  Future<int> markAllAsRead() async {
    final uid = _uid;
    if (uid == null) return 0;
    final col = _db.collection('notifications').doc(uid).collection('items');
    final snap =
        await col.where('read', isEqualTo: false).limit(500).get(); // güvenli limit
    if (snap.docs.isEmpty) return 0;
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
    return snap.size;
  }

  // --------- SADECE yorum için helper bırakıyoruz (çift yazım yoksa kullanmaya devam edebilirsin) ---------

  Future<void> createCommentNotificationByPostId({
    required String postId,
    required String fromUid,
    String? fromUsername,
    String? commentId,
  }) async {
    final postSnap = await _db.collection('posts').doc(postId).get();
    final ownerUid = (postSnap.data() ?? {})['uid'] as String?;
    if (ownerUid == null || ownerUid.isEmpty || ownerUid == fromUid) return;

    String? commentText;
    if (commentId != null && commentId.isNotEmpty) {
      try {
        final cSnap = await _db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .get();
        final txt = (cSnap.data() ?? {})['text'];
        if (txt is String && txt.trim().isNotEmpty) {
          final t = txt.trim();
          commentText = t.length <= 140 ? t : '${t.substring(0, 140)}…';
        }
      } catch (_) {}
    }

    await _db.collection('notifications').doc(ownerUid).collection('items').add({
      'type': 'comment',
      'fromUid': fromUid,
      if (fromUsername != null) 'fromUsername': fromUsername,
      'postId': postId,
      if (commentText != null) 'commentText': commentText,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
