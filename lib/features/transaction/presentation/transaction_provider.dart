import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import 'controllers/transaction_timeline_controller.dart';
import '../../../core/utils/app_logger.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';

// Định nghĩa các trạng thái
enum TransactionState { initial, loading, success, error }

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(TransactionState.initial);

  TransactionRepository get _repository =>
      _ref.read(transactionRepositoryProvider);

  /// 🌸 HÀM 1: GHI LẠI KHOẢNH KHẮC CHI TIÊU MỚI
  Future<void> addTransaction({
    required double amount,
    required String category,
    required String emoji,
    required String note,
    String? localImagePath,
  }) async {
    state = TransactionState.loading;
    try {
      String? uploadedImageUrl;

      if (localImagePath != null && localImagePath.isNotEmpty) {
        uploadedImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }

      await _repository.createTransaction(
        amount: amount,
        category: category,
        note: note,
        emoji: emoji,
        imageUrl: uploadedImageUrl,
      );

      // Cập nhật lại list ở màn hình chính sau khi thêm
      _ref.read(transactionTimelineProvider.notifier).refreshTimeline();

      // ✨ THẦN CHÚ: Ép ví ngoan tính lại tiền đã tiêu tức thì!
      _ref.invalidate(homeBudgetProvider);

      state = TransactionState.success;
      state = TransactionState.initial; // Reset về ban đầu để tránh state cũ
    } catch (error, stackTrace) {
      AppLogger.e('TransactionNotifier.addTransaction', error, stackTrace);
      state = TransactionState.error;
    }
  }

  /// 🌸 HÀM 2: CẬP NHẬT KHOẢNH KHẮC CŨ
  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String category,
    required String emoji,
    required String note,
    String? localImagePath,
  }) async {
    state = TransactionState.loading;
    try {
      String? uploadedImageUrl;

      if (localImagePath != null && localImagePath.isNotEmpty) {
        uploadedImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }

      await _repository.updateTransaction(
        id: id,
        amount: amount,
        category: category,
        note: note,
        emoji: emoji,
        imageUrl: uploadedImageUrl,
      );

      // Cập nhật lại list ở màn hình chính sau khi sửa
      _ref.read(transactionTimelineProvider.notifier).refreshTimeline();

      // ✨ THẦN CHÚ: Ép ví ngoan tính lại tiền đã tiêu tức thì!
      _ref.invalidate(homeBudgetProvider);

      state = TransactionState.success;
      state = TransactionState.initial;
    } catch (error, stackTrace) {
      AppLogger.e('TransactionNotifier.updateTransaction', error, stackTrace);
      state = TransactionState.error;
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref);
    });

// =========================================================
// 🚀 THÊM MỚI TỪ ĐÂY: PROVIDER DÀNH RIÊNG CHO ANALYTICS
// =========================================================

class TransactionAnalyticsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;

  // Lưu giữ khoảng thời gian đang xem để dùng cho chức năng "Kéo xuống làm mới" (Pull to refresh)
  DateTime _currentStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _currentEnd = DateTime.now();

  TransactionAnalyticsNotifier(this._ref) : super(const AsyncValue.loading());

  TransactionRepository get _repository =>
      _ref.read(transactionRepositoryProvider);

  /// 🌸 HÀM: Lấy dữ liệu biểu đồ theo ngày
  Future<void> fetchByDateRange(DateTime start, DateTime end) async {
    _currentStart = start;
    _currentEnd = end;
    state = const AsyncValue.loading();

    try {
      final data = await _repository.getTransactionAnalytics(
        startDate: start,
        endDate: end,
      );
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      AppLogger.e(
        'TransactionAnalyticsNotifier.fetchByDateRange',
        error,
        stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 🌸 HÀM: Kéo xuống để làm mới dữ liệu (Refresh)
  Future<void> refreshAnalytics() async {
    await fetchByDateRange(_currentStart, _currentEnd);
  }
}

// ✨ THẦN CHÚ: Provider cung cấp dữ liệu cho màn hình biểu đồ
final transactionAnalyticsProvider =
    StateNotifierProvider<
      TransactionAnalyticsNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      return TransactionAnalyticsNotifier(ref);
    });
