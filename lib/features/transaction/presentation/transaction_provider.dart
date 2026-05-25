import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

enum TransactionState { idle, loading, success, error }

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;
  String? errorMessage;

  TransactionNotifier(this._repository) : super(TransactionState.idle);

  /// ✨ Hàm cốt lõi thực hiện luồng tuần tự 2 bước
  Future<void> addTransaction({
    required double amount,
    required String category,
    String? note,
    String? localImagePath, // Đường dẫn file ảnh tạm thời trên máy thật iOS
    String? emoji,
  }) async {
    state = TransactionState.loading;
    try {
      String? serverImageUrl;

      // 🔥 BƯỚC 1: Nếu người dùng có chụp ảnh, tiến hành upload lên server trước
      if (localImagePath != null && localImagePath.isNotEmpty) {
        serverImageUrl = await _repository.uploadInvoiceImage(localImagePath);
      }
      // 🔥 BƯỚC 2: Cầm đường dẫn ảnh từ server (nếu có) gửi cùng data giao dịch
      await _repository.createTransaction(
        amount: amount,
        category: category,
        note: note,
        imageUrl:
            serverImageUrl, // Đã được đồng bộ hóa thành chuỗi text lưu vào DB
        emoji: emoji,
      );

      errorMessage = null;
      state = TransactionState.success;
      HapticFeedback.mediumImpact(); // Rung phản hồi vừa phải báo hiệu tạo thành công trên iPhone cực đã
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

// Khai báo các Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      final repo = ref.watch(transactionRepositoryProvider);
      return TransactionNotifier(repo);
    });
