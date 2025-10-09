// lib/features/notifications/providers/notifications_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';
import 'package:travel_app/features/notifications/services/notifications_service.dart';

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

/// Bildirim listesi (my)
final notificationsStreamProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationsServiceProvider).watchMyNotifications();
});

/// Unread count (badge)
final notificationsUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(notificationsServiceProvider).unreadCountStream();
});

/// Controller: UI’dan Firestore/servis çağrılarını izole eder
class NotificationsController {
  NotificationsController(this._ref);
  final Ref _ref;

  Future<void> markAsRead(String notifId) {
    return _ref.read(notificationsServiceProvider).markAsRead(notifId);
  }

  Future<int> markAllAsRead() {
    return _ref.read(notificationsServiceProvider).markAllAsRead();
  }

  /// postId’den PostModel getir (UI burada Firestore’a dokunmasın)
  Future<PostModel?> fetchPostById(String postId) async {
    final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    return PostModel.fromMap({...data, 'id': doc.id});
  }
}

final notificationsControllerProvider = Provider<NotificationsController>((ref) {
  return NotificationsController(ref);
});
