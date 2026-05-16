import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class ChatService {
  static final Dio _dio = DioClient.instance;

  /// GET /rag/sessions/ — list all sessions for current user
  static Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await _dio.get(ApiConstants.chatSessions);
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /rag/sessions/ — create a new session
  static Future<Map<String, dynamic>> createSession({String title = 'محادثة جديدة'}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatSessions,
        data: {'title': title},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /rag/sessions/{id}/ — get session with messages
  static Future<Map<String, dynamic>> getSession(int sessionId) async {
    try {
      final response = await _dio.get(ApiConstants.chatSessionDetail(sessionId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// DELETE /rag/sessions/{id}/ — delete a session
  static Future<void> deleteSession(int sessionId) async {
    try {
      await _dio.delete(ApiConstants.chatSessionDetail(sessionId));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /rag/sessions/{id}/send/ — send a message and get response
  static Future<Map<String, dynamic>> sendMessage(int sessionId, String query) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatSessionSend(sessionId),
        data: {'query': query},
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
