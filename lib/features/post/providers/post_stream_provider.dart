import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  final service = ref.watch(postServiceProvider);
  return service.watchPosts();
});
