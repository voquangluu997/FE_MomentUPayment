import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/transaction_repository.dart';

class TransactionTimelineController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  // 🔑 CÁC BIẾN QUẢN LÝ PHÂN TRANG (PAGINATION)
  int _page = 1;
  final int _limit = 20; // Mỗi lượt bốc 20 moments từ NestJS lên
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Cung cấp các Getter công khai để giao diện HomeScreen có thể lắng nghe trạng thái bận
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    // Khởi tạo/Khôi phục lại cấu hình phân trang gốc khi khởi tạo Provider
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchTimelineData(page: _page, limit: _limit);
  }

  /// 🔑 CẬP NHẬT: Thêm tham số page và limit để đồng bộ tham số xuống Repository
  Future<List<Map<String, dynamic>>> _fetchTimelineData({
    required int page,
    required int limit,
  }) async {
    // Đảm bảo hàm getTransactions của Repository nhận thêm page và limit truyền đi
    return await _repository.getTransactions(page: page, limit: limit);
  }

  /// Làm mới danh sách quay về trang đầu tiên (Dùng khi kéo vuốt RefreshIndicator)
  Future<void> refreshTimeline() async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchTimelineData(page: _page, limit: _limit),
    );
  }

  void removeMomentLocally(String id) {
    if (state.hasValue) {
      final currentList = state.value!;
      // Lọc bỏ moment có ID vừa xóa
      final updatedList = currentList
          .where((moment) => moment['id'] != id)
          .toList();

      // Gán thẳng data mới vào state, UI sẽ tự vẽ lại êm ru
      state = AsyncValue.data(updatedList);
    }
  }

  /// 🔑 HÀM MỚI: Tải trang kế tiếp khi người dùng kéo xuống gần chạm đáy màn hình
  Future<void> loadNextPage() async {
    // Ngăn chặn gọi lặp lại nếu đang bận tải hoặc server thông báo đã hết sạch dữ liệu
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    // Gạt nhẹ trạng thái cũ để UI nhận biết và kích hoạt hiển thị vòng xoáy Loading ở đáy
    if (state.hasValue) {
      state = AsyncValue.data(state.value!);
    }

    try {
      final nextPage = _page + 1;
      final newTransactions = await _fetchTimelineData(
        page: nextPage,
        limit: _limit,
      );

      // Nếu số lượng data lấy về rỗng hoặc ít hơn limit -> Server đã hết dữ liệu cho các trang sau
      if (newTransactions.isEmpty || newTransactions.length < _limit) {
        _hasMore = false;
      }

      if (newTransactions.isNotEmpty) {
        _page = nextPage;
        // 🔑 Nối đuôi mảng dữ liệu mới bốc về vào sau danh sách đang có trên RAM
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
      // Giữ nguyên dữ liệu cũ, không làm sập giao diện khi lỗi mạng đột xuất lúc phân trang
    } finally {
      _isLoadingMore = false;
      // Thông báo cập nhật để ẩn vòng xoáy Loading ở đáy màn hình
      if (state.hasValue) {
        state = AsyncValue.data(state.value!);
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

// Khai báo định danh Provider hệ thống
final transactionTimelineProvider =
    AsyncNotifierProvider<
      TransactionTimelineController,
      List<Map<String, dynamic>>
    >(() {
      return TransactionTimelineController();
    });
