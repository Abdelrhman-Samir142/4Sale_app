import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/cache/offline_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Hive-backed offline cache ──────────────────────
  await OfflineCache.init();

  // ── Global error handlers (prevent red screens in production) ─
  if (kReleaseMode) {
    // Show a grey placeholder instead of red error screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const ColoredBox(
        color: Color(0xFFF8FAFC),
        child: Center(
          child: Icon(Icons.error_outline_rounded,
              color: Color(0xFFCBD5E1), size: 40),
        ),
      );
    };
  }

  // Log uncaught Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // TODO: Send to crash reporting (Sentry / Crashlytics)
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  // Log uncaught platform/async errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[PlatformError] $error\n$stack');
    // TODO: Send to crash reporting (Sentry / Crashlytics)
    return true;
  };

  runApp(const ProviderScope(child: ForSaleApp()));
}
