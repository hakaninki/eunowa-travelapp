import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/comment_model.dart';

/// Yorum sayısı
final commentCountStreamProvider =
    StreamProvider.family.autoDispose<int, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection(AppCollections.posts)
      .doc(postId)
      .collection(AppCollections.comments)
      .snapshots()
      .map((snapshot) => snapshot.size);
});

/// Yorum listesi
final commentsStreamProvider =
    StreamProvider.family.autoDispose<List<CommentModel>, String>(
  (ref, postId) {
    return FirebaseFirestore.instance
        .collection(AppCollections.posts)
        .doc(postId)
        .collection(AppCollections.comments)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => CommentModel.fromFirestore(d.id, d.data())).toList());
  },
);
