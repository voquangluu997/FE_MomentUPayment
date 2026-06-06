import 'package:flutter/material.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

class BadgeVisual extends StatelessWidget {
  final UserBadge badge;
  final double size;

  const BadgeVisual({super.key, required this.badge, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.75, // Tỷ lệ thẩm mỹ
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors:
              badge.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: badge.color.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(child: Icon(badge.icon, size: 52, color: Colors.white)),
    );
  }
}
