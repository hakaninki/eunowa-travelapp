// lib/core/services/geocoding/geocoding_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Basit yer öneri modeli
class PlaceSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  PlaceSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

class GeocodingClient {
  final http.Client _http;

  GeocodingClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  /// Nominatim autocomplete
  /// Örn: q = "mersin", limit=5
  Future<List<PlaceSuggestion>> searchPlaces(String query, {int limit = 5, String lang = 'en'}) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query,
        'format': 'jsonv2',
        'addressdetails': '0',
        'limit': '$limit',
        'accept-language': lang,
      },
    );

    final res = await _http.get(
      uri,
      headers: {
        'User-Agent': 'travelapp/1.0 (contact: example@example.com)',
      },
    );

    if (res.statusCode != 200) {
      // ignore: avoid_print
      print('Nominatim error: ${res.statusCode} - ${res.body}');
      return [];
    }

    final data = jsonDecode(res.body);
    if (data is! List) return [];

    return data
        .map((e) {
          final name = (e['display_name'] as String?) ?? '';
          final lat = double.tryParse((e['lat'] ?? '').toString());
          final lon = double.tryParse((e['lon'] ?? '').toString());
          if (name.isEmpty || lat == null || lon == null) return null;
          return PlaceSuggestion(displayName: name, lat: lat, lon: lon);
        })
        .whereType<PlaceSuggestion>()
        .toList();
  }
}
