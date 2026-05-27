import 'package:intl/intl.dart';

class CurrencyHelper {
  static String formatCompactAmount(dynamic numValue) {
    if (numValue == null) return '0₫';

    // Ép kiểu an toàn về số thực double
    final double value = double.tryParse(numValue.toString()) ?? 0.0;

    // 1. Nếu từ 1 tỷ trở lên -> Rút gọn chữ b thường gạch chân (b̲)
    if (value >= 1000000000) {
      double shortValue = value / 1000000000;
      String formatted = shortValue % 1 == 0
          ? shortValue.toStringAsFixed(0)
          : shortValue.toStringAsFixed(2);
      return '${formatted}B'; // 🔑 b thường gạch chân
    }

    // 2. Nếu từ 1 triệu trở lên -> Rút gọn chữ m thường gạch chân (m̲)
    if (value >= 1000000) {
      double shortValue = value / 1000000;
      String formatted = shortValue % 1 == 0
          ? shortValue.toStringAsFixed(0)
          : shortValue.toStringAsFixed(2);
      return '${formatted}M'; // 🔑 m thường gạch chân
    }

    // 3. Nếu dưới 1 triệu -> Giữ nguyên số 0 phân tách dấu chấm, viết liền '₫'
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(value.toInt());
  }
}
