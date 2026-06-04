import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  /// Rung nhẹ (Light): Dùng cho việc gõ bàn phím số, chuyển đổi tab,
  /// chọn lựa các chip (QuickPeriodChips)
  Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Rung vừa (Medium): Dùng khi mở các BottomSheet, nhấn giữ (Long press)
  /// hoặc tương tác cần chú ý vừa phải
  Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Rung thành công (Success/Heavy): Khi bấm "Lưu chi tiêu" thành công,
  /// widget cập nhật xong, hoặc thanh toán hoàn tất
  Future<void> success() async {
    // Trên iOS/Android gốc, chuỗi rung kép (vibrate) tạo cảm giác hoàn thành tốt hơn
    await HapticFeedback.vibrate();
  }

  /// Rung cảnh báo/Lỗi (Selection/Pattern): Khi nhập thiếu thông tin,
  /// validate form thất bại, hoặc bấm nhầm nút bị khóa
  Future<void> error() async {
    // Gọi liên tiếp 2 hoặc 3 lần light/medium cách nhau một chút để giả lập tiếng "tạch tạch" lỗi
    await HapticFeedback.heavyImpact();
  }
}

// Khai báo Provider để inject vào các Controller hoặc Widget
final hapticServiceProvider = Provider((ref) => HapticService());
