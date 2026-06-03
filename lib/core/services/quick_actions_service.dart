import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  final QuickActions _quickActions = const QuickActions();

  // Lưu callback để gọi khi app đã khởi tạo xong
  Function()? _onAddTransactionCallback;

  // Khởi tạo, không cần Context
  void init(Function() onAddTransactionTap) {
    _onAddTransactionCallback = onAddTransactionTap;

    // 1. Cấu hình các mục phím tắt
    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_add_fast',
        localizedTitle: 'Thêm chi tiêu nhanh',
        icon: 'icon_add', // Đảm bảo file này tồn tại trong Native assets
      ),
    ]);

    // 2. Lắng nghe sự kiện
    _quickActions.initialize((String type) {
      if (type == 'action_add_fast') {
        _onAddTransactionCallback?.call();
      }
    });
  }
}

// Provider đơn giản
final quickActionsServiceProvider = Provider((ref) => QuickActionsService());
