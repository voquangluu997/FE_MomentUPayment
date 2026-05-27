import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/data/repositories/budget_repository.dart';
import '../data/models/budget_summary.dart';

// Sử dụng AsyncNotifier để quản lý trạng thái bất đồng bộ sạch sẽ
class HomeBudgetNotifier extends AutoDisposeAsyncNotifier<BudgetSummary> {
  @override
  FutureOr<BudgetSummary> build() {
    // Gọi repository để lấy dữ liệu từ Backend
    return ref.read(budgetRepositoryProvider).getBudgetSummary();
  }

  // Hàm giúp UI ra lệnh nạp lại dữ liệu sau khi cập nhật ngân sách thành công
  Future<void> refreshSummary() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).getBudgetSummary(),
    );
  }
}

final homeBudgetProvider =
    AsyncNotifierProvider.autoDispose<HomeBudgetNotifier, BudgetSummary>(() {
      return HomeBudgetNotifier();
    });
