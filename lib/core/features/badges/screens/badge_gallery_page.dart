import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/features/badges/widgets/badge_premium_dialog.dart';
import 'package:moment_u_payment/core/utils/gamification_utils.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';

final badgeProgressProvider = Provider<Map<BadgeType, double>>((ref) {
  final allTransactions = ref.watch(transactionTimelineProvider).value ?? [];
  final now = DateTime.now();
  final monthlyTransactions = allTransactions.where((tx) {
    final dateStr = tx['spentAt'] ?? tx['dateTime'] ?? tx['createdAt'];
    if (dateStr == null) return false;
    final date = DateTime.tryParse(dateStr.toString()) ?? now;
    return date.year == now.year && date.month == now.month;
  }).toList();

  final budgetSummary = ref.watch(homeBudgetProvider).value;
  final monthlyTotalSpent = budgetSummary?.totalSpent.toDouble() ?? 0.0;

  return GamificationUtils.calculateBadgeProgress(
    allTransactions,
    monthlyTransactions,
    monthlyTotalSpent,
  );
});

class BadgeGalleryPage extends ConsumerWidget {
  const BadgeGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    final unlockedBadges = ref.watch(unlockedBadgesProvider);
    final badgeProgressMap = ref.watch(badgeProgressProvider);

    final List<UserBadge> sortedBadges = List.from(GamificationUtils.allBadges)
      ..sort((a, b) {
        final bool isAUnlocked = unlockedBadges.contains(a.type);
        final bool isBUnlocked = unlockedBadges.contains(b.type);

        if (isAUnlocked && !isBUnlocked) return -1;
        if (!isAUnlocked && isBUnlocked) return 1;

        final double progressA = badgeProgressMap[a.type] ?? 0.0;
        final double progressB = badgeProgressMap[b.type] ?? 0.0;
        return progressB.compareTo(progressA);
      });

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.badgeTabTitle,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: appColors.primaryDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_back, color: appColors.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: sortedBadges.length,
        itemBuilder: (context, index) {
          final badge = sortedBadges[index];
          final isUnlocked = unlockedBadges.contains(badge.type);
          final double progress = badgeProgressMap[badge.type] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BadgeRectangularCard(
              badge: badge,
              isUnlocked: isUnlocked,
              progress: progress,
              l10n: l10n,
              appColors: appColors,
            ),
          );
        },
      ),
    );
  }
}

class _BadgeRectangularCard extends StatefulWidget {
  final UserBadge badge;
  final bool isUnlocked;
  final double progress;
  final AppLocalizations l10n;
  final AppColorTheme appColors;

  const _BadgeRectangularCard({
    required this.badge,
    required this.isUnlocked,
    required this.progress,
    required this.l10n,
    required this.appColors,
  });

  @override
  State<_BadgeRectangularCard> createState() => _BadgeRectangularCardState();
}

