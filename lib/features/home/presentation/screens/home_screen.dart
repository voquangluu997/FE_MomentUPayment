import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/presentation/widgets/home_budget_card.dart';
import 'package:moment_u_payment/features/home/presentation/widgets/home_app_bar.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_details_dialog.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_grid_item.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        ref.read(transactionTimelineProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🔑 CẬP NHẬT: Hàm mở Dialog chờ tín hiệu reload từ Dialog trả về
  Future<void> _openMomentDetails(
    Map<String, dynamic> moment,
    AppLocalizations l10n,
  ) async {
    final bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (context) => MomentDetailsDialog(moment: moment, l10n: l10n),
    );

    // Nếu isUpdated == true (cập nhật thành công) -> Refresh dữ liệu
    if (isUpdated == true && mounted) {
      ref.read(transactionTimelineProvider.notifier).refreshTimeline();
    }
  }

  // 🔑 CẬP NHẬT MỚI: Bọc BudgetProgressCard và thêm nút điều hướng 🎯 vào góc trên bên phải
  Widget _buildBudgetCardWithNavigation(AppLocalizations l10n) {
    return Stack(children: [const HomeBudgetCard()]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timelineState = ref.watch(transactionTimelineProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final currentCurrency = ref.watch(currencyProvider);

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
          skipLoadingOnRefresh: true,
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
                  _buildBudgetCardWithNavigation(
                    l10n,
                  ), // 🔑 CẬP NHẬT: Thay thế BudgetProgressCard cũ
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

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: 2 + keys.length + (isLoadingMore && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0)
                  return _buildBudgetCardWithNavigation(
                    l10n,
                  ); // 🔑 CẬP NHẬT: Thay thế BudgetProgressCard cũ

                if (index == 1) {
                  return _buildHeaderSection(
                    context,
                    ref,
                    l10n,
                    currentCurrency,
                    isGridView,
                  );
                }

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
        onPressed: () async {
          // 🔑 CẬP NHẬT: Hứng kết quả từ màn hình Add
          final bool? isAdded = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (isAdded == true && mounted) {
            ref.read(transactionTimelineProvider.notifier).refreshTimeline();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

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
            physics: const NeverScrollableScrollPhysics(),
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
              onTap: () => _openMomentDetails(
                txList[gridIdx],
                l10n,
              ), // 🔑 Cập nhật gọi hàm mới
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
        onTap: () => _openMomentDetails(tx, l10n), // 🔑 Cập nhật gọi hàm mới
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
        ref
            .read(transactionTimelineProvider.notifier)
            .removeMomentLocally(tx['id'].toString()); // Refresh sau khi xóa
      } catch (e) {
        ref.read(transactionTimelineProvider.notifier).refreshTimeline();
      }
    }
  }
}
