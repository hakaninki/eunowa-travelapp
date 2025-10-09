import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/user_model.dart';
//import 'package:travel_app/features/user/services/user_service.dart';
import 'package:travel_app/features/user/providers/user_provider.dart'; // mevcut provider'ınız (UserService)

/// Arama sorgusu (sayfa yaşam döngüsünde otomatik temizlensin)
final userSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Sorguya göre canlı sonuçlar
final userSearchResultsProvider =
    StreamProvider.autoDispose<List<UserModel>>((ref) {
  final q = ref.watch(userSearchQueryProvider);
  final svc = ref.watch(userServiceProvider);
  return svc.watchUsersByPrefix(q);
});
