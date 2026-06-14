import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TimelineHeader extends StatelessWidget {
  final String dateLabel;
  final AppColorTheme appColors;

  const TimelineHeader({
    super.key,
    required this.dateLabel,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: appColors.primaryDark,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2.0, // Độ dày đường kẻ
            width: 40, // Độ dài đường kẻ
            decoration: BoxDecoration(
              color: appColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
