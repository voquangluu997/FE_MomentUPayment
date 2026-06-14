import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';
import 'badge_visual.dart'; // Import file trên

class BadgePremiumDialog extends StatelessWidget {
  final UserBadge badge;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onSecondaryPressed;
  final AppColorTheme appColors;

  const BadgePremiumDialog({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
    required this.appColors,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: badge.color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeVisual(badge: badge),
            const SizedBox(height: 28),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: appColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: appColors.textMuted),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onButtonPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
