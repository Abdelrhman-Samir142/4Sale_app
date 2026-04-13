import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class RagService {
  static final Dio _dio = DioClient.instance;

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
