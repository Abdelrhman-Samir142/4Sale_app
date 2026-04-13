import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../auth/auth_guard.dart';
import '../router/app_router.dart';

/// Singleton Dio HTTP client with JWT interceptor & error handling.
class DioClient {
  DioClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(_AuthInterceptor());

  static Dio get instance => _dio;
}

/// Interceptor that injects the JWT bearer token, handles 401s,
/// and attempts automatic token refresh.
class _AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await SecureStorageService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // Attempt to refresh the access token
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));
          final response = await refreshDio.post(
            ApiConstants.refreshToken,
            data: {'refresh': refreshToken},
          );
          final newAccess = response.data['access'] as String;
          await SecureStorageService.setAccessToken(newAccess);
          _isRefreshing = false;

          // Retry the original request with the new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await DioClient.instance.fetch(opts);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed — force global logout immediately
        _isRefreshing = false;
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          await AuthGuard.performStrictLogout(context, showSessionExpired: true);
          return handler.next(err); // Skip proceeding
        } else {
          await SecureStorageService.clearTokens();
        }
      }
      
      // If no refresh token existed in the first place or we fall through
      _isRefreshing = false;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
         await AuthGuard.performStrictLogout(ctx, showSessionExpired: true);
      }
    }
    handler.next(err);
  }
}

/// Parse DRF error responses into a user‑friendly message string.
/// Supports both Arabic and English fallback messages.
String parseDioError(DioException e, {String locale = 'en'}) {
  final isAr = locale == 'ar';

  // ── No response from server ─────────────────────────────────
  final data = e.response?.data;
  if (data == null) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return isAr ? 'انتهت مهلة الاتصال. حاول مرة أخرى' : 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return isAr ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection.';
      case DioExceptionType.cancel:
        return isAr ? 'تم إلغاء الطلب' : 'Request cancelled.';
      default:
        return e.message ?? (isAr ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred.');
    }
  }

  // ── HTTP status-based messages ──────────────────────────────
  final statusCode = e.response?.statusCode;
  if (statusCode != null) {
    if (statusCode == 404) {
      return isAr ? 'الصفحة أو الخدمة غير موجودة' : 'Resource not found (404).';
    }
    if (statusCode == 500) {
      return isAr ? 'خطأ في الخادم. حاول لاحقاً' : 'Server error. Please try again later.';
    }
    if (statusCode == 403) {
      return isAr ? 'ليس لديك صلاحية للوصول' : 'Access denied (403).';
    }
  }

  // ── Parse response body ─────────────────────────────────────
  if (data is Map) {
    // e.g. {"detail": "..."} or field errors {"username": ["Required"]}
    if (data.containsKey('detail')) return data['detail'].toString();
    if (data.containsKey('error')) return data['error'].toString();
    if (data.containsKey('message')) return data['message'].toString();

    // Field‑level errors
    final msgs = <String>[];
    data.forEach((key, value) {
      final msg = value is List ? value.join(', ') : value.toString();
      msgs.add('$key: $msg');
    });
    if (msgs.isNotEmpty) return msgs.join(' | ');
  }

  return data.toString();
}
