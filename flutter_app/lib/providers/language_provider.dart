import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/i18n/dictionaries.dart';

/// Persisted language state (ar/en) with RTL/LTR support.
final languageProvider =
    NotifierProvider<LanguageNotifier, LanguageState>(LanguageNotifier.new);

class LanguageState {
  final String locale; // 'ar' or 'en'
  final Dict dict;
  final bool isRtl;
  final TextDirection textDirection;

  LanguageState({required this.locale})
      : dict = getDictionary(locale),
        isRtl = locale == 'ar',
        textDirection =
            locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}

class LanguageNotifier extends Notifier<LanguageState> {
  static const _key = 'locale';

  @override
  LanguageState build() {
    _load();
    return LanguageState(locale: 'ar');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && (saved == 'ar' || saved == 'en')) {
      state = LanguageState(locale: saved);
    }
  }

  Future<void> toggle() async {
    final next = state.locale == 'ar' ? 'en' : 'ar';
    await setLanguage(next);
  }

  Future<void> setLanguage(String next) async {
    state = LanguageState(locale: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next);
    await prefs.setBool('language_selected', true);
  }
}
