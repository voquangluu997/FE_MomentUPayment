import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/cloudinary_helper.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';

class TransactionCard extends ConsumerWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(currencyProvider);
    final String formattedAmount =
        '-${CurrencyHelper.formatCompactAmount(transaction['amount'])}$currencySymbol';

    final String imageUrl = transaction['imageUrl'] ?? '';
    final String thumbnailUrl = CloudinaryHelper.getThumbnailUrl(imageUrl);
    final String category = transaction['category'] ?? l10n.categoryOther;
    final String note = transaction['note'] ?? '';
    final String emoji = transaction['emoji'] ?? '📝';

    String formattedDateTime = '--:-- - --/--/----';
    if (transaction['spentAt'] != null) {
      try {
        final DateTime parsedDate = DateTime.parse(
          transaction['spentAt'].toString(),
        ).toLocal();

        final String hour = parsedDate.hour.toString().padLeft(2, '0');
        final String minute = parsedDate.minute.toString().padLeft(2, '0');
        final String day = parsedDate.day.toString().padLeft(2, '0');
        final String month = parsedDate.month.toString().padLeft(2, '0');
        final String year = parsedDate.year.toString();

        formattedDateTime = '$hour:$minute - $day/$month/$year';
      } catch (e) {
        formattedDateTime = transaction['spentAt'].toString();
      }
    }

    // 🔑 Tự động định dạng theo quy tắc: Dưới 1M hiện 150.000đ, trên 1M hiện 2.5M
    // final String compactAmount =
    // '-${CurrencyHelper.formatCompactAmount(amount)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackIcon(emoji),
                      )
                    : _buildFallbackIcon(emoji),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.isNotEmpty ? note : l10n.emptyTransactionNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.68),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDateTime,
                      style: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.errorAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(String emoji) {
    return Container(
      width: 62,
      height: 62,
      color: AppColors.background,
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}
