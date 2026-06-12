import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_analytics_controller.dart';
import '../../data/transaction_repository.dart';

class AllSplurgesController
    extends AutoDisposeAsyncNotifier<List<SplurgeInfo>> {
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<List<SplurgeInfo>> build() async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchSplurgesData(page: _page);
  }

  Future<List<SplurgeInfo>> _fetchSplurgesData({required int page}) async {
    // Đọc ngày tháng hiện tại từ Analytics Controller
    final analyticsCtrl = ref.read(transactionAnalyticsProvider.notifier);

    return await _repository.getAllSplurges(
      startDate: analyticsCtrl.currentStartDate,
      endDate: analyticsCtrl.currentEndDate,
      page: page,
      limit: _limit,
    );
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    // Báo cho UI biết đang tải thêm để hiện vòng xoay
    if (state.hasValue) state = AsyncValue.data([...state.value!]);

    try {
      final nextPage = _page + 1;
      final newData = await _fetchSplurgesData(page: nextPage);

      if (newData.isEmpty || newData.length < _limit) {
        _hasMore = false;
      }

      if (newData.isNotEmpty) {
        _page = nextPage;
        if (state.hasValue) {
          state = AsyncValue.data([...state.value!, ...newData]);
        }
      }
    } catch (e, stack) {
      AppLogger.e('AllSplurgesController.loadNextPage', e, stack);
    } finally {
      _isLoadingMore = false;
      if (state.hasValue) state = AsyncValue.data([...state.value!]);
    }
  }
}

// Dùng AutoDispose để dữ liệu tự xoá khi user đóng màn hình See All
final allSplurgesProvider =
    AsyncNotifierProvider.autoDispose<AllSplurgesController, List<SplurgeInfo>>(
      () {
        return AllSplurgesController();
      },
    );
