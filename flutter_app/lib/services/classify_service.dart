import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class ClassifyService {
  static final Dio _dio = DioClient.instance;

  /// POST /classify-image/ (multipart)
  static Future<Map<String, dynamic>> classifyImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        ApiConstants.classifyImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
