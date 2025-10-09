// lib/features/user/services/follow_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  FollowService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  static const _users = 'users';
  static const _followers = 'followers';
  static const _following = 'following';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(_users).doc(uid);

  CollectionReference<Map<String, dynamic>> _followersCol(String uid) =>
      _userDoc(uid).collection(_followers);

  CollectionReference<Map<String, dynamic>> _followingCol(String uid) =>
      _userDoc(uid).collection(_following);

  CollectionReference<Map<String, dynamic>> _notifItemsCol(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  /// currentUid -> targetUid takip et
  /// (BİLDİRİM sadece burada yazılır. Başka yerde follow notifi yazma -> duplicate olur.)
  Future<void> follow({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid == targetUid) return;

    final followingRef = _followingCol(currentUid).doc(targetUid);
    final followersRef = _followersCol(targetUid).doc(currentUid);

    await _db.runTransaction((tx) async {
      tx.set(followingRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      tx.set(followersRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    });

    // Bildirim: targetUid'e yaz (username ile)
    try {
      String? fromUsername;
      final fromUserDoc = await _userDoc(currentUid).get();
      if (fromUserDoc.exists) {
        final d = fromUserDoc.data()!;
        fromUsername = d['username'] as String?;
      }

      await _notifItemsCol(targetUid).add({
        'type': 'follow',
        'fromUid': currentUid,
        if (fromUsername != null) 'fromUsername': fromUsername,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Bildirim yazılamasa da follow başarılı; hatayı yutuyoruz.
    }
  }

  /// currentUid -> targetUid takibi bırak
  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid == targetUid) return;

    final followingRef = _followingCol(currentUid).doc(targetUid);
    final followersRef = _followersCol(targetUid).doc(currentUid);

    await _db.runTransaction((tx) async {
      tx.delete(followingRef);
      tx.delete(followersRef);
    });
    // Unfollow için bildirim YOK
  }

  Stream<bool> isFollowingStream({
    required String currentUid,
    required String targetUid,
  }) {
    if (currentUid == targetUid) {
      return Stream<bool>.value(false);
    }
    return _followingCol(currentUid).doc(targetUid).snapshots().map((d) => d.exists);
  }

  Stream<int> followersCountStream(String targetUid) {
    return _followersCol(targetUid).snapshots().map((s) => s.size);
  }

  Stream<int> followingCountStream(String currentUid) {
    return _followingCol(currentUid).snapshots().map((s) => s.size);
  }
}
