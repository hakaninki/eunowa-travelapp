// lib/features/main/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/home/home_page.dart';
import 'package:travel_app/features/post/presentation/pages/add_post_page.dart';
import 'package:travel_app/features/main/providers/nav_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';
import 'package:travel_app/features/notifications/pages/notifications_page.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';
import 'package:travel_app/features/map/map_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    // 🔹 unread count
    final unreadAsync = ref.watch(notificationsUnreadCountProvider);
    final unread = unreadAsync.maybeWhen(data: (v) => v, orElse: () => 0);

    final pages = const [
      HomePage(),
      NotificationsPage(),
      AddPostPage(),
      MapPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: const IconThemeData(size: 30),
        selectedItemColor: const Color(0xFFF09245),
        unselectedItemColor: Colors.black54,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: '',
          ),
          BottomNavigationBarItem(
            label: '',
            icon: _BadgeIcon(
              base: const Icon(Icons.notifications),
              count: unread,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final Widget base;
  final int count;
  const _BadgeIcon({required this.base, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return base;
    final text = count > 99 ? '99+' : '$count';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        base,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title, super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}
