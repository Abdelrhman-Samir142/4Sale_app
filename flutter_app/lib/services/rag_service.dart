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
        options: Options(
          // RAG pipeline can take time (LLM + vector search + SQL)
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
