import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

class LikeController {
  LikeController(this._ref);
  final Ref _ref;

  /// Sadece toggle et. Bildirim yazma işi LikeService içinde hallediniyor.
  Future<void> toggle(String postId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    await _ref.read(likeServiceProvider).toggleLike(
      postId: postId,
      userId: uid,
    );
  }
}

final likeControllerProvider = Provider<LikeController>((ref) {
  return LikeController(ref);
});
