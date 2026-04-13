import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class ProfileService {
  static final Dio _dio = DioClient.instance;

  /// GET /profiles/me/
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.profileMe);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// PATCH /profiles/me/
  static Future<Map<String, dynamic>> update(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(ApiConstants.profileMe, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
