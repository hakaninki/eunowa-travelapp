import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';
import 'package:travel_app/features/post/providers/location_posts_provider.dart';

class LocationPostsPage extends ConsumerWidget {
  final String locationLabel;
  final double? lat;
  final double? lng;

  const LocationPostsPage({
    super.key,
    required this.locationLabel,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsByLocationProvider(locationLabel));

    return Scaffold(
      appBar: AppBar(
        title: Text(locationLabel, overflow: TextOverflow.ellipsis),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts for this location'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => PostCard(post: posts[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
