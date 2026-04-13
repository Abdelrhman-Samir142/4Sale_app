import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class NotificationsService {
  static final Dio _dio = DioClient.instance;

  /// GET /notifications/
  static Future<List<dynamic>> list() async {
    try {
      final response = await _dio.get(ApiConstants.notifications);
      final data = response.data;
      return data is List ? data : (data['results'] as List? ?? []);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /notifications/mark-read/
  static Future<void> markAllRead() async {
    try {
      await _dio.post(ApiConstants.notificationsMarkRead);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /notifications/unread-count/
  static Future<int> unreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsUnreadCount);
      return response.data['unread_count'] as int;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
