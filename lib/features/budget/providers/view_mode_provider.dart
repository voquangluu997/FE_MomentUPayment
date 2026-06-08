import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Định nghĩa các chế độ hiển thị
enum ViewMode { list, grid, calendar }

// 2. Sử dụng AsyncNotifier để quản lý và lưu trữ trạng thái mượt mà
class ViewModeNotifier extends AsyncNotifier<ViewMode> {
  static const _viewModeKey = 'app_home_view_mode_pref';

  @override
  FutureOr<ViewMode> build() async {
    // Tự động load dữ liệu từ Local Storage khi khởi tạo
    return _loadSavedViewMode();
  }

  Future<ViewMode> _loadSavedViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_viewModeKey);

    if (savedMode != null) {
      // Tìm ViewMode tương ứng với chuỗi đã lưu
      return ViewMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ViewMode.list, // Nếu lỗi, mặc định là list
      );
    }
    return ViewMode.list; // Mặc định lần đầu tải app là List View
  }

  // Hàm gọi từ UI khi user bấm chuyển đổi View
  Future<void> updateViewMode(ViewMode newMode) async {
    // 🚀 Cập nhật UI ngay lập tức để không bị giật/lag (Optimistic Update)
    state = AsyncValue.data(newMode);

    // Tiến hành lưu xuống bộ nhớ ngầm
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewModeKey, newMode.name);
  }
}

// 3. Khởi tạo Provider
final viewModeProvider = AsyncNotifierProvider<ViewModeNotifier, ViewMode>(() {
  return ViewModeNotifier();
});
