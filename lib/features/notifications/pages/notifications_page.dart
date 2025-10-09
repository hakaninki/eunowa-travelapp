// lib/features/notifications/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';
import 'package:travel_app/features/notifications/providers/notifications_provider.dart';
import 'package:travel_app/features/notifications/widgets/notifications_appbar.dart';
import 'package:travel_app/features/notifications/widgets/notifications_list.dart';
import 'package:travel_app/features/post/presentation/pages/post_detail_page.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsStreamProvider);
    final unreadAsync = ref.watch(notificationsUnreadCountProvider);
    final controller = ref.read(notificationsControllerProvider);

    final unread = unreadAsync.maybeWhen(data: (v) => v, orElse: () => 0);

    return Scaffold(
      appBar: NotificationsAppBar(
        unread: unread,
        onMarkAll: controller.markAllAsRead,
      ),
      body: CustomScrollView(
        slivers: [
          // Liste UI’si ayrı widget’ta; sayfa sadece callback sağlar.
          NotificationsSliverList(
            snapshot: AsyncSnapshot.withData(ConnectionState.active, notifsAsync.asData?.value ?? []),
            onTap: (n) => _handleTap(context, controller, n),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    NotificationsController controller,
    AppNotification n,
  ) async {
    await controller.markAsRead(n.id);

    switch (n.type) {
      case AppNotificationType.follow:
        if (n.fromUid.isNotEmpty) {
          // ignore: use_build_context_synchronously
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProfilePage(userId: n.fromUid)),
          );
        }
        break;

      case AppNotificationType.like:
      case AppNotificationType.comment:
        final postId = n.postId;
        if (postId == null || postId.isEmpty) break;

        try {
          final PostModel? post = await controller.fetchPostById(postId);
          if (post == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post not found')),
              );
            }
            break;
          }
          if (context.mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to open post: $e')),
            );
          }
        }
        break;
    }
  }
}
