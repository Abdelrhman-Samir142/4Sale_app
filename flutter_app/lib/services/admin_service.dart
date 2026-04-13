import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

/// Admin service — uses existing backend endpoints with admin-level access.
/// For admin-specific endpoints that don't exist yet, we gracefully fall back.
class AdminService {
  static final Dio _dio = DioClient.instance;

  /// GET /general-stats/ — overall platform metrics
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get(ApiConstants.generalStats);
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// GET /products/ — all products (admin sees all)
  static Future<List<dynamic>> getAllProducts({int page = 1}) async {
    try {
      final response = await _dio.get(ApiConstants.products,
          queryParameters: {'page': page});
      return (response.data['results'] as List?) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// GET /auctions/ — all auctions
  static Future<List<dynamic>> getAllAuctions() async {
    try {
      final response = await _dio.get(ApiConstants.auctions);
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['results'] != null) {
        return data['results'] as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// GET /conversations/ — all conversations (admin view)
  static Future<List<dynamic>> getAllConversations() async {
    try {
      final response = await _dio.get(ApiConstants.conversations);
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['results'] != null) {
        return data['results'] as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// GET /notifications/ — all notifications
  static Future<List<dynamic>> getAllNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications);
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['results'] != null) {
        return data['results'] as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// DELETE /products/{id}/ — admin delete product
  static Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete(ApiConstants.productDetail(id));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// PATCH /products/{id}/ — admin update product
  static Future<void> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      await _dio.patch(ApiConstants.productDetail(id), data: data);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
