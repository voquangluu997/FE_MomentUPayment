import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  // Mặc định ban đầu app sẽ dùng tiếng Việt
  LocaleNotifier() : super(const Locale('vi'));

  void changeLocale(String languageCode) {
    if (languageCode == 'vi' || languageCode == 'en') {
      state = Locale(languageCode);
    }
  }
}

// Provider toàn cục để UI lắng nghe và thay đổi ngôn ngữ
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
