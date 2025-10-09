import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/user/services/user_service.dart';

/// UserService provider (DI için)
final userServiceProvider = Provider<UserService>((ref) => UserService());

/// Tek bir kullanıcıyı gerçek zamanlı dinler: users/{uid}
final userStreamProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  final svc = ref.watch(userServiceProvider);
  return svc.watchUser(uid);
});
