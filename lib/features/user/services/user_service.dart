import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  /// İlk kez signup/login olduğunda users/{uid} dokümanı yoksa oluşturur.
  Future<void> ensureUserDoc(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      final email = user.email ?? 'user_${user.uid}';
      final username = (user.displayName?.trim().isNotEmpty == true)
          ? user.displayName!.trim()
          : email.split('@').first;
      await doc.set({
        'username': username,
        'username_lc': username.toLowerCase(),
        'photoUrl': user.photoURL,
        'bio': null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Belirli uid’ler için user profilleri (10’arlı parça)
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    final results = <UserModel>[];

    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, (i + 10 > uids.length) ? uids.length : i + 10);
      final q = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final d in q.docs) {
        final data = d.data();
        results.add(
          UserModel(
            id: d.id,
            username: (data['username'] as String?) ?? 'user_${d.id.substring(0,6)}',
            photoUrl: data['photoUrl'] as String?,
            bio: data['bio'] as String?,
          ),
        );
      }
    }
    return results;
  }

  /// Tek kullanıcıyı getir
  Future<UserModel?> getUserById(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.id, snap.data()!);
  }

  /// Kullanıcı stream (gerçek zamanlı)
  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((d) {
      if (!d.exists || d.data() == null) return null;
      return UserModel.fromMap(d.id, d.data()!);
    });
  }

  /// Profil güncelle
  Future<void> updateProfile({
    required String uid,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) {
      data['username'] = username;
      data['username_lc'] = username.toLowerCase();
    }
    if (bio != null) data['bio'] = bio;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    if (data.isEmpty) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

    /// username_lc üstünden prefix arama (canlı)
  Stream<List<UserModel>> watchUsersByPrefix(String rawQ, {int limit = 20}) {
    final q = (rawQ.trim().toLowerCase());
    if (q.length < 2) {
      // 1 harf ve altı için sonuç döndürme
      return Stream.value(<UserModel>[]);
    }

    return _db
        .collection('users')
        .orderBy('username_lc')
        .startAt([q])
        .endAt([q + '\uf8ff'])
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return UserModel(
                id: d.id,
                username: (data['username'] as String?) ?? 'user_${d.id.substring(0,6)}',
                photoUrl: data['photoUrl'] as String?,
                bio: data['bio'] as String?,
              );
            }).toList());
  }

}
