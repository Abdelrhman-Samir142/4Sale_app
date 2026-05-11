import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class RagService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// POST /rag/query/
  static Future<Map<String, dynamic>> query(String queryText) async {
    try {
      final response = await _dio.post(
        ApiConstants.ragQuery,
        data: {'query': queryText},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
