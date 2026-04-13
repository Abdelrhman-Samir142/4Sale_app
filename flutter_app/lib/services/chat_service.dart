import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class ChatService {
  static final Dio _dio = DioClient.instance;

  /// GET /conversations/
  static Future<List<dynamic>> getConversations() async {
    try {
      final response = await _dio.get(ApiConstants.conversations);
      final data = response.data;
      return data is List ? data : (data['results'] as List? ?? []);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /conversations/{id}/
  static Future<Map<String, dynamic>> getConversation(int id) async {
    try {
      final response = await _dio.get(ApiConstants.conversationDetail(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /conversations/start_conversation/
  static Future<Map<String, dynamic>> startConversation(int productId) async {
    try {
      final response = await _dio.post(
        ApiConstants.startConversation,
        data: {'product_id': productId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /conversations/{id}/send_message/
  static Future<Map<String, dynamic>> sendMessage(
      int conversationId, String content) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendMessage(conversationId),
        data: {'content': content},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /conversations/unread_count/
  static Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.unreadCount);
      return response.data['unread_count'] as int;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// DELETE /conversations/{id}/delete_conversation/
  static Future<void> deleteConversation(int id) async {
    try {
      await _dio.delete(ApiConstants.deleteConversation(id));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// DELETE /conversations/{id}/delete_message/{msgId}/
  static Future<void> deleteMessage(int convId, int msgId) async {
    try {
      await _dio.delete(ApiConstants.deleteMessage(convId, msgId));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// PATCH /conversations/{id}/edit_message/{msgId}/
  static Future<Map<String, dynamic>> editMessage(
      int convId, int msgId, String content) async {
    try {
      final response = await _dio.patch(
        ApiConstants.editMessage(convId, msgId),
        data: {'content': content},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
