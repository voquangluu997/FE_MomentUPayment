import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/core/utils/category_helper.dart'; 

// Provider lưu trữ ID của danh mục đang được lọc (null = Tất cả)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 🚀 PROVIDER MỚI: Nơi xử lý logic lọc (Filter)
final filteredTransactionsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((
  ref,
) {
  // 1. Lắng nghe dữ liệu gốc từ Timeline
  final timelineState = ref.watch(transactionTimelineProvider);

  // 2. Lắng nghe ID danh mục đang được chọn trên Filter Bar
  final selectedCategory = ref.watch(selectedCategoryProvider);

  // 3. Thực hiện lọc dữ liệu khi timelineState đã có data (khi đang loading hoặc error thì giữ nguyên state đó)
  return timelineState.whenData((transactions) {
    // Nếu chọn "All" (null) -> Trả về danh sách gốc
    if (selectedCategory == null) {
      return transactions;
    }

    // Nếu chọn "Custom/Khác" -> Lọc ra các giao dịch tự nhập (KHÔNG nằm trong list mặc định)
    if (selectedCategory == CategoryHelper.idCustom) {
      return transactions.where((tx) {
        final category = tx['category']?.toString() ?? '';
        return !CategoryHelper.isStandardCategory(category);
      }).toList();
    }

    // Lọc theo các danh mục chuẩn (Food, Shopping, Transport, Entertainment...)
    return transactions.where((tx) {
      final category = tx['category']?.toString() ?? '';
      return category == selectedCategory;
    }).toList();
  });
});
