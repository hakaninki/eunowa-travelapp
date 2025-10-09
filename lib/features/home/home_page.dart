import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/features/home/widgets/home_sliver_appbar.dart';
import 'package:travel_app/features/home/widgets/home_sliver_list.dart';
import 'package:travel_app/core/widgets/async_error.dart';
import 'package:travel_app/features/post/providers/post_paged_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // İlk sayfayı bir kere çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pagedPostsProvider.notifier).fetchFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    final notifier = ref.read(pagedPostsProvider.notifier);

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () => notifier.refresh(),
        child: CustomScrollView(
          slivers: [
            const HomeSliverAppBar(),

            // Hata (ve hiç item yokken)
            if (state.error != null && state.items.isEmpty)
              SliverToBoxAdapter(
                child: AsyncErrorWidget(
                  error: state.error!,
                  onRetry: notifier.fetchFirstPage,
                  message: 'Failed to load feed.',
                ),
              )

            // İlk yükleniş skeleton
            else if (state.isLoading && state.items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )

            // Veri geldi
            else
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
        ),
      ),
    );
  }
}
