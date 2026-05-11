import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';

class ClassifyService {
  /// POST /classify-image/ (multipart)
  static Future<Map<String, dynamic>> classifyImage(String filePath) async {
    try {
      debugPrint('[ClassifyService] POST ${ApiConstants.classifyImage}');
      
      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.classifyImage);
      final request = http.MultipartRequest('POST', uri);
      
      final token = await SecureStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[ClassifyService] Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } else {
        debugPrint('[ClassifyService] Server Error: ${response.body}');
      }
      return {'category': 'other'};
    } catch (e) {
      debugPrint('[ClassifyService] Unknown error: $e');
      return {'category': 'other'};
    }
  }
}
