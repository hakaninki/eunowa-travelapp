import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/tappable_post_card.dart';

class HomeSliverList extends StatelessWidget {
  final List<PostModel> posts;

  /// Sonsuz kaydırma için opsiyonel parametreler
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeSliverList({
    super.key,
    required this.posts,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Footer tetikleyici
          final isLast = index == posts.length;
          if (isLast) {
            // sayfa sonuna gelindi, bir sonraki frame'de loadMore çağır
            if (hasMore && !isLoadingMore && onLoadMore != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore!());
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: hasMore
                    ? const CircularProgressIndicator()
                    : const Text('No more posts'),
              ),
            );
          }

          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TappablePostCard(post: post),
          );
        },
        childCount: posts.length + 1, // +1 footer
      ),
    );
  }
}
