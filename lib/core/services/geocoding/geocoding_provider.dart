// lib/core/services/geocoding/geocoding_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/services/geocoding/geocoding_client.dart';

final geocodingClientProvider = Provider<GeocodingClient>((ref) {
  return GeocodingClient();
});
