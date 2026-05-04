import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class AuctionsService {
  static final Dio _dio = DioClient.instance;

  /// GET /auctions/
  static Future<dynamic> list({bool activeOnly = false, int? page}) async {
    try {
      final params = <String, dynamic>{};
      if (activeOnly) params['active_only'] = 'true';
      if (page != null) params['page'] = page;
      final response =
          await _dio.get(ApiConstants.auctions, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /auctions/{id}/
  static Future<Map<String, dynamic>> get(String id) async {
    try {
      final response = await _dio.get(ApiConstants.auctionDetail(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /auctions/{id}/place_bid/
  static Future<Map<String, dynamic>> placeBid(
      String id, double amount) async {
    try {
      final response = await _dio.post(
        ApiConstants.placeBid(id),
        data: {'amount': amount},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
