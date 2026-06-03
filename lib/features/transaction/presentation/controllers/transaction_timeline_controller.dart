import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/core/services/home_widget_service.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import '../../data/transaction_repository.dart';
import 'package:moment_u_payment/features/transaction/presentation/transaction_provider.dart';

class TransactionTimelineController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> _syncHomeWidget() async {
    try {
      // Nếu không có .future, nó sẽ lấy ngay giá trị lúc đang loading -> trả về null -> ra số 0
      final budgetSummary = await ref
          .read(homeBudgetProvider.future)
          .catchError((_) => null);

      if (budgetSummary == null)
        return; // Nếu lỗi mạng, dừng lại để giữ nguyên số cũ trên Widget

      // 1. Logic Ngân sách (Lấy trực tiếp từ HomeBudgetCard)
      final totalBudget = budgetSummary.budgetLimit.toDouble();
      final totalSpent = budgetSummary.totalSpent.toDouble();
      final remaining = totalBudget - totalSpent;

      // 2. Logic Ngày tháng (Lấy trực tiếp từ HomeBudgetCard)
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final daysRemaining = lastDayOfMonth.day - now.day;

      // 3. Đẩy dữ liệu chuẩn ra Widget
      await HomeWidgetService.updateBudgetWidget(
        budget: totalBudget,
        spent: totalSpent,
        remaining: remaining,
        daysRemaining: daysRemaining,
      );
    } catch (e, stack) {
      AppLogger.e('TransactionTimelineController._syncHomeWidget', e, stack);
    }
  }

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    final isAuthenticated = ref.watch(
      authProvider.select(
        (auth) =>
            auth == AuthState.authenticated || auth == AuthState.loginSuccess,
      ),
    );

    if (!isAuthenticated) {
      _page = 1;
      _hasMore = false;
      _isLoadingMore = false;
      return [];
    }

    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final initialData = await _fetchTimelineData(page: _page, limit: _limit);

    // Gọi hàm đồng bộ (chạy ngầm, không cần await block UI)
    _syncHomeWidget();

    return initialData;
  }

  Future<List<Map<String, dynamic>>> _fetchTimelineData({
    required int page,
    required int limit,
  }) async {
    return await _repository.getTransactions(page: page, limit: limit);
  }

  Future<void> refreshTimeline() async {
    final isAuthenticated = ref.read(
      authProvider.select(
        (auth) =>
            auth == AuthState.authenticated || auth == AuthState.loginSuccess,
      ),
    );
    if (!isAuthenticated) return;

    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    if (!state.hasValue || state.value!.isEmpty) {
      state = const AsyncValue.loading();
    }

    state = await AsyncValue.guard(() async {
      final refreshedData = await _fetchTimelineData(
        page: _page,
        limit: _limit,
      );

      _syncHomeWidget(); // Đồng bộ sau khi refresh

      return refreshedData;
    });
  }

  void removeMomentLocally(String id) {
    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList
          .where((moment) => moment['id'] != id)
          .toList();
      state = AsyncValue.data(updatedList);

      _syncHomeWidget(); // Đồng bộ lại
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    if (state.hasValue) {
      state = AsyncValue.data([...state.value!]);
    }

    try {
      final nextPage = _page + 1;
      final newTransactions = await _fetchTimelineData(
        page: nextPage,
        limit: _limit,
      );

      if (newTransactions.isEmpty || newTransactions.length < _limit) {
        _hasMore = false;
      }

      if (newTransactions.isNotEmpty) {
        _page = nextPage;
        if (state.hasValue) {
          state = AsyncValue.data([...state.value!, ...newTransactions]);
          _syncHomeWidget(); // Cập nhật khi tải thêm
        }
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        'TransactionTimelineController.loadNextPage',
        error,
        stackTrace,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final previousState = state;
    if (!state.hasValue) return;

    final currentList = state.value!;
    state = AsyncValue.data(
      currentList.where((tx) => tx['id'].toString() != id).toList(),
    );

    try {
      await _repository.deleteTransaction(id);

      // Xóa thành công -> yêu cầu Provider ngân sách tính lại tiền
      ref.invalidate(homeBudgetProvider);
      ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();

      // Chạy đồng bộ (hàm này sẽ tự động đợi homeBudgetProvider tải xong số mới)
      _syncHomeWidget();
    } catch (error, stackTrace) {
      AppLogger.e(
        'TransactionTimelineController.deleteTransaction',
        error,
        stackTrace,
      );
      state = previousState;
      rethrow;
    }
  }
}

final transactionTimelineProvider =
    AsyncNotifierProvider<
      TransactionTimelineController,
      List<Map<String, dynamic>>
    >(() {
      return TransactionTimelineController();
    });
