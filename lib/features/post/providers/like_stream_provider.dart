import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

/// Like sayısı
final likeCountStreamProvider = StreamProvider.family<int, String>((ref, postId) {
  final svc = ref.watch(likeServiceProvider);
  return svc.likeCountStream(postId);
});

/// Bu kullanıcı beğenmiş mi?
final isLikedStreamProvider = StreamProvider.family<bool, String>((ref, postId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream<bool>.empty();
  final svc = ref.watch(likeServiceProvider);
  return svc.isLikedByUserStream(postId: postId, userId: uid);
});
