import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_grid_item.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';

class HomeGridGroup extends StatelessWidget {
  final String dateKey;
  final List<Map<String, dynamic>> txList;
  final AppLocalizations l10n;
  final AppColorTheme appColors;
  final Function(Map<String, dynamic>) onTapItem;
  final Function(Map<String, dynamic>) onLongPress;

  const HomeGridGroup({
    super.key,
    required this.dateKey,
    required this.txList,
    required this.l10n,
    required this.appColors,
    required this.onTapItem,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: appColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    DateTimeHelper.getFriendlyDateLabel(dateKey, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate((context, gridIdx) {
              final tx = txList[gridIdx];
              return AnimationConfiguration.staggeredGrid(
                position: gridIdx,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutCubic,
                  child: FadeInAnimation(
                    child: MomentGridItem(
                      moment: tx,
                      l10n: l10n,
                      onLongPress: () => onLongPress(tx),
                      onTap: () => onTapItem(tx),
                    ),
                  ),
                ),
              );
            }, childCount: txList.length),
          ),
        ),
      ],
    );
  }
}
