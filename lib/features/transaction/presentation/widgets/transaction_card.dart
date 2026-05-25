import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/cloudinary_helper.dart';
import '../../../../../l10n/app_localizations.dart'; // 💡 Đã sửa chuẩn theo dự án của bạn

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Gọi trực tiếp AppLocalizations chuẩn của Flutter
    final l10n = AppLocalizations.of(context)!;

    final String imageUrl = transaction['imageUrl'] ?? '';
    final String thumbnailUrl = CloudinaryHelper.getThumbnailUrl(imageUrl);
    final double amount = (transaction['amount'] ?? 0.0).toDouble();
    final String category = transaction['category'] ?? l10n.categoryOther;
    final String note = transaction['note'] ?? '';
    final String emoji = transaction['emoji'] ?? '📝';
    
    final String time = transaction['spentAt'] != null 
        ? transaction['spentAt'].toString().substring(11, 16)
        : '00:00';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.4), 
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '-₫${amount.toStringAsFixed(0)}',
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