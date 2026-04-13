import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class WishlistService {
  static final Dio _dio = DioClient.instance;

  /// GET /wishlist/
  static Future<List<dynamic>> list() async {
    try {
      final response = await _dio.get(ApiConstants.wishlist);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /wishlist/toggle/{productId}/
  static Future<Map<String, dynamic>> toggle(int productId) async {
    try {
      final response = await _dio.post(ApiConstants.wishlistToggle(productId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /wishlist/check/{productId}/
  static Future<bool> check(int productId) async {
    try {
      final response = await _dio.get(ApiConstants.wishlistCheck(productId));
      return response.data['is_wishlisted'] as bool;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /wishlist/ids/
  static Future<List<int>> getIds() async {
    try {
      final response = await _dio.get(ApiConstants.wishlistIds);
      final ids = response.data['product_ids'] as List;
      return ids.cast<int>();
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
