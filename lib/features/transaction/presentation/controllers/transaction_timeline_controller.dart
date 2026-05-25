import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/transaction_repository.dart';

class TransactionTimelineController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return _fetchTimelineData();
  }

  /// Hàm nội bộ gọi xuống Repository lấy dữ liệu thật từ Postgres
  Future<List<Map<String, dynamic>>> _fetchTimelineData() async {
    return await _repository.getTransactions();
  }

  /// Hàm public phục vụ cho tính năng "Kéo để làm mới" (Pull to Refresh) hoặc tự động reload sau khi thêm mới thành công
  Future<void> refreshTimeline() async {
    state =
        const AsyncLoading(); // Chuyển giao diện sang trạng thái đợi loading
    state = await AsyncValue.guard(
      () => _fetchTimelineData(),
    ); // Bọc an toàn dữ liệu hoặc lỗi
  }
}

/// Provider toàn cục dùng chung cho toàn App để lắng nghe danh sách dòng thời gian
final transactionTimelineProvider =
    AsyncNotifierProvider<
      TransactionTimelineController,
      List<Map<String, dynamic>>
    >(() => TransactionTimelineController());
