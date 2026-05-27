import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔑 Khởi tạo một Provider rỗng, giá trị thực tế sẽ được nạp đè (override) từ hàm main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// 🔑 Định nghĩa Notifier quản lý trạng thái tiền tệ lưu trữ bền vững
class CurrencyNotifier extends Notifier<String> {
  static const _currencyKey = 'selected_currency_symbol';

  @override
  String build() {
    // Đọc instance SharedPreferences đã được nạp sẵn từ main()
    final prefs = ref.watch(sharedPreferencesProvider);
    // Trả về ký hiệu đã lưu từ trước, nếu app mới cài đặt/chưa lưu thì mặc định trả về '₫'
    return prefs.getString(_currencyKey) ?? '₫';
  }

  // Hàm thay đổi tiền tệ đồng thời tự động ghi đè xuống bộ nhớ máy
  void setCurrency(String newCurrency) async {
    state = newCurrency; // Thay đổi giao diện trên UI ngay lập tức

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      _currencyKey,
      newCurrency,
    ); // Ghi dữ liệu ngầm xuống thiết bị
  }
}

// 🔑 Khai báo provider toàn cục thay thế cho StateProvider cũ
final currencyProvider = NotifierProvider<CurrencyNotifier, String>(() {
  return CurrencyNotifier();
});
