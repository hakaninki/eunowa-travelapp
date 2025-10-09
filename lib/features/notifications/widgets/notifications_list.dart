// lib/features/notifications/widgets/notifications_list.dart
import 'package:flutter/material.dart';
import 'package:travel_app/core/widgets/async_error.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';
import 'package:travel_app/features/notifications/widgets/notification_tile.dart';

typedef NotificationTap = Future<void> Function(AppNotification notif);

class NotificationsSliverList extends StatelessWidget {
  final AsyncSnapshot<List<AppNotification>> snapshot;
  final NotificationTap onTap;

  const NotificationsSliverList({
    super.key,
    required this.snapshot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverToBoxAdapter(
        child: AsyncErrorWidget(error: snapshot.error as Object, message: 'Failed to load notifications.'),
      );
    }

    final items = snapshot.data ?? const <AppNotification>[];
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No notifications yet')),
        ),
      );
    }

    return SliverList.separated(
      itemBuilder: (context, i) {
        final n = items[i];
        return NotificationTile(
          notif: n,
          onTap: () => onTap(n),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }
}
