import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  /// Keys to PRESERVE across logout (user experience settings).
  static const _preservedKeys = {'locale', 'language_selected', 'theme_mode'};

  static Future<void> performStrictLogout(BuildContext context, {bool showSessionExpired = false}) async {
    // 1. Clear secure tokens (JWT access + refresh)
    await SecureStorageService.clearTokens();
    
    // 2. Clear SharedPrefs EXCEPT user-experience settings
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (!_preservedKeys.contains(key)) {
        await prefs.remove(key);
      }
    }

    // 3. Show session-expired message if triggered by token refresh failure
    if (context.mounted && showSessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired, please login again / الجلسة انتهت، يرجى تسجيل الدخول مجدداً'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // 4. Navigate to LoginScreen and REMOVE ALL previous routes
    if (context.mounted) {
      context.go('/login');
    }
  }
}

