import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';

final postsByLocationProvider =
    StreamProvider.family<List<PostModel>, String>((ref, label) {
  final ps = ref.watch(postServiceProvider);
  return ps.watchPostsByLocationLabel(label);
});
