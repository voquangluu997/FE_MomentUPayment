import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import 'controllers/transaction_timeline_controller.dart';
import '../../../core/utils/app_logger.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';

enum TransactionState { initial, loading, success, error }

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(TransactionState.initial);

  TransactionRepository get _repository =>
      _ref.read(transactionRepositoryProvider);

  /// 🚀 HÀM MỚI: TẢI ẢNH LÊN NGẦM (BACKGROUND UPLOAD)
  Future<String?> uploadImageOnly(String localImagePath) async {
    try {
      // Gọi repository để đẩy file lên Cloudinary
      return await _repository.uploadInvoiceImage(localImagePath);
    } catch (error, stackTrace) {
      AppLogger.e('TransactionNotifier.uploadImageOnly', error, stackTrace);
      return null;
    }
  }

  /// 🚀 HÀM MỚI: XÓA ẢNH RÁC TRÊN CLOUD NẾU USER HỦY
  Future<void> deleteImage(String imageUrl) async {
    try {
      // *Lưu ý: Bạn cần thêm hàm deleteImage vào transaction_repository.dart
      // để gọi API gọi lên backend (UploadService.deleteImage)
      await _repository.deleteImage(imageUrl);
    } catch (error, stackTrace) {
      AppLogger.e('TransactionNotifier.deleteImage', error, stackTrace);
    }
  }

  /// 🌸 HÀM 1: GHI LẠI KHOẢNH KHẮC CHI TIÊU MỚI
  Future<void> addTransaction({
    required double amount,
    required String category,
    required String emoji,
    required String note,
    String? localImagePath,
    String? imageUrl, // ✨ Thêm tham số imageUrl (link đã upload ngầm)
    DateTime? spentAt,
  }) async {
    state = TransactionState.loading;
    try {
      String? finalImageUrl = imageUrl;

      // Nếu chưa có link ảnh ngầm, mà lại có ảnh local thì mới upload lại (Fallback an toàn)
      if (finalImageUrl == null &&
          localImagePath != null &&
          localImagePath.isNotEmpty) {
        finalImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }

      await _repository.createTransaction(
        amount: amount,
        category: category,
        note: note,
        emoji: emoji,
        imageUrl: finalImageUrl, // Truyền link ảnh cuối cùng
        spentAt: spentAt,
      );

      // 🔄 Làm mới dòng thời gian
      _ref.read(transactionTimelineProvider.notifier).refreshTimeline();

      // 🔄 Ép ví ngoan tính lại tiền
      _ref.invalidate(homeBudgetProvider);

      // 🟢 THẦN CHÚ: Làm mới biểu đồ thống kê ngay lập tức
      _ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();

      state = TransactionState.success;
      state = TransactionState.initial;
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
    String? imageUrl, // ✨ Thêm tham số imageUrl
    DateTime? spentAt,
  }) async {
    state = TransactionState.loading;
    try {
      String? finalImageUrl = imageUrl;

      // Tương tự, dùng làm fallback
      if (finalImageUrl == null &&
          localImagePath != null &&
          localImagePath.isNotEmpty) {
        finalImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }

      await _repository.updateTransaction(
        id: id,
        amount: amount,
        category: category,
        note: note,
        emoji: emoji,
        imageUrl: finalImageUrl,
        spentAt: spentAt,
      );

      // 🔄 Làm mới dòng thời gian và cập nhật Home Widget
      _ref.read(transactionTimelineProvider.notifier).refreshTimeline();

      // 🔄 Cập nhật ngân sách
      _ref.invalidate(homeBudgetProvider);

      // 🟢 THẦN CHÚ: Cập nhật lại số liệu biểu đồ sau khi sửa đổi thành công
      _ref.read(transactionAnalyticsProvider.notifier).refreshAnalytics();

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
// 🚀 PROVIDER DÀNH RIÊNG CHO ANALYTICS (Giữ nguyên)
// =========================================================

class TransactionAnalyticsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;

  DateTime _currentStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _currentEnd = DateTime.now();

  TransactionAnalyticsNotifier(this._ref) : super(const AsyncValue.loading());

  TransactionRepository get _repository =>
      _ref.read(transactionRepositoryProvider);

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

  Future<void> refreshAnalytics() async {
    try {
      final data = await _repository.getTransactionAnalytics(
        startDate: _currentStart,
        endDate: _currentEnd,
      );
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      AppLogger.e(
        'TransactionAnalyticsNotifier.refreshAnalytics',
        error,
        stackTrace,
      );
    }
  }
}

final transactionAnalyticsProvider =
    StateNotifierProvider<
      TransactionAnalyticsNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      return TransactionAnalyticsNotifier(ref);
    });
