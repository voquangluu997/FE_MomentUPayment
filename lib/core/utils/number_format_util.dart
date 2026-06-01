class NumberFormatUtil {
  static String formatNumber(String s) {
    String digits = s.replaceAll('.', '');
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String cleanValue(String value) {
    String clean = value.replaceAll('.', '');
    if (clean.length > 1 && clean.startsWith('0')) {
      clean = clean.replaceFirst(RegExp(r'^0+'), '');
    }
    return clean;
  }
}
