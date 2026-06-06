import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/badge_service.dart';
import 'package:moment_u_payment/core/features/badges/widgets/badge_premium_dialog.dart';
import 'package:moment_u_payment/core/utils/gamification_utils.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';

// ==========================================
// 1. PROVIDER & MAIN PAGE
// ==========================================

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
            child: BadgeRectangularCard(
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

// ==========================================
// 2. BADGE CARD LIST ITEM
// ==========================================

class BadgeRectangularCard extends StatefulWidget {
  final UserBadge badge;
  final bool isUnlocked;
  final double progress;
  final AppLocalizations l10n;
  final AppColorTheme appColors;

  const BadgeRectangularCard({
    super.key,
    required this.badge,
    required this.isUnlocked,
    required this.progress,
    required this.l10n,
    required this.appColors,
  });

  @override
  State<BadgeRectangularCard> createState() => _BadgeRectangularCardState();
}

class _BadgeRectangularCardState extends State<BadgeRectangularCard>
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
      return widget.l10n.hintSecret;
    }
  }

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
                color: Colors.white.withOpacity(0.08),
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
                        Colors.white.withOpacity(0.85),
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
                                    : _getBadgeHint(),
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
      showDialog(
        context: context,
        builder: (context) => BadgePremiumDialog(
          badge: widget.badge,
          title: widget.badge.getLocalizedTitle(widget.l10n),
          description: widget.badge.getLocalizedDesc(widget.l10n),
          // Đã cập nhật đa ngôn ngữ
          buttonText: widget.l10n.boastAchievement,
          appColors: widget.appColors,
          onButtonPressed: () {
            Navigator.pop(context);
            _showSharePreview(context);
          },
        ),
      );
    } else {
      _showLockedMysteryDialog(context);
    }
  }

  void _showSharePreview(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SharePreview',
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (context, _, __) =>
          BadgeSharePreviewDialog(badge: widget.badge, l10n: widget.l10n),
    );
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
        var ImageFilter;
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
                            widget.l10n.progressTitle(percent.toString()),
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

// ==========================================
// 3. SHARE PREVIEW DIALOG & CAPTURE LOGIC
// ==========================================

class BadgeSharePreviewDialog extends StatefulWidget {
  final UserBadge badge;
  final AppLocalizations l10n;

  const BadgeSharePreviewDialog({
    super.key,
    required this.badge,
    required this.l10n,
  });

  @override
  State<BadgeSharePreviewDialog> createState() =>
      _BadgeSharePreviewDialogState();
}

class _BadgeSharePreviewDialogState extends State<BadgeSharePreviewDialog> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isProcessing = false;

  Future<void> _captureAndShare() async {
    setState(() => _isProcessing = true);
    try {
      // 1. Chụp màn hình thẻ Share từ RepaintBoundary
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Ghi ra file tạm thời
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/badge_achievement.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);

      // 3. Chuẩn bị nội dung chữ đính kèm mang tính quảng bá App (Marketing)
      final String badgeTitle = widget.badge.getLocalizedTitle(widget.l10n);
      final String textToShare = widget.l10n.shareAppPromoMessage(badgeTitle);

      // 4. Chia sẻ
      final xFile = XFile(imagePath.path);
      await Share.shareXFiles([xFile], text: textToShare);
    } catch (e) {
      debugPrint("Lỗi khi chia sẻ: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thẻ hiển thị thực tế sẽ được chụp
          RepaintBoundary(
            key: _globalKey,
            child: BadgeStunningExportCard(
              badge: widget.badge,
              l10n: widget.l10n,
            ),
          ),
          const SizedBox(height: 32),

          // Các nút bấm điều hướng
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.l10n.closeButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _captureAndShare,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(CupertinoIcons.share, color: Colors.white),
                  label: Text(
                    _isProcessing
                        ? widget.l10n.creatingImage
                        : widget.l10n.shareNow,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: widget.badge.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    shadowColor: widget.badge.color.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. THE BEAUTIFUL EXPORTABLE CARD TEMPLATE
// ==========================================

// ==========================================
// 4. THE BEAUTIFUL EXPORTABLE CARD TEMPLATE (ĐÃ SỬA LỖI OVERFLOW)
// ==========================================

class BadgeStunningExportCard extends StatelessWidget {
  final UserBadge badge;
  final AppLocalizations l10n;

  const BadgeStunningExportCard({
    super.key,
    required this.badge,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Thêm Material(transparency) để đảm bảo không lỗi Text Direction trong RepaintBoundary
    return Material(
      type: MaterialType.transparency,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xFF0F0F16), // Nền đen sâu thẳm
            border: Border.all(color: badge.color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: badge.color.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // 1. Ánh sáng Ambient đằng sau
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          badge.color.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Nội dung chính - 💡 SỬ DỤNG FITTED BOX ĐỂ KHÔNG BAO GIỜ BỊ SỌC VÀNG ĐEN
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      32,
                      24,
                      60,
                    ), // Chừa không gian cho watermark ở đáy
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Header Text
                            Text(
                              l10n.achievementUnlocked,
                              style: TextStyle(
                                color: badge.color.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Icon phát sáng
                            Container(
                              width: 140, // Đã thu nhỏ nhẹ để cân đối hơn
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: badge.gradientColors,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: badge.gradientColors.first
                                        .withOpacity(0.6),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  badge.icon,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title - Cố định width để chữ rớt dòng đẹp mắt
                            SizedBox(
                              width: 300,
                              child: Text(
                                badge.getLocalizedTitle(l10n).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            SizedBox(
                              width: 300,
                              child: Text(
                                badge.getLocalizedDesc(l10n),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Branding & Watermark nằm cố định ở đáy thẻ
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        color: Colors.white.withOpacity(0.4),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Moments U Payment",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
