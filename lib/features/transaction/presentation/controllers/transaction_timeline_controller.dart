import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/core/services/home_widget_service.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_analytics_controller.dart';
import '../../data/transaction_repository.dart';

// 🚀 BỔ SUNG IMPORT: Service quản lý Huy hiệu
import 'package:moment_u_payment/core/features/badges/badge_service.dart';

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
      final budgetSummary = await ref
          .read(homeBudgetProvider.future)
          // ignore: invalid_return_type_for_catch_error
          .catchError((_) => null);

      final totalBudget = budgetSummary.budgetLimit.toDouble();
      final totalSpent = budgetSummary.totalSpent.toDouble();
      final remaining = totalBudget - totalSpent;

      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final daysRemaining = lastDayOfMonth.day - now.day;

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

  // 🚀 BỔ SUNG: Hàm chạy ngầm để tính toán huy hiệu dựa trên dữ liệu hiện tại
  Future<void> _evaluateBadges(List<Map<String, dynamic>> currentData) async {
    try {
      // 1. Lấy tổng tiền đã chi trong tháng từ provider ngân sách
      final budgetSummary = await ref
          .read(homeBudgetProvider.future)
          // ignore: invalid_return_type_for_catch_error
          .catchError((_) => null);
      final thisMonthTotal = budgetSummary.totalSpent.toDouble();

      // 2. Lọc ra các giao dịch của tháng này từ danh sách timeline
      final now = DateTime.now();
      final thisMonthData = currentData.where((tx) {
        // Tùy theo field backend trả về (spentAt, dateTime, createdAt)
        final dateStr = tx['spentAt'] ?? tx['dateTime'] ?? tx['createdAt'];
        if (dateStr == null) return false;

        final date = DateTime.tryParse(dateStr.toString()) ?? now;
        return date.year == now.year && date.month == now.month;
      }).toList();

      // 3. Kích hoạt xét duyệt (Badge Service tự so sánh và trigger UI nếu có huy hiệu mới)
      ref
          .read(badgeServiceProvider.notifier)
          .evaluateTransactions(
            currentData, // allTimeData
            thisMonthData, // thisMonthData
            thisMonthTotal, // thisMonthTotalSpent
          );
    } catch (e, stack) {
      AppLogger.e('TransactionTimelineController._evaluateBadges', e, stack);
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

    _syncHomeWidget();

    // 🚀 BỔ SUNG: Đánh giá huy hiệu khi vừa tải xong dữ liệu mở app
    _evaluateBadges(initialData);

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

      _syncHomeWidget();

      // 🚀 BỔ SUNG: Đánh giá huy hiệu lại sau khi người dùng kéo thả refresh
      _evaluateBadges(refreshedData);

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

      _syncHomeWidget();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    // Kích hoạt UI hiển thị vòng xoay
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
          final updatedData = [...state.value!, ...newTransactions];
          state = AsyncValue.data(updatedData);

          _syncHomeWidget();

          // 🚀 BỔ SUNG: Khi tải thêm page mới (có thể đạt mốc 100 tx) thì quét lại
          _evaluateBadges(updatedData);
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

      // 🚀 BƯỚC QUYẾT ĐỊNH: Bắt buộc ép Riverpod cập nhật lại state một lần nữa
      // để UI nhận diện được `_isLoadingMore` đã biến thành false và giấu vòng xoay đi.
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!]);
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    final previousState = state;
    if (!state.hasValue) return;

    final currentList = state.value!;
    final updatedList = currentList
        .where((tx) => tx['id'].toString() != id)
        .toList();
    state = AsyncValue.data(updatedList);

    try {
      await _repository.deleteTransaction(id);

      ref.invalidate(homeBudgetProvider);
      ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();

      _syncHomeWidget();

      // 🚀 BỔ SUNG: Quét lại vì ngân sách và data đã thay đổi do bị xóa
      _evaluateBadges(updatedList);
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
