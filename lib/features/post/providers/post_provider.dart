import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/services/cloudinary_service.dart';
import 'package:travel_app/features/post/services/post_service.dart';
import 'package:travel_app/features/post/services/like_service.dart';
import 'package:travel_app/features/post/services/comment_service.dart';

/// Cloudinary
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  // AppConfig artık static; CloudinaryService içinde AppConfig.* kullanılıyor.
  return CloudinaryService();
});

/// Services
final postServiceProvider = Provider<PostService>((ref) {
  final cloud = ref.watch(cloudinaryServiceProvider);
  return PostService(cloud);
});

final likeServiceProvider = Provider<LikeService>((ref) => LikeService());
final commentServiceProvider = Provider<CommentService>((ref) => CommentService());
