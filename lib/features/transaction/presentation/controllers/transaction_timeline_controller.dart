import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/transaction_repository.dart';

class TransactionTimelineController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return _fetchTimelineData();
  }

  Future<List<Map<String, dynamic>>> _fetchTimelineData() async {
    return await _repository.getTransactions();
  }

  Future<void> refreshTimeline() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTimelineData());
  }

  /// 🔥 HÀM XỬ LÝ SỰ KIỆN XÓA GIAO DỊCH (Optimistic UI)
  Future<void> deleteTransaction(String id) async {
    // 1. Lưu lại trạng thái danh sách hiện tại phòng trường hợp lỗi mạng thì khôi phục
    final previousState = state;
    if (!state.hasValue) return;

    final currentList = state.value!;

    // 2. Cập nhật UI ngay lập tức bằng cách lọc bỏ phần tử vừa xóa
    state = AsyncValue.data(
      currentList.where((tx) => tx['id'].toString() != id).toList(),
    );

    try {
      // 3. Bắn lệnh DELETE lên Server NestJS
      await _repository.deleteTransaction(id);
    } catch (error, stackTrace) {
      // 4. Nếu lỗi (Token hết hạn, mất mạng...), log lỗi và khôi phục lại danh sách cũ
      AppLogger.e(
        'TransactionTimelineController.deleteTransaction',
        error,
        stackTrace,
      );
      state = previousState;
      rethrow; // Bắn lỗi ra ngoài để UI hiển thị SnackBar thông báo
    }
  }
}

final transactionTimelineProvider =
    AsyncNotifierProvider<
      TransactionTimelineController,
      List<Map<String, dynamic>>
    >(() => TransactionTimelineController());
