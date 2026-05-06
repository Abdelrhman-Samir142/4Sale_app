import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class ClassifyService {
  static final Dio _dio = DioClient.instance;

  /// POST /classify-image/ (multipart)
  static Future<Map<String, dynamic>> classifyImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      debugPrint('[ClassifyService] POST ${ApiConstants.classifyImage}');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.classifyImage,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('[ClassifyService] Status: ${response.statusCode}');

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        debugPrint('[ClassifyService] Non-map response: ${response.data}');
        return {'category': 'other'};
      }
    } on DioException catch (e) {
      debugPrint('[ClassifyService] DioError: ${e.response?.statusCode}');
      throw Exception(parseDioError(e));
    } catch (e) {
      debugPrint('[ClassifyService] Unknown error: $e');
      return {'category': 'other'};
    }
  }
}
