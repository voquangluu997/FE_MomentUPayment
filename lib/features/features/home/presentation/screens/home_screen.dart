import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/providers/currency_provider.dart';
import 'package:frontend/core/utils/datetime_helper.dart';
import 'package:frontend/features/features/home/presentation/widgets/budget_progress_card.dart';
import 'package:frontend/features/features/home/presentation/widgets/home_app_bar.dart';
import 'package:frontend/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:frontend/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:frontend/features/transaction/presentation/widgets/moment_details_dialog.dart';
import 'package:frontend/features/transaction/presentation/widgets/moment_grid_item.dart';
import 'package:frontend/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:frontend/l10n/app_localizations.dart';

final isGridViewProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 🔑 LẮNG NGHE SỰ KIỆN CUỘN: Khi user kéo gần xuống cuối trang (cách đáy 150px)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        // Gọi hàm load trang tiếp theo từ Notifier của bạn
        ref.read(transactionTimelineProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Giải phóng bộ nhớ tránh leak RAM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timelineState = ref.watch(transactionTimelineProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final currentCurrency = ref.watch(currencyProvider);

    // 🔑 Trích xuất trạng thái bổ trợ từ Notifier (Ví dụ: đang load thêm, còn dữ liệu không)
    final timelineNotifier = ref.watch(transactionTimelineProvider.notifier);
    final isLoadingMore = timelineNotifier.isLoadingMore;
    final hasMore = timelineNotifier.hasMore;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () =>
            ref.read(transactionTimelineProvider.notifier).refreshTimeline(),
        child: timelineState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Text(
              l10n.errorLoadData,
              style: const TextStyle(color: AppColors.errorAccent),
            ),
          ),
          data: (transactions) {
            // Phân nhóm dữ liệu sẵn để hiển thị theo cơ chế Lazy Render
            final monthlyGrouped = DateTimeHelper.groupMomentsByMonth(
              transactions,
              l10n,
            );
            final dailyGrouped = DateTimeHelper.groupTransactionsByDate(
              transactions,
            );
            final keys = isGridView
                ? monthlyGrouped.keys.toList()
                : dailyGrouped.keys.toList();

            if (transactions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  const BudgetProgressCard(),
                  _buildHeaderSection(
                    context,
                    ref,
                    l10n,
                    currentCurrency,
                    isGridView,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        l10n.emptyTransactionList,
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 🔑 GIẢI PHÁP LAG: Gom toàn bộ màn hình vào 1 ListView duy nhất. Không dùng shrinkWrap bên ngoài nữa.
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              // Tổng item = 1 (Card) + 1 (Header) + Số lượng nhóm ngày/tháng + 1 (Nút xoay load more nếu có)
              itemCount: 2 + keys.length + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Vị trí 0: Thẻ hạn mức ngân sách
                if (index == 0) return const BudgetProgressCard();

                // Vị trí 1: Tiêu đề "Spending Moments" & Bộ lọc
                if (index == 1) {
                  return _buildHeaderSection(
                    context,
                    ref,
                    l10n,
                    currentCurrency,
                    isGridView,
                  );
                }

                // Vị trí cuối cùng: Hiển thị vòng xoay Loading khi đang tải trang tiếp theo dưới nền
                if (index == 2 + keys.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                // Các vị trí ở giữa: Render các cụm danh sách giao dịch một cách tuần tự (Lazy)
                final dataIndex = index - 2;
                final groupKey = keys[dataIndex];

                if (isGridView) {
                  final txList = monthlyGrouped[groupKey]!;
                  return _buildGridGroup(groupKey, txList, l10n, ref, context);
                } else {
                  final txList = dailyGrouped[groupKey]!;
                  return _buildListGroup(groupKey, txList, l10n, ref, context);
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Tách Widget Header để gọn code chính
  Widget _buildHeaderSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String currentCurrency,
    bool isGridView,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.spendingMomentsTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentCurrency,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                  items: ['₫', '\$', '€', '¥'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      ref.read(currencyProvider.notifier).setCurrency(newValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                onPressed: () =>
                    ref.read(isGridViewProvider.notifier).state = !isGridView,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tách cụm render List theo từng ngày độc lập
  Widget _buildListGroup(
    String dateKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
          child: Text(
            DateTimeHelper.getFriendlyDateLabel(dateKey, l10n),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        ...txList.map((tx) => _buildDismissibleCard(context, ref, tx, l10n)),
      ],
    );
  }

  // Tách cụm render Grid theo từng tháng độc lập
  Widget _buildGridGroup(
    String monthKey,
    List<Map<String, dynamic>> txList,
    AppLocalizations l10n,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
          child: Text(
            monthKey,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark.withOpacity(0.45),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Vẫn giữ vì cụm tháng nhỏ, ListView cha sẽ lo cuộn tổng thể
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemCount: txList.length,
            itemBuilder: (context, gridIdx) => MomentGridItem(
              moment: txList[gridIdx],
              l10n: l10n,
              onLongPress: () =>
                  _showDeleteConfirmDialog(context, ref, txList[gridIdx], l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tx,
    AppLocalizations l10n,
  ) {
    return Dismissible(
      key: Key(tx['id'].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await _showDeleteConfirmDialog(context, ref, tx, l10n);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.errorAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep, color: AppColors.errorAccent),
      ),
      child: TransactionCard(
        transaction: tx,
        onTap: () => showDialog(
          context: context,
          builder: (context) => MomentDetailsDialog(moment: tx, l10n: l10n),
        ),
        l10n: l10n,
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tx,
    AppLocalizations l10n,
  ) async {
    final isConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteDialogTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.deleteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.deleteDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteDialogConfirm,
              style: const TextStyle(color: AppColors.errorAccent),
            ),
          ),
        ],
      ),
    );

    if (isConfirm == true) {
      try {
        await ref
            .read(transactionTimelineProvider.notifier)
            .deleteTransaction(tx['id'].toString());
      } catch (e) {
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
      }
    }
  }
}
