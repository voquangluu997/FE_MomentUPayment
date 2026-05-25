import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/transaction_repository.dart';

class TransactionAnalyticsController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return _fetchAnalyticsData();
  }

  /// Hàm nội bộ thực hiện kéo dữ liệu từ Repository về
  Future<List<Map<String, dynamic>>> _fetchAnalyticsData() async {
    return await _repository.getTransactionAnalytics();
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
