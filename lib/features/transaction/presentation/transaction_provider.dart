import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import 'controllers/transaction_timeline_controller.dart';

enum TransactionState { idle, loading, success, error }

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;
  final Ref
  ref; // ✨ THÊM: Giữ biến ref để có thể clear/invalidate chéo giữa các provider
  String? errorMessage;

  TransactionNotifier(this._repository, this.ref)
    : super(TransactionState.idle);

  Future<void> addTransaction({
    required double amount,
    required String category,
    String? note,
    String? localImagePath,
    String? emoji,
  }) async {
    state = TransactionState.loading;
    try {
      String? serverImageUrl;

      if (localImagePath != null && localImagePath.isNotEmpty) {
        serverImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }

      await _repository.createTransaction(
        amount: amount,
        category: category,
        note: note,
        imageUrl: serverImageUrl,
        emoji: emoji,
      );

      // ✨ ĐÃ SỬA: Tự động xóa bộ đệm cũ, bắt buộc app phải nạp lại danh sách giao dịch mới tinh của chính user này
      ref.invalidate(transactionTimelineProvider);

      errorMessage = null;
      state = TransactionState.success;
      HapticFeedback.mediumImpact();
    } catch (e) {
      errorMessage = e.toString().contains('401')
          ? 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại bạn ơi! 🔑'
          : 'Không lưu được giao dịch rồi bạn ơi! 😢';
      state = TransactionState.error;
    }
  }

  void resetState() {
    state = TransactionState.idle;
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      final repo = ref.watch(transactionRepositoryProvider);
      return TransactionNotifier(repo, ref); // Truyền thêm ref vào đây
    });
