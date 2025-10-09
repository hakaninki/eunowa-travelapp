// lib/features/post/services/like_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  CollectionReference<Map<String, dynamic>> _likesCol(String postId) =>
      _postRef(postId).collection(AppCollections.likes);

  CollectionReference<Map<String, dynamic>> _notifItemsCol(String uid) =>
      _firestore.collection('notifications').doc(uid).collection('items');

  /// Like/Unlike (+ like olduğunda post sahibine username ile bildirim)
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeDoc = _likesCol(postId).doc(userId);
    final snap = await likeDoc.get();

    if (snap.exists) {
      // UNLIKE
      await likeDoc.delete();
      return;
    }

    // LIKE
    await likeDoc.set({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Bildirim: post sahibine, "userId"nin username'i ile
    try {
      final postSnap = await _postRef(postId).get();
      final ownerUid = (postSnap.data() ?? {})['uid'] as String?;
      if (ownerUid == null || ownerUid.isEmpty || ownerUid == userId) return;

      // username çek
      String? fromUsername;
      final uSnap = await _firestore.collection('users').doc(userId).get();
      if (uSnap.exists) {
        fromUsername = (uSnap.data() ?? {})['username'] as String?;
      }

      await _notifItemsCol(ownerUid).add({
        'type': 'like',
        'fromUid': userId,
        if (fromUsername != null) 'fromUsername': fromUsername,
        'postId': postId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Bildirim yazılamasa da like başarılı
    }
  }

  /// Like sayısı: alt koleksiyon boyutu
  Stream<int> likeCountStream(String postId) {
    return _likesCol(postId).snapshots().map((s) => s.size);
  }

  /// Bu kullanıcı beğenmiş mi? (stream)
  Stream<bool> isLikedByUserStream({
    required String postId,
    required String userId,
  }) {
    return _likesCol(postId).doc(userId).snapshots().map((s) => s.exists);
  }

  /// Tek seferlik kontrol
  Future<bool> isLikedOnce({
    required String postId,
    required String userId,
  }) async {
    final snap = await _likesCol(postId).doc(userId).get();
    return snap.exists;
  }

  /// Liker ID listesi
  Future<List<String>> getLikerIds({
    required String postId,
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> q =
        _likesCol(postId).orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final res = await q.get();
    return res.docs.map((d) => d.id).toList();
  }
}
