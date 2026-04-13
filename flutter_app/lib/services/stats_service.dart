import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class StatsService {
  static final Dio _dio = DioClient.instance;

  /// GET /general-stats/
  static Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final response = await _dio.get(ApiConstants.generalStats);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
