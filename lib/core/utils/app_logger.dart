class AppLogger {
  static void d(String tag, String message) {
    final ts = DateTime.now().toIso8601String();
    // using print as the low-level sink; can be replaced by package:logger later
    print("[DEBUG] $ts | $tag | $message");
  }

  static void i(String tag, String message) {
    final ts = DateTime.now().toIso8601String();
    print("[INFO]  $ts | $tag | $message");
  }

  static void w(String tag, String message) {
    final ts = DateTime.now().toIso8601String();
    print("[WARN]  $ts | $tag | $message");
  }

  static void e(String tag, Object error, [StackTrace? stackTrace]) {
    final ts = DateTime.now().toIso8601String();
    print("[ERROR] $ts | $tag | $error");
    if (stackTrace != null) print(stackTrace.toString());
  }
}
