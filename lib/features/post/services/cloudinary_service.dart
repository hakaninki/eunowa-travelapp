import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:travel_app/core/constants/app_config.dart';

class CloudinaryService {
  Future<String> uploadImage(File file) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudName}/image/upload',
    );

    print('📤 Cloudinary → $url | preset=${AppConfig.unsignedPreset} | file=${file.path}');

    final req = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = AppConfig.unsignedPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();
    print('📦 Cloudinary resp [${res.statusCode}]: $body');

    if (res.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${res.statusCode}): $body');
    }

    final match = RegExp(r'"secure_url"\s*:\s*"([^"]+)"').firstMatch(body);
    final secureUrl = match?.group(1);
    if (secureUrl == null) {
      throw Exception('secure_url not found in response');
    }

    print('✅ Cloudinary URL: $secureUrl');
    return secureUrl;
  }
}
