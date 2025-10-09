import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/post/presentation/pages/likers_page.dart';
import 'package:travel_app/features/post/presentation/pages/comments_page.dart';
import 'package:travel_app/features/post/providers/like_stream_provider.dart';
import 'package:travel_app/features/post/providers/comment_stream_provider.dart';
import 'package:travel_app/features/post/application/like_controller.dart';

class PostActionsInfo extends ConsumerWidget {
  final String postId;
  final EdgeInsets? padding;

  const PostActionsInfo({
    super.key,
    required this.postId,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeCountAsync = ref.watch(likeCountStreamProvider(postId));
    final isLikedAsync = ref.watch(isLikedStreamProvider(postId));
    final commentCountAsync = ref.watch(commentCountStreamProvider(postId));
    final likeCtrl = ref.read(likeControllerProvider);

    void openLikers() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LikersPage(postId: postId)),
      );
    }

    void openComments() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CommentsPage(postId: postId)),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Like',
            icon: Icon(
              isLikedAsync.asData?.value == true
                  ? Icons.favorite
                  : Icons.favorite_border_outlined,
              color: Colors.red[400],
            ),
            onPressed: () async {
              await likeCtrl.toggle(postId);
            },
          ),

          likeCountAsync.when(
            data: (count) => GestureDetector(
              onTap: openLikers,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '$count likes',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => GestureDetector(
              onTap: openLikers,
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text('0 likes', style: TextStyle(color: Colors.black54)),
              ),
            ),
          ),

          const Spacer(),

          IconButton(
            tooltip: 'Comments',
            icon: const Icon(Icons.mode_comment_outlined, color: Colors.black54),
            onPressed: openComments,
          ),

          commentCountAsync.when(
            data: (count) => GestureDetector(
              onTap: openComments,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Text(
                  '$count comments',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => GestureDetector(
              onTap: openComments,
              child: const Padding(
                padding: EdgeInsets.only(left: 4.0, right: 4.0),
                child: Text('0 comments', style: TextStyle(color: Colors.black54)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
