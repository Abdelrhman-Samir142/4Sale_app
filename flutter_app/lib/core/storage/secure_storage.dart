import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for JWT token persistence.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // ── Access Token ──────────────────────────────────────────────
  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  static Future<void> setAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  // ── Refresh Token ─────────────────────────────────────────────
  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  // ── Clear all auth data ───────────────────────────────────────
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Returns true if an access token is stored.
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