class _BadgeRectangularCardState extends State<_BadgeRectangularCard>
    with TickerProviderStateMixin {
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sheenAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _sheenController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutBack),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    if (widget.isUnlocked) {
      _sheenController.repeat();
    } else {
      _pulseController.repeat(reverse: true);
      _shakeController.repeat();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // 🌟 HÀM TRUY XUẤT MẬT THƯ THEO TỪNG LOẠI HUY HIỆU
  String _getBadgeHint() {
    try {
      switch (widget.badge.type) {
        case BadgeType.firstBlood:
          return widget.l10n.hintFirstBlood;
        case BadgeType.centurion:
          return widget.l10n.hintCenturion;
        case BadgeType.ghost:
          return widget.l10n.hintGhost;
        case BadgeType.bigTicket:
          return widget.l10n.hintBigTicket;
        case BadgeType.paydayFlash:
          return widget.l10n.hintPaydayFlash;
        case BadgeType.nightOwl:
          return widget.l10n.hintNightOwl;
        case BadgeType.weekendStorm:
          return widget.l10n.hintWeekendStorm;
        case BadgeType.shopaholic:
          return widget.l10n.hintShopaholic;
        case BadgeType.whale:
          return widget.l10n.hintWhale;
        case BadgeType.survivalist:
          return widget.l10n.hintSurvivalist;
        case BadgeType.foodDestroyer:
          return widget.l10n.hintFoodDestroyer;
        case BadgeType.brokeAF:
          return widget.l10n.hintBrokeAF;
        case BadgeType.goldfish:
          return widget.l10n.hintGoldfish;
        case BadgeType.balanced:
          return widget.l10n.hintBalanced;
        default:
          return widget.l10n.hintDefault;
      }
    } catch (e) {
      // Fallback khi file gen-l10n chưa kịp update
      return "Mật thư: Bí mật đang chờ đợi những người kiên nhẫn khám phá...";
    }
  }

  // 🌟 PROGRESS BAR VỚI GRADIENT HÀI HÒA VÀ SANG TRỌNG
  Widget _buildHarmoniousProgressBar() {
    const Color lockedAuraColor = Color(0xFF8A2BE2);
    final int percent = (widget.progress.clamp(0.0, 1.0) * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08), // Màu nền tinh tế
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        lockedAuraColor.withOpacity(0.4),
                        lockedAuraColor,
                        Colors.white.withOpacity(0.85), // Phát sáng ở đầu thanh
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lockedAuraColor.withOpacity(
                          (0.4 + 0.4 * _pulseAnimation.value).clamp(0.0, 1.0),
                        ),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$percent%",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: lockedAuraColor.withOpacity(
                (0.7 + 0.3 * _pulseAnimation.value).clamp(0.0, 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _handleBadgeClick(context);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _sheenController,
          _pulseController,
          _shakeController,
        ]),
        builder: (context, child) {
          const Color lockedAuraColor = Color(0xFF8A2BE2);
          final double dynamicShake =
              _shakeAnimation.value * (0.5 + widget.progress);

          return Container(
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.isUnlocked
                  ? widget.appColors.cardBackground
                  : const Color(0xFF161622),
              border: Border.all(
                color: widget.isUnlocked
                    ? widget.badge.color.withOpacity(0.25)
                    : lockedAuraColor.withOpacity(
                        (0.5 * _pulseAnimation.value).clamp(0.0, 1.0),
                      ),
                width: widget.isUnlocked ? 1.5 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isUnlocked
                      ? widget.badge.color.withOpacity(0.08)
                      : lockedAuraColor.withOpacity(
                          (0.3 * _pulseAnimation.value).clamp(0.0, 1.0),
                        ),
                  blurRadius: widget.isUnlocked
                      ? 12
                      : (20 * _pulseAnimation.value).clamp(0.0, 50.0),
                  spreadRadius: widget.isUnlocked
                      ? 0
                      : (2 * _pulseAnimation.value).clamp(0.0, 10.0),
                  offset: widget.isUnlocked ? const Offset(0, 6) : Offset.zero,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: widget.isUnlocked
                              ? 1.0
                              : (0.95 + (0.05 * _pulseAnimation.value)).clamp(
                                  0.5,
                                  2.0,
                                ),
                          child: Transform.rotate(
                            angle: widget.isUnlocked ? 0 : dynamicShake,
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: widget.isUnlocked
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: widget.badge.gradientColors,
                                      )
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.black87,
                                          lockedAuraColor.withOpacity(
                                            (0.6 * _pulseAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                boxShadow: widget.isUnlocked
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: lockedAuraColor.withOpacity(
                                            (0.5 * _pulseAnimation.value).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                          ),
                                          blurRadius: 15,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: widget.isUnlocked
                                    ? Icon(
                                        widget.badge.icon,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    : Transform.scale(
                                        scale:
                                            1.0 +
                                            (0.15 * _pulseAnimation.value),
                                        child: Icon(
                                          CupertinoIcons.lock_fill,
                                          color: Colors.white.withOpacity(
                                            (0.8 +
                                                    (0.2 *
                                                        _pulseAnimation.value))
                                                .clamp(0.0, 1.0),
                                          ),
                                          size: 26,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.isUnlocked
                                          ? widget.badge.getLocalizedTitle(
                                              widget.l10n,
                                            )
                                          : "???",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: widget.isUnlocked
                                            ? widget.appColors.primaryDark
                                            : lockedAuraColor.withOpacity(
                                                (0.8 +
                                                        (0.2 *
                                                            _pulseAnimation
                                                                .value))
                                                    .clamp(0.0, 1.0),
                                              ),
                                        letterSpacing: widget.isUnlocked
                                            ? 0
                                            : 2.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.isUnlocked
                                          ? widget.badge.color.withOpacity(0.1)
                                          : lockedAuraColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.badge.isMonthly
                                          ? widget.l10n.badgeTagMonthly
                                          : widget.l10n.badgeTagElite,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: widget.isUnlocked
                                            ? widget.badge.color
                                            : lockedAuraColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              Text(
                                widget.isUnlocked
                                    ? widget.badge.getLocalizedDesc(widget.l10n)
                                    : _getBadgeHint(), // 🚀 GỌI HÀM MẬT THƯ
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  fontStyle: widget.isUnlocked
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  color: widget.isUnlocked
                                      ? widget.appColors.textMuted.withOpacity(
                                          0.8,
                                        )
                                      : Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // 🚀 GỌI PROGRESS BAR VỚI GRADIENT
                              if (!widget.isUnlocked)
                                _buildHarmoniousProgressBar(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isUnlocked)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment(_sheenAnimation.value, 0.0),
                        child: Transform.rotate(
                          angle: pi / 6,
                          child: Container(
                            width: 32,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleBadgeClick(BuildContext context) {
    if (widget.isUnlocked) {
      String btnText;
      try {
        btnText = widget.l10n.shareBadgeAction;
      } catch (e) {
        btnText = "Khoe chiến tích ✨";
      }

      showDialog(
        context: context,
        builder: (context) => BadgePremiumDialog(
          badge: widget.badge,
          title: widget.badge.getLocalizedTitle(widget.l10n),
          description: widget.badge.getLocalizedDesc(widget.l10n),
          buttonText: btnText,
          appColors: widget.appColors,
          onButtonPressed: () {
            Navigator.pop(context);
            _triggerShareFeature(context);
          },
        ),
      );
    } else {
      _showLockedMysteryDialog(context);
    }
  }

  void _triggerShareFeature(BuildContext context) {
    String shareMsg;
    try {
      shareMsg = widget.l10n.shareBadgeMessage;
    } catch (e) {
      shareMsg = "Tuyệt vời! Tôi vừa xuất sắc mở khóa huy hiệu";
    }

    final String badgeTitle = widget.badge.getLocalizedTitle(widget.l10n);
    final String textToShare = "$shareMsg: $badgeTitle! 🏆✨\n#MomentUPayment";

    Share.share(textToShare);
  }

  void _showLockedMysteryDialog(BuildContext context) {
    const Color lockedDialogAura = Color(0xFFE91E63);
    final int percent = (widget.progress * 100).toInt();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16 * anim1.value,
            sigmaY: 16 * anim1.value,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: lockedDialogAura.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lockedDialogAura.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            lockedDialogAura.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: lockedDialogAura.withOpacity(0.6),
                            blurRadius: 50,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(color: lockedDialogAura, width: 2.0),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.lock_circle_fill,
                          color: Colors.white.withOpacity(0.9),
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      widget.l10n.badgeLockedTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lockedDialogAura.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badge.isMonthly
                            ? widget.l10n.badgeTypeMonthly
                            : widget.l10n.badgeTypeElite,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: lockedDialogAura,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Tiến độ: $percent%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: lockedDialogAura.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getBadgeHint(), 
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lockedDialogAura,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor: lockedDialogAura.withOpacity(0.5),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          widget.l10n.closeButton,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
