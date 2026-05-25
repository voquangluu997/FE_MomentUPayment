import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/datetime_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/transaction_timeline_controller.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Lắng nghe trạng thái động từ AsyncNotifierProvider
    final timelineState = ref.watch(transactionTimelineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
      // Luồng kéo để tải lại dữ liệu (Pull to Refresh)
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () =>
            ref.read(transactionTimelineProvider.notifier).refreshTimeline(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(), // Hiệu ứng kéo mượt chuẩn iOS
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetProgressCard(context, l10n),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  l10n.spendingMomentsTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),

              // Quản lý Render UI dựa theo trạng thái AsyncValue của Riverpod
              timelineState.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, stackTrace) => SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          l10n.errorLoadData,
                          style: const TextStyle(color: AppColors.errorAccent),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(transactionTimelineProvider.notifier)
                              .refreshTimeline(),
                          child: Text(
                            l10n.retryButton,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          l10n.emptyTransactionList,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryDark.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // 🧠 Sạch sẽ gọn gàng: Sử dụng Util để gom nhóm và sắp xếp dữ liệu
                  final groupedTransactions =
                      DateTimeHelper.groupTransactionsByDate(transactions);

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupedTransactions.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedTransactions.keys.elementAt(index);
                      final txList = groupedTransactions[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🗓️ Nhãn hiển thị nhóm thời gian (HÔM NAY, HÔM QUA, dd/MM/yyyy)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              top: 14,
                              bottom: 6,
                            ),
                            child: Text(
                              DateTimeHelper.getFriendlyDateLabel(dateKey),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark.withOpacity(0.45),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Danh sách card chi tiêu thuộc ngày đó
                          ...txList.map(
                            (tx) => TransactionCard(
                              transaction: tx,
                              onTap: () => _showFullSizeImageDialog(
                                context,
                                l10n,
                                tx['imageUrl'] ?? '',
                                tx['note'] ?? '',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
    );
  }

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
              value: 0.4,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.budgetHealthyFeedback,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullSizeImageDialog(
    BuildContext context,
    AppLocalizations l10n,
    String imageUrl,
    String note,
  ) {
    if (imageUrl.isEmpty) return;
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
