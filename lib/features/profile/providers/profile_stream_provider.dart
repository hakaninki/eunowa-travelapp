import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/user/services/user_service.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/core/models/post_model.dart';

final _userServiceProvider = Provider<UserService>((ref) => UserService());

/// users/{uid} stream
final userStreamProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  final svc = ref.watch(_userServiceProvider);
  return svc.watchUser(uid);
});

/// posts where uid == userId stream
final userPostsStreamProvider =
    StreamProvider.family<List<PostModel>, String>((ref, uid) {
  final postSvc = ref.watch(postServiceProvider);
  return postSvc.watchPostsByUser(uid);
});
