import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/transaction_provider.dart'; // 🟢 Thêm để gọi làm mới Analytics
import '../../../../core/utils/app_logger.dart';
import '../../data/transaction_repository.dart';

class TransactionTimelineController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  // 🔑 CÁC BIẾN QUẢN LÝ PHÂN TRANG (PAGINATION)
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    // 🟢 SỬA TẠI ĐÂY: Đổi sang ref.read để tránh bị re-build trùng lặp 2 lần khi Auth đổi trạng thái
    final authState = ref.read(authProvider);

    if (authState != AuthState.authenticated &&
        authState != AuthState.loginSuccess) {
      _page = 1;
      _hasMore = false;
      _isLoadingMore = false;
      return [];
    }

    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchTimelineData(page: _page, limit: _limit);
  }

  Future<List<Map<String, dynamic>>> _fetchTimelineData({
    required int page,
    required int limit,
  }) async {
    return await _repository.getTransactions(page: page, limit: limit);
  }

  /// Làm mới danh sách quay về trang đầu tiên (Dùng khi kéo vuốt RefreshIndicator)
  Future<void> refreshTimeline() async {
    final authState = ref.read(authProvider);
    if (authState != AuthState.authenticated &&
        authState != AuthState.loginSuccess)
      return;

    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    // 🟢 ĐÃ XÓA dòng ép State loading nặng ở đây để trải nghiệm vuốt kéo mượt mà hơn
    state = await AsyncValue.guard(
      () => _fetchTimelineData(page: _page, limit: _limit),
    );
  }

  void removeMomentLocally(String id) {
    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList
          .where((moment) => moment['id'] != id)
          .toList();
      state = AsyncValue.data(updatedList);
    }
  }

  /// Tải trang kế tiếp khi kéo xuống gần đáy màn hình
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    // 🟢 SỬA TẠI ĐÂY: Dùng toán tử spread [...] tạo mảng mới để kích hoạt UI vẽ lại vòng xoáy loading đáy màn hình
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
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!]);
      }
    }
  }

  /// 🔥 HÀM XỬ LÝ SỰ KIỆN XÓA GIAO DỊCH (Optimistic UI)
  Future<void> deleteTransaction(String id) async {
    final previousState = state;
    if (!state.hasValue) return;

    final currentList = state.value!;

    state = AsyncValue.data(
      currentList.where((tx) => tx['id'].toString() != id).toList(),
    );

    try {
      await _repository.deleteTransaction(id);
      ref.invalidate(homeBudgetProvider);

      // 🟢 THẦN CHÚ: Ép biểu đồ cập nhật lại số liệu sau khi xóa thành công
      ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();
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
