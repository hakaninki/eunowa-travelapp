// lib/features/notifications/widgets/notification_tile.dart
import 'package:flutter/material.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notif, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;

    switch (notif.type) {
      case AppNotificationType.like:
        icon = Icons.favorite;
        title = '${notif.fromUsername ?? 'Someone'} liked your post';
        break;
      case AppNotificationType.comment:
        icon = Icons.mode_comment_outlined;
        title = '${notif.fromUsername ?? 'Someone'} commented on your post';
        break;
      case AppNotificationType.follow:
        icon = Icons.person_add_alt_1;
        title = '${notif.fromUsername ?? 'Someone'} started following you';
        break;
    }

    return ListTile(
      leading: Icon(icon, color: Colors.red[200]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: notif.read ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: _buildSubtitle(),
      trailing:
          notif.read ? null : const CircleAvatar(radius: 5, backgroundColor: Colors.green),
      onTap: onTap,
    );
  }

  Widget _buildSubtitle() {
    final when = _timeAgo(notif.createdAt);
    if (notif.commentText == null || notif.commentText!.trim().isEmpty) {
      return Text(when, style: const TextStyle(fontSize: 12));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“${notif.commentText}”',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(when, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
