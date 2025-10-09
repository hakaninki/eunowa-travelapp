// lib/features/post/presentation/widgets/comments_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/core/widgets/async_error.dart';
import 'package:travel_app/features/post/providers/comment_stream_provider.dart';
import 'package:travel_app/features/post/presentation/widgets/comment_item.dart';

class CommentsSection extends ConsumerWidget {
  final PostModel post;
  const CommentsSection({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsStreamProvider(post.id));

    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text('No comments yet')),
          );
        }
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: comments.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, i) {
            final c = comments[i];
            return CommentItem(comment: c);
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncErrorWidget(error: e, message: 'Failed to load comments.'),
      ),
    );
  }
}
