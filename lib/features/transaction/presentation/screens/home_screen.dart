import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/datetime_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/transaction_timeline_controller.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () =>
            ref.read(transactionTimelineProvider.notifier).refreshTimeline(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
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
              timelineState.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, stack) => SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      l10n.errorLoadData,
                      style: const TextStyle(color: AppColors.errorAccent),
                    ),
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty)
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.emptyTransactionList,
                          style: TextStyle(
                            color: AppColors.primaryDark.withOpacity(0.5),
                          ),
                        ),
                      ),
                    );
                  final grouped = DateTimeHelper.groupTransactionsByDate(
                    transactions,
                  );
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final txList = grouped[dateKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              ),
                            ),
                          ),
                          ...txList.map(
                            (tx) =>
                                _buildDismissibleCard(context, ref, tx, l10n),
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
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetProgressCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.06)),
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
              const LinearProgressIndicator(
                value: 0.4,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.budgetHealthyFeedback,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${l10n.analyticsTitle ?? 'Details'} ➡️',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
      },
      onDismissed: (_) async {
        try {
          await ref
              .read(transactionTimelineProvider.notifier)
              .deleteTransaction(tx['id'].toString());
        } catch (e) {
          ref.read(transactionTimelineProvider.notifier).refreshTimeline();
        }
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
        onTap: () => _showFullSizeImageDialog(
          context,
          l10n,
          tx['imageUrl'] ?? '',
          tx['note'] ?? '',
        ),
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
                CloudinaryHelper.getOptimizedOriginalUrl(imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                note.isNotEmpty ? note : l10n.emptyTransactionNote,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
