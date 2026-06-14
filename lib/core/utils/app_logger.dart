import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class AppLogger {
  // Ngăn chặn khởi tạo instance để dùng chuẩn như một Utility Class
  AppLogger._();

  static void d(String tag, String message) {
    if (kDebugMode) {
      final ts = DateTime.now().toIso8601String();
      developer.log("[DEBUG] $ts | $message", name: tag);
    }
  }

  static void i(String tag, String message) {
    if (kDebugMode) {
      final ts = DateTime.now().toIso8601String();
      developer.log("[INFO]  $ts | $message", name: tag);
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      final ts = DateTime.now().toIso8601String();
      // level 900 tương đương với Warning
      developer.log("[WARN]  $ts | $message", name: tag, level: 900);
    }
  }

  static void e(String tag, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      final ts = DateTime.now().toIso8601String();
      // level 1000 tương đương với Error
      developer.log(
        "[ERROR] $ts | $error",
        name: tag,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
