import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class StorageService {
  // TODO: Replace these with your actual Cloudinary credentials
  static const String _cloudName = 'djyevccou';
  static const String _apiKey = '222753221969373';
  static const String _apiSecret = 'UtW8LVmaLAr6861cm8dxzgV7pbw';

  String _generateSignature(int timestamp) {
    final stringToSign = 'timestamp=$timestamp$_apiSecret';
    final bytes = utf8.encode(stringToSign);
    return sha1.convert(bytes).toString();
  }

  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(timestamp);

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      
      if (response.statusCode == 200) {
        final url = json['secure_url'] as String;
        debugPrint('Cloudinary signed upload successful: $url');
        return url;
      } else {
        throw Exception('Cloudinary signed upload failed: ${json['error']?['message'] ?? body}');
      }
    } catch (e) {
      debugPrint('StorageService.uploadImage Error: $e');
      rethrow;
    }
  }

  Future<String> uploadBytes(Uint8List bytes, String path, String extension) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(timestamp);

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'upload.$extension',
        ));
      
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      
      if (response.statusCode == 200) {
        final url = json['secure_url'] as String;
        debugPrint('Cloudinary signed bytes upload successful: $url');
        return url;
      } else {
        throw Exception('Cloudinary signed bytes upload failed: ${json['error']?['message'] ?? body}');
      }
    } catch (e) {
      debugPrint('StorageService.uploadBytes Error: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    debugPrint('Cloudinary delete requested for: $url (requires signature, skipped)');
  }
}
