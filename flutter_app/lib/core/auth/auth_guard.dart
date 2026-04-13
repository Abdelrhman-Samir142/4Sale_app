import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  static Future<void> performStrictLogout(BuildContext context, {bool showSessionExpired = false}) async {
    // 1. Clear secure tokens
    await SecureStorageService.clearTokens();
    
    // 2. Clear ALL stored user data from SharedPrefs as requested
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 3. Reset auth state (If using Riverpod, this is implicitly caught by GoRouter's refreshListenable on next build,
    // but we forcibly wipe the stack below as requested).
    
    if (context.mounted && showSessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired, please login again / الجلسة انتهت، يرجى تسجيل الدخول مجدداً'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // 4. Navigate to LoginScreen and REMOVE ALL previous routes natively via GoRouter
    if (context.mounted) {
      context.go('/login');
    }
  }
}
