import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';

class AuthService {
  static final Dio _dio = DioClient.instance;

  /// POST /auth/register/
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String city,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
        'city': city,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      final data = response.data as Map<String, dynamic>;
      // Store tokens
      await SecureStorageService.setAccessToken(data['tokens']['access']);
      await SecureStorageService.setRefreshToken(data['tokens']['refresh']);
      return data;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /auth/login/
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'username': username,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await SecureStorageService.setAccessToken(data['access']);
      await SecureStorageService.setRefreshToken(data['refresh']);
      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('اسم المستخدم أو كلمة المرور غلط');
      }
      throw Exception(parseDioError(e));
    }
  }

  /// GET /auth/me/
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.currentUser);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
