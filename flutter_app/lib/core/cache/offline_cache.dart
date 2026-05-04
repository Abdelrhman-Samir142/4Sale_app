import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Offline cache using Hive — no code generation required.
/// All data stored as JSON strings for flexibility.
///
/// Usage:
///   await OfflineCache.init();            // call once in main()
///   await OfflineCache.set('products', data);
///   final data = OfflineCache.get<Map>('products');
class OfflineCache {
  static const _boxName = 'foursale_cache';
  static const _maxAge = Duration(hours: 2);
  static late Box _box;

  /// Must be called once before any get/set operations.
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ── Write ───────────────────────────────────────────────────────
  static Future<void> set(String key, dynamic value) async {
    await _box.put(key, jsonEncode({
      'data': value,
      'ts': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  // ── Read ────────────────────────────────────────────────────────
  /// Returns cached data if it exists and isn't older than [maxAge].
  /// Returns null if missing or expired.
  static T? get<T>(String key, {Duration maxAge = _maxAge}) {
    final raw = _box.get(key) as String?;
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = map['ts'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > maxAge.inMilliseconds) return null;
      return map['data'] as T?;
    } catch (_) {
      return null;
    }
  }

  /// Returns cached data regardless of age (for offline fallback).
  static T? getStale<T>(String key) {
    final raw = _box.get(key) as String?;
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['data'] as T?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String key) => _box.delete(key);
  static Future<void> clear() => _box.clear();
}
