// lib/features/map/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/features/map/widgets/map_post_marker.dart';
import 'package:travel_app/features/map/pages/location_posts_page.dart';
import 'package:travel_app/core/constants/app_colors.dart';

/// Tüm postları izleyip map'e vereceğiz
final mapPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final ps = ref.watch(postServiceProvider);
  return ps.watchPosts();
});

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(mapPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: AppColors.appBarPeach,
      ),
      body: postsAsync.when(
        data: (posts) {
          final markers = posts
              .where((p) => p.lat != null && p.lng != null)
              .map(
                (p) => Marker(
                  point: LatLng(p.lat!, p.lng!),
                  width: 40,
                  height: 40,
                  child: MapPostMarker(
                    onTap: () {
                      final label = p.location;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationPostsPage(
                            locationLabel: label,
                            lat: p.lat,
                            lng: p.lng,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList();

          final center = markers.isNotEmpty
              ? markers.first.point
              : const LatLng(39.0, 35.0); // TR ortalama

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 5),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travel_app',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
