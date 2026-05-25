import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart'; //

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Dữ liệu mẫu mô phỏng cấu trúc trả về từ API NestJS & Postgres
  final List<Map<String, dynamic>> _dummyTransactions = [
    {
      'id': '1',
      'amount': 45000,
      'category': 'Food',
      'note': 'Ăn tối bún đậu mắm tôm cùng team dev',
      'emoji': '🍔',
      'imageUrl':
          'https://res.cloudinary.com/demo/image/upload/v123456/moment_u_payment/sample1.jpg',
      'spentAt': '2026-05-25 19:15:00',
    },
    {
      'id': '2',
      'amount': 35000,
      'category': 'Coffee',
      'note': 'Ly Latte đá cho ngày làm việc tỉnh táo',
      'emoji': '☕',
      'imageUrl':
          'https://res.cloudinary.com/demo/image/upload/v123456/moment_u_payment/sample2.jpg',
      'spentAt': '2026-05-25 08:30:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Khởi tạo đối tượng đa ngôn ngữ hệ thống
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background, // Nền kem sữa Pastel ngọt ngào
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.background,
              child: Text('👋', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeGreetingDeveloper,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.homeSubGreeting,
                  style: TextStyle(
                    color: AppColors.primaryDark.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primaryDark,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 1. Tiến độ hạn mức chi tiêu (Thanh màu Trà sữa, feedback màu Xanh Sage)
            _buildBudgetProgressCard(context, l10n),

            // 📅 2. Tiêu đề danh sách dòng thời gian chi tiêu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.spendingMomentsTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),

            // ☕ 3. Danh sách dòng thời gian Timeline chi tiết
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dummyTransactions.length,
              itemBuilder: (context, index) {
                final tx = _dummyTransactions[index];
                return TransactionCard(
                  transaction: tx,
                  onTap: () => _showFullSizeImageDialog(
                    context,
                    l10n,
                    tx['imageUrl'] ?? '',
                    tx['note'] ?? '',
                  ),
                );
              },
            ),
            const SizedBox(height: 100), // Khoảng đệm an toàn tránh đè nút FAB
          ],
        ),
      ),

      // ➕ NÚT BẤM NỔI FAB: Điều hướng chuẩn gốc xếp chồng màn hình
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary, // Màu nâu trà sữa chủ đạo
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          // Thực hiện push màn hình AddTransaction lên trên Stack
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
    );
  }

  /// Khung hiển thị tiến độ Hạn mức chi tiêu
  Widget _buildBudgetProgressCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.budgetThisMonthLabel,
            style: TextStyle(
              color: AppColors.primaryDark.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.budgetRemainingStatus,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.4, // Giả lập đã chi tiêu 40%
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.budgetHealthyFeedback,
            style: const TextStyle(
              color: AppColors.success, // Xanh Sage chữa lành
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Pop-up hiển thị ảnh hóa đơn đầy đủ ở chất lượng tối ưu hóa
  void _showFullSizeImageDialog(
    BuildContext context,
    AppLocalizations l10n,
    String imageUrl,
    String note,
  ) {
    if (imageUrl.isEmpty) return;

    // Tự động chèn tham số f_auto,q_auto nén nhẹ ảnh gốc từ Cloudinary CDN
    final optimizedUrl = CloudinaryHelper.getOptimizedOriginalUrl(imageUrl);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.network(
                optimizedUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                note.isNotEmpty ? note : l10n.emptyTransactionNote,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
