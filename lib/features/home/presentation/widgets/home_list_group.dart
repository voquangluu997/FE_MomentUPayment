import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // 🚀 Import animation
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/transaction/presentation/widgets/moment_list_item.dart';

class HomeListGroup extends StatelessWidget {
  final String dateKey;
  final List<Map<String, dynamic>> txList;
  final AppLocalizations l10n;
  final AppColorTheme appColors;
  final Function(Map<String, dynamic>) onTapItem;
  final Future<bool> Function(Map<String, dynamic>) onConfirmDelete;

  const HomeListGroup({
    super.key,
    required this.dateKey,
    required this.txList,
    required this.l10n,
    required this.appColors,
    required this.onTapItem,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // Tiêu đề ngày dạng Text hoa
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 20, bottom: 12),
            child: Text(
              DateTimeHelper.getFriendlyDateLabel(dateKey, l10n).toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: appColors.primaryDark.withOpacity(0.4),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),

        // Danh sách các item
        SliverList(
          delegate: SliverChildBuilderDelegate((context, idx) {
            final tx = txList[idx];

            // Hiệu ứng bay vào mượt mà
            return AnimationConfiguration.staggeredList(
              position: idx,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MomentListItem(
                      transaction: tx,
                      l10n: l10n,
                      appColors: appColors,
                      onTap: () => onTapItem(tx),
                      onConfirmDelete: () async {
                        return await onConfirmDelete(tx);
                      },
                    ),
                  ),
                ),
              ),
            );
          }, childCount: txList.length),
        ),
      ],
    );
  }
}
