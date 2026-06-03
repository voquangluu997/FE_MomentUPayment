import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  // ⚠️ LƯU Ý: Tên App Group này phải khớp 100% trong Xcode (Signing & Capabilities)
  static const String _appGroupId = 'group.moment_u_payment';
  static const String _iOSWidgetName = 'MomentHomeWidget';

  /// Kiểm tra xem ứng dụng có được mở từ Widget không
  static Future<void> checkWidgetLaunch(VoidCallback onLaunch) async {
    try {
      // 🔥 SỬA LỖI TẠI ĐÂY: Bắt buộc phải set AppGroup trước khi gọi bất kỳ hàm nào của HomeWidget
      await HomeWidget.setAppGroupId(_appGroupId);

      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null && uri.host == 'add_transaction') {
        onLaunch();
      }
    } catch (e) {
      debugPrint('Lỗi checkWidgetLaunch: $e');
    }
  }

  /// Cập nhật dữ liệu ngân sách mới cho Widget
  static Future<void> updateBudgetWidget({
    required double budget,
    required double spent,
    required double remaining,
    required int daysRemaining,
  }) async {
    try {
      // Đảm bảo set lại App Group (Rất an toàn, không bị ảnh hưởng nếu gọi nhiều lần)
      await HomeWidget.setAppGroupId(_appGroupId);

      // Lưu dữ liệu vào User Defaults
      await HomeWidget.saveWidgetData<double>('budget_total', budget);
      await HomeWidget.saveWidgetData<double>('amount_spent', spent);
      await HomeWidget.saveWidgetData<double>('amount_remaining', remaining);
      await HomeWidget.saveWidgetData<int>('days_remaining', daysRemaining);

      // Ép Widget cập nhật giao diện
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _iOSWidgetName,
      );

      debugPrint('Widget đã cập nhật thành công');
    } catch (e) {
      debugPrint('Lỗi updateBudgetWidget: $e');
    }
  }
}
