import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  // Tự động tải ngôn ngữ đã lưu từ máy lên
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    state = Locale(langCode);
  }

  // Hàm chuyển đổi qua lại giữa vi và en
  Future<void> toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.languageCode == 'vi') {
      state = const Locale('en');
      await prefs.setString('language_code', 'en');
    } else {
      state = const Locale('vi');
      await prefs.setString('language_code', 'vi');
    }
  }
}
