import 'package:moment_u_payment/l10n/app_localizations.dart';

class CategoryHelper {
  // 1. Định nghĩa các ID chuẩn (Tránh việc gõ sai text 'Food', 'Shopping' ở các nơi)
  static const String idFood = 'Food';
  static const String idShopping = 'Shopping';
  static const String idTransport = 'Transport';
  static const String idEntertainment = 'Entertainment';
  static const String idCustom = 'Custom';

  // 2. Danh sách các danh mục mặc định (Dùng chung)
  static List<Map<String, dynamic>> _getBaseCategories(AppLocalizations l10n) {
    return [
      {'id': idFood, 'name': l10n.catFood, 'emoji': '🍰'},
      {'id': idShopping, 'name': l10n.catShopping, 'emoji': '🛍️'},
      {'id': idTransport, 'name': l10n.catTransport, 'emoji': '🛵'},
      {'id': idEntertainment, 'name': l10n.catEntertainment, 'emoji': '🍿'},
    ];
  }

  // 3. Dành cho màn hình Thêm Transaction (Thêm mục "Khác/Tùy chỉnh")
  static List<Map<String, dynamic>> getTransactionCategories(
    AppLocalizations l10n,
  ) {
    final categories = _getBaseCategories(l10n);
    categories.add({'id': idCustom, 'name': l10n.catCustom, 'emoji': '✨'});
    return categories;
  }

  // 4. Dành cho thanh Filter (Thêm mục "Tất cả" ở đầu và "Khác" ở cuối)
  static List<Map<String, dynamic>> getFilterCategories(AppLocalizations l10n) {
    // 🔥 SỬA TẠI ĐÂY: Khai báo rõ ràng kiểu List<Map<String, dynamic>>
    final List<Map<String, dynamic>> categories = [
      {'id': null, 'name': 'All', 'emoji': ''},
    ];

    categories.addAll(_getBaseCategories(l10n));

    categories.add({'id': idCustom, 'name': l10n.catCustom, 'emoji': '✨'});
    return categories;
  }

  // 5. Hàm Helper hỗ trợ Logic Filter (Rất quan trọng cho Bước 4 bên dưới)
  static bool isStandardCategory(String categoryName) {
    return [
      idFood,
      idShopping,
      idTransport,
      idEntertainment,
    ].contains(categoryName);
  }

  String getLocalizedCategory(String? categoryKey, AppLocalizations l10n) {
    if (categoryKey == null || categoryKey.isEmpty) return l10n.other;
    switch (categoryKey.toLowerCase()) {
      case 'food':
        return l10n.food;
      case 'transport':
        return l10n.transport;
      case 'shopping':
        return l10n.shopping;
      case 'entertainment':
        return l10n.entertainment;
      // Thêm các case khác tương ứng với file .arb của bạn
      default:
        return "${categoryKey[0].toUpperCase()}${categoryKey.substring(1).toLowerCase()}";
    }
  }
}
