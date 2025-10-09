// lib/features/notifications/widgets/notifications_appbar.dart
import 'package:flutter/material.dart';
import 'package:travel_app/core/constants/app_colors.dart';

class NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int unread;
  final Future<int> Function()? onMarkAll;
  const NotificationsAppBar({super.key, required this.unread, this.onMarkAll});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Notifications'),
      backgroundColor: AppColors.appBarPeach,
      actions: [
        if (unread > 0 && onMarkAll != null)
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              try {
                final n = await onMarkAll!();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Marked $n notifications as read')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
          ),
      ],
    );
  }
}
