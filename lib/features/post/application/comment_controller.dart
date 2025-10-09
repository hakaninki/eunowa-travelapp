// lib/features/post/application/comment_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';

class CommentController {
  CommentController(this._ref);
  final Ref _ref;

  Future<void> add({
    required String postId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not signed in');
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('Comment cannot be empty');
    if (trimmed.length > 2000) throw Exception('Comment is too long (max 2000)');

    // username / photo al
    final userDoc = await FirebaseFirestore.instance
        .collection(AppCollections.users)
        .doc(user.uid)
        .get();
    final username = userDoc.data()?['username'] ?? (user.displayName ?? 'user');
    final profilePhoto = userDoc.data()?['photoUrl'] ?? user.photoURL;

    // 1) YORUMU EKLE
    final commentId = await _ref.read(commentServiceProvider).addComment(
          postId: postId,
          userId: user.uid,
          username: username,
          photoUrl: profilePhoto,
          text: trimmed,
        );
    // ignore: avoid_print
    print('DEBUG comment: created post=$postId commentId=$commentId by=${user.uid}');

    // 2) BİLDİRİM OLUŞTUR (başarısız olursa uygulamayı düşürmeyelim)
    try {
      await _ref.read(notificationsServiceProvider).createCommentNotificationByPostId(
            postId: postId,
            fromUid: user.uid,
            fromUsername: username,
            //fromPhotoUrl: profilePhoto,
            commentId: commentId,
          );
      // ignore: avoid_print
      print('DEBUG notif.comment: queued post=$postId by=${user.uid}');
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG notif.comment: write failed (ignored): $e');
    }
  }

  Future<void> delete({
    required String postId,
    required String commentId,
  }) async {
    await _ref.read(commentServiceProvider).deleteComment(
          postId: postId,
          commentId: commentId,
        );
    // ignore: avoid_print
    print('DEBUG comment: deleted post=$postId commentId=$commentId');
  }
}

final commentControllerProvider = Provider<CommentController>((ref) {
  return CommentController(ref);
});
