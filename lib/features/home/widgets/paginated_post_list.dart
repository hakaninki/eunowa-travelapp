import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/widgets/async_error.dart';
import 'package:travel_app/features/home/widgets/home_sliver_list.dart';
import 'package:travel_app/features/post/providers/post_paged_provider.dart';

/// CustomScrollView içine koy: PaginatedPostList()
class PaginatedPostList extends ConsumerStatefulWidget {
  const PaginatedPostList({super.key});

  @override
  ConsumerState<PaginatedPostList> createState() => _PaginatedPostListState();
}

class _PaginatedPostListState extends ConsumerState<PaginatedPostList> {
  @override
  void initState() {
    super.initState();
    // ilk sayfa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pagedPostsProvider.notifier).fetchFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    final notifier = ref.read(pagedPostsProvider.notifier);

    if (state.error != null && state.items.isEmpty) {
      return SliverToBoxAdapter(
        child: AsyncErrorWidget(
          error: state.error!,
          onRetry: notifier.fetchFirstPage,
          message: 'Failed to load feed.',
        ),
      );
    }

    if (state.isLoading && state.items.isEmpty) {
      // başlangıç skeleton listesi
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _PostSkeleton(),
          childCount: 5,
        ),
      );
    }

    return MultiSliver(
      slivers: [
        HomeSliverList(
          posts: state.items,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoading && state.items.isNotEmpty,
          onLoadMore: notifier.fetchNextPage,
        ),
        // Footer loader (opsiyonel)
        if (state.isLoading && state.items.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

/// Küçük skeleton (görsel ağırlıklı)
class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // header placeholders
          SizedBox(height: 12),
          _Bar(width: 140),
          SizedBox(height: 6),
          _Bar(width: 100),

          // image placeholder
          AspectRatio(aspectRatio: 4 / 3, child: _Rect()),
          SizedBox(height: 8),

          _Bar(width: 220),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  const _Bar({required this.width});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 12,
        width: width,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _Rect extends StatelessWidget {
  const _Rect();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black12),
    );
  }
}

/// Yardımcı: Birden fazla sliver'ı tek widget gibi döndürmek için
class MultiSliver extends StatelessWidget {
  final List<Widget> slivers;
  const MultiSliver({super.key, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [CustomScrollView(slivers: slivers, shrinkWrap: true, physics: const NeverScrollableScrollPhysics())],
      ),
    );
  }
}
