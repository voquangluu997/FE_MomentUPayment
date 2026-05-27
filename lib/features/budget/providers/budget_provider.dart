// features/budget/presentation/budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/budget_repository.dart';
import '../../../core/utils/app_logger.dart';

// 1. Thống nhất sử dụng enum trạng thái tương tự như TransactionState
enum BudgetState { initial, loading, success, error }

class BudgetNotifier extends StateNotifier<BudgetState> {
  final Ref _ref;

  BudgetNotifier(this._ref) : super(BudgetState.initial);

  // 2. Khai báo getter để lấy Repository thông qua Ref tập trung
  BudgetRepository get _repository => _ref.read(budgetRepositoryProvider);

  /// 🌸 CẬP NHẬT NGƯỠNG CHI TIÊU HÀNG THÁNG
  Future<void> updateBudgetLimit(double limit) async {
    state = BudgetState.loading;
    try {
      // Gọi repository để xử lý logic API (Token đã có Interceptor lo)
      await _repository.updateBudgetLimit(limit);

      // 3. Xử lý trạng thái sau khi thành công giống file tham khảo
      state = BudgetState.success;

      // Reset về ban đầu ngay lập tức để UI tránh bị kẹt ở trạng thái cũ
      state = BudgetState.initial;
    } catch (error, stackTrace) {
      // 4. Sử dụng AppLogger tập trung để bẫy và tracking lỗi hệ thống
      AppLogger.e('BudgetNotifier.updateBudgetLimit', error, stackTrace);
      state = BudgetState.error;
    }
  }

  /// Reset trạng thái thủ công khi cần thiết
  void resetState() => state = BudgetState.initial;
}

// 5. Khai báo StateNotifierProvider toàn cục
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier(ref);
});
