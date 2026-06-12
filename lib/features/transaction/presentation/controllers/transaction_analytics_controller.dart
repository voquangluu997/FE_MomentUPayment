import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart'; // Import Helper
import '../../data/transaction_repository.dart';

class TransactionAnalyticsController
    extends AsyncNotifier<Map<String, dynamic>> {
  // 🔑 Khởi tạo ngày bắt đầu từ 00:00:00 (UTC) của 30 ngày trước
  DateTime _startDate = DateTimeHelper.getStartOfDayUtc(
    DateTime.now().subtract(const Duration(days: 30)),
  );

  // 🔑 Khởi tạo ngày kết thúc đến 23:59:59 (UTC) của hôm nay
  DateTime _endDate = DateTimeHelper.getEndOfDayUtc(DateTime.now());

  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<Map<String, dynamic>> build() async {
    return _fetchAnalyticsData();
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    // ⚠️ Đảm bảo repository.getTransactionAnalytics() của bạn cũng đã được
    // update kiểu trả về thành Map<String, dynamic> thay vì List<>
    return await _repository.getTransactionAnalytics(
      startDate: _startDate, // Đã chuẩn UTC
      endDate: _endDate, // Đã chuẩn UTC
    );
  }

  // 🔥 Gọi DateTimeHelper để tạo ranh giới và khóa múi giờ tự động
  Future<void> updateDateRange(DateTime start, DateTime end) async {
    _startDate = DateTimeHelper.getStartOfDayUtc(start);
    _endDate = DateTimeHelper.getEndOfDayUtc(end);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAnalyticsData());
  }

  Future<void> refreshAnalytics() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAnalyticsData());
  }
}

final transactionAnalyticsProvider =
    AsyncNotifierProvider<TransactionAnalyticsController, Map<String, dynamic>>(
      () => TransactionAnalyticsController(),
    );
