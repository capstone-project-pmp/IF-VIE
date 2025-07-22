import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Tambahkan di pubspec.yaml

class CloudinaryMethods {
  final String cloudName = 'dho4pl5re'; // GANTI sesuai data kamu
  final String uploadPreset = 'campusyc'; // GANTI sesuai preset kamu (unsigned)

  /// ✅ Upload image ke Cloudinary dan mengembalikan secure URL-nya.
  /// Return `null` jika gagal upload.
  Future<String?> uploadImage(Uint8List fileBytes, String folder) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: 'img_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonRes = json.decode(responseBody);
        final secureUrl = jsonRes['secure_url'];

        if (secureUrl != null && secureUrl.toString().isNotEmpty) {
          print('✅ Cloudinary Upload Success: $secureUrl');
          return secureUrl;
        } else {
          print('⚠️ Upload succeeded, but no secure_url returned.');
          return null;
        }
      } else {
        print('❌ Cloudinary Error [${response.statusCode}]: $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Exception during Cloudinary upload: $e');
      return null;
    }
  }
}
