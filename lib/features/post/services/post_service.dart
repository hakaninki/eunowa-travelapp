import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary;

  PostService(this._cloudinary);

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(AppCollections.posts).doc(postId);

  /// Yeni post oluştur
  Future<void> createPost({
    required File imageFile,
    required String uid,
    required String username,
    required String description,
    required String location,
    double? lat,
    double? lng,
  }) async {
    final imageUrl = await _cloudinary.uploadImage(imageFile);
    final docRef = _firestore.collection(AppCollections.posts).doc();

    final post = PostModel(
      id: docRef.id,
      uid: uid,
      username: username,
      description: description,
      imageUrl: imageUrl,
      location: location,
      createdAt: DateTime.now(),
      lat: lat,
      lng: lng,
    );

    await docRef.set({
      ...post.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Post güncelle (yalnızca açıklama/konum/lat/lng)
  Future<void> updatePost({
    required String postId,
    String? description,
    String? location,
    double? lat,
    double? lng,
  }) async {
    final Map<String, dynamic> data = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (description != null) data['description'] = description;
    if (location != null) data['location'] = location;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;

    if (data.length == 1) return; // sadece updatedAt var -> değişiklik yok
    await _postRef(postId).update(data);
  }

  /// Post sil
  Future<void> deletePost(String postId) async {
    // Not: Alt koleksiyonlar otomatik silinmez (comments/likes). Backlog: recursive delete.
    await _postRef(postId).delete();
  }

  /// Post feed akışı (tüm kullanıcılar)
  Stream<List<PostModel>> watchPosts() {
    return _firestore
        .collection(AppCollections.posts)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PostModel.fromMap({...data, 'id': doc.id});
            }).toList());
  }

  /// Belirli kullanıcının postları
  Stream<List<PostModel>> watchPostsByUser(String uid) {
    return _firestore
        .collection(AppCollections.posts)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PostModel.fromMap({...data, 'id': doc.id});
            }).toList());
  }

    /// Belirli konum label'ına göre postlar
  Stream<List<PostModel>> watchPostsByLocationLabel(String locationLabel) {
    return _firestore
        .collection(AppCollections.posts)
        .where('location', isEqualTo: locationLabel)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PostModel.fromMap({...data, 'id': doc.id});
            }).toList());
  }

}
