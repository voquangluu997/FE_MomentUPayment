import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/transaction_repository.dart';

class TransactionAnalyticsController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  // 🔑 BƯỚC 1: Thêm 2 biến lưu trữ khoảng thời gian đang chọn (Mặc định là 30 ngày gần đây)
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    // Khi màn hình Analytics được mở lên lần đầu, nó sẽ tự động chạy hàm này
    return _fetchAnalyticsData();
  }

  /// Hàm nội bộ thực hiện kéo dữ liệu từ Repository về
  Future<List<Map<String, dynamic>>> _fetchAnalyticsData() async {
    // 🛠️ BƯỚC 2: Đã truyền startDate và endDate vào đúng như Repository yêu cầu
    return await _repository.getTransactionAnalytics(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// 🔥 BƯỚC 3: Hàm mới cho phép UI gọi khi người dùng bấm chọn một khoảng ngày khác trên lịch
  Future<void> updateDateRange(DateTime start, DateTime end) async {
    _startDate = start;
    _endDate = end;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAnalyticsData());
  }

  /// 🔥 Hàm public cho phép người dùng kéo màn hình để làm mới biểu đồ (Pull-to-Refresh)
  Future<void> refreshAnalytics() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAnalyticsData());
  }
}

/// 🔥 Provider toàn cục cung cấp trạng thái dữ liệu biểu đồ cho UI
final transactionAnalyticsProvider =
    AsyncNotifierProvider<
      TransactionAnalyticsController,
      List<Map<String, dynamic>>
    >(() => TransactionAnalyticsController());
