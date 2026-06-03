import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/transaction_provider.dart';
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
    // ✨ NÂNG CẤP: Sử dụng ref.watch kết hợp .select để theo dõi trạng thái Đăng nhập một cách phản xạ (Reactive)
    // Giải quyết triệt để vấn đề không tự động tải dữ liệu khi vừa đăng nhập xong,
    // đồng thời chọn lọc trả về giá trị bool giúp chặn đứng việc bị re-build 2 lần liên tiếp (khi chuyển từ loginSuccess sang authenticated).
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
    return _fetchTimelineData(page: _page, limit: _limit);
  }

  Future<List<Map<String, dynamic>>> _fetchTimelineData({
    required int page,
    required int limit,
  }) async {
    return await _repository.getTransactions(page: page, limit: limit);
  }

  /// Làm mới danh sách quay về trang đầu tiên (Dùng khi kéo vuốt RefreshIndicator hoặc gọi lại sau khi đăng nhập)
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

    // ✨ SỬA LỖI ĐỘT PHÁ (Smart-Loading):
    // - Nếu app vừa mở/vừa đăng nhập thành công và danh sách đang RỖNG (hoặc chưa có dữ liệu),
    //   ta bắt buộc phải đưa state về loading ngay lập tức để UI bật Skeleton lên, không được hiện chữ "Không có data".
    // - Ngược lại nếu người dùng đang dùng app bình thường và chủ động "kéo vuốt xuống để refresh",
    //   ta bỏ qua không ép loading để danh sách cũ giữ nguyên trên màn hình, giúp trải nghiệm mượt mà không bị chớp trắng.
    if (!state.hasValue || state.value!.isEmpty) {
      state = const AsyncValue.loading();
    }

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
