import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/product.dart';
import '../models/paginated_response.dart';

class ProductsService {
  static final Dio _dio = DioClient.instance;

  /// GET /products/ with optional query params
  static Future<PaginatedResponse<Product>> list({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    bool? isAuction,
    bool? auctionsOnly,
    String? search,
    int? page,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (category != null) params['category'] = category;
      if (minPrice != null) params['min_price'] = minPrice;
      if (maxPrice != null) params['max_price'] = maxPrice;
      if (condition != null) params['condition'] = condition;
      if (isAuction != null) params['is_auction'] = isAuction;
      if (auctionsOnly != null && auctionsOnly) params['auctions_only'] = 'true';
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (page != null) params['page'] = page;

      final response = await _dio.get(ApiConstants.products, queryParameters: params);
      return PaginatedResponse<Product>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /products/{id}/
  static Future<Product> get(String id) async {
    try {
      final response = await _dio.get(ApiConstants.productDetail(id));
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /products/ (multipart with images)
  static Future<Product> create({
    required String title,
    required String description,
    required double price,
    required String category,
    required String condition,
    required String location,
    String? phoneNumber,
    bool isAuction = false,
    String? auctionEndTime,
    List<String>? imagePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'location': location,
        'phone_number': phoneNumber,
        'is_auction': isAuction,
        'auction_end_time': auctionEndTime,
      });

      if (imagePaths != null) {
        for (final path in imagePaths) {
          formData.files.add(MapEntry(
            'uploaded_images',
            await MultipartFile.fromFile(path),
          ));
        }
      }

      final response = await _dio.post(
        ApiConstants.products,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      try {
        return Product.fromJson(response.data as Map<String, dynamic>);
      } catch (parseError) {
        throw Exception("Parse Error: $parseError\nData: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// PATCH /products/{id}/
  static Future<Product> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(ApiConstants.productDetail(id), data: data);
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// DELETE /products/{id}/
  static Future<void> delete(String id) async {
    try {
      await _dio.delete(ApiConstants.productDetail(id));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /products/my_listings/
  static Future<List<Product>> getMyListings() async {
    try {
      final response = await _dio.get(ApiConstants.myListings);
      final list = response.data as List<dynamic>;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /products/{id}/ai_analysis/
  static Future<Map<String, dynamic>> getAIAnalysis(String id) async {
    try {
      final response = await _dio.get(ApiConstants.aiAnalysis(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /categories/
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      debugPrint('[ProductsService] Categories response received');
      
      if (response.data is List) {
        final list = response.data as List<dynamic>;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        debugPrint('[ProductsService] Categories: non-list data');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('[ProductsService] Categories DioError: ${e.response?.statusCode}');
      throw Exception(parseDioError(e));
    } catch (e) {
      debugPrint('[ProductsService] Categories error: $e');
      return [];
    }
  }
}
