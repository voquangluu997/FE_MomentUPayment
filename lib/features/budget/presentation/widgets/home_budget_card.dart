import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/budget/providers/home_budget_provider.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class HomeBudgetCard extends ConsumerWidget {
  const HomeBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(homeBudgetProvider);
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    return budgetAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 120, // Đã giảm height loading
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24), // Thu gọn bo góc
        ),
      ),
      error: (err, stack) => _buildErrorCard(l10n),
      data: (summary) => _HomeBudgetCardContent(summary: summary),
    );
  }

  Widget _buildErrorCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4B4B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          l10n.budgetLoadError,
          style: const TextStyle(
            color: Color(0xFFFF4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// --- 🌟 TÁCH THÀNH STATEFUL WIDGET ĐỂ QUẢN LÝ TIMER ẨN/HIỆN THÔNG ĐIỆP ---
class _HomeBudgetCardContent extends ConsumerStatefulWidget {
  final dynamic summary;
  const _HomeBudgetCardContent({required this.summary});

  @override
  ConsumerState<_HomeBudgetCardContent> createState() =>
      _HomeBudgetCardContentState();
}

class _HomeBudgetCardContentState
    extends ConsumerState<_HomeBudgetCardContent> {
  bool _showPunchline = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCollapseTimer();
  }

  void _startAutoCollapseTimer() {
    _hideTimer?.cancel();
    // Tự động ẩn thông điệp sau 10 giây
    _hideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _showPunchline) {
        setState(() {
          _showPunchline = false;
        });
      }
    });
  }

  void _togglePunchline() {
    setState(() {
      _showPunchline = !_showPunchline;
      if (_showPunchline) {
        _startAutoCollapseTimer(); // Mở lại thì đếm giờ lại
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);

    // --- 📅 LOGIC NGÀY & TỐC ĐỘ ĐỐT TIỀN (Giữ nguyên) ---
    final now = DateTime.now();
    final currentDay = now.day;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDaysInMonth = lastDayOfMonth - currentDay + 1;

    final limit = summary.budgetLimit;
    final spent = summary.totalSpent;
    final remaining = limit - spent;

    final double dailyBurnRate = currentDay > 1
        ? (spent / (currentDay - 1))
        : spent;

    int survivalDays = 99;
    if (dailyBurnRate > 0 && remaining > 0) {
      survivalDays = (remaining / dailyBurnRate).floor();
    } else if (remaining <= 0) {
      survivalDays = 0;
    }

    final bool isNotSet = limit <= 0;
    final bool isOvertarget = !isNotSet && remaining <= 0;

    _SurvivalState state;
    if (isNotSet) {
      state = _SurvivalState.notSet;
    } else if (isOvertarget) {
      state = _SurvivalState.wasted;
    } else if (survivalDays <= 3) {
      state = _SurvivalState.apocalypse;
    } else if (survivalDays < remainingDaysInMonth) {
      state = _SurvivalState.danger;
    } else {
      state = _SurvivalState.godMode;
    }
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final config = _getCardConfig(
      state,
      survivalDays,
      remainingDaysInMonth,
      l10n,
      appColors,
      isDark,
    );

    final double spentPercentage = isNotSet ? 0.0 : (spent / limit);
    final double clampedPercentage = spentPercentage > 1.0
        ? 1.0
        : spentPercentage;

    final String spentStr = CurrencyHelper.formatCompactAmount(spent);
    final String limitStr = CurrencyHelper.formatCompactAmount(limit);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: config.backgroundColor ?? appColors.cardBackground,
        borderRadius: BorderRadius.circular(24), // Bo góc mềm mại, nhỏ hơn
        boxShadow: [
          BoxShadow(
            color: config.accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: config.accentColor.withOpacity(0.15),
          width: config.borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  isNotSet ? const SetBudgetScreen() : const AnalyticsScreen(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ), // Giảm padding tổng từ 22 xuống 16
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LAYER 1: STATUS LINE & TIMING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🛠️ FIX LỖI TRÀN VIỀN: Dùng Expanded cho phần Title
                    Expanded(
                      child: Row(
                        children: [
                          _PulseIndicator(
                            color: config.accentColor,
                            isPulsing: config.shouldPulse,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              config.title.toUpperCase(),
                              style: TextStyle(
                                color: config.textColor.withOpacity(0.6),
                                fontSize: 10, // Giảm font
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // 🛠️ Cắt chữ nếu quá dài
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: config.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            config.icon,
                            size: 11, // Giảm size icon
                            color: config.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            config.badgeText,
                            style: TextStyle(
                              color: config.accentColor,
                              fontSize: 10, // Giảm font
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Giảm khoảng cách
                // LAYER 2: BIG COUNTDOWN OR TEXT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.mainDisplayHeading,
                            style: TextStyle(
                              fontSize: 20, // Giảm từ 28 xuống 20
                              fontWeight: FontWeight.w900,
                              color: config.textColor,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow
                                .ellipsis, // 🛠️ Chống tràn dòng tiêu đề
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isNotSet
                                ? l10n.setupRadarNow
                                : l10n.spentOutOffLimit(spentStr, limitStr),
                            style: TextStyle(
                              fontSize: 12, // Giảm font
                              fontWeight: FontWeight.w600,
                              color: config.textColor.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!isNotSet) ...[
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32, // Thu nhỏ nút sửa
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: config.textColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: config.accentColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SetBudgetScreen(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // LAYER 3: THE GAME PROGRESS TIMELINE
                SizedBox(
                  height: 6, // Làm thanh bar mỏng lại
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: config.textColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: clampedPercentage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                config.accentColor.withOpacity(0.7),
                                config.accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // LAYER 4: VIBE LÉM LỈNH (CÓ THỂ GẬP/MỞ & TỰ ĐỘNG ẨN)
                GestureDetector(
                  onTap: _togglePunchline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: config.textColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              config.bottomIcon,
                              size: 14,
                              color: config.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _showPunchline
                                    ? l10n.budgetCardCosmicMessage
                                    : l10n.budgetCardTapToView,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: config.textColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                            Icon(
                              _showPunchline
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              size: 12,
                              color: config.textColor.withOpacity(0.4),
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _showPunchline
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 22,
                                      ), // Căn lề thụt vào khớp với icon trên
                                      Expanded(
                                        child: Text(
                                          config.punchline,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: config.textColor.withOpacity(
                                              0.8,
                                            ),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CONFIG HELPER (Giữ nguyên logic của bạn) ---
  _CardDesignConfig _getCardConfig(
    _SurvivalState state,
    int survivalDays,
    int remainingDaysInMonth,
    AppLocalizations l10n,
    AppColorTheme appColors,
    bool isDark,
  ) {
    final int missingDays = remainingDaysInMonth - survivalDays;
    switch (state) {
      case _SurvivalState.notSet:
        return _CardDesignConfig(
          title: l10n.survivalStateNotSetTitle,
          badgeText: l10n.survivalStateNotSetBadge,
          mainDisplayHeading: l10n.survivalStateNotSetHeading,
          punchline: l10n.survivalStateNotSetPunchline,
          accentColor: appColors.primary,
          textColor: appColors.text,
          icon: CupertinoIcons.lock,
          bottomIcon: Icons.help_outline,
        );
      case _SurvivalState.godMode:
        return _CardDesignConfig(
          title: l10n.survivalStateGodModeTitle,
          badgeText: l10n.survivalStateGodModeBadge,
          mainDisplayHeading: l10n.survivalStateGodModeHeading,
          punchline: l10n.survivalStateGodModePunchline,
          accentColor: const Color(0xFF10B981),
          textColor: appColors.text,
          icon: CupertinoIcons.check_mark_circled,
          bottomIcon: Icons.verified_user_outlined,
        );
      case _SurvivalState.danger:
        return _CardDesignConfig(
          title: l10n.survivalStateDangerTitle,
          badgeText: l10n.survivalStateDangerBadge,
          mainDisplayHeading: l10n.survivalStateDangerHeading(
            survivalDays.toString(),
          ),
          punchline: l10n.survivalStateDangerPunchline(missingDays.toString()),
          accentColor: const Color(0xFFF59E0B),
          textColor: appColors.text,
          icon: Icons.speed,
          bottomIcon: Icons.warning_amber_rounded,
        );
      case _SurvivalState.apocalypse:
        return _CardDesignConfig(
          title: l10n.survivalStateApocalypseTitle,
          badgeText: l10n.survivalStateApocalypseBadge,
          mainDisplayHeading: l10n.survivalStateApocalypseHeading(
            survivalDays.toString(),
          ),
          punchline: l10n.survivalStateApocalypsePunchline,
          accentColor: const Color(0xFFEF4444),
          textColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D),
          backgroundColor: isDark
              ? const Color(0xFF311515)
              : const Color(0xFFFEF2F2),
          icon: CupertinoIcons.timer,
          bottomIcon: Icons.gavel,
          shouldPulse: true,
          borderWidth: 1.5,
        );
      case _SurvivalState.wasted:
        return _CardDesignConfig(
          title: l10n.survivalStateWastedTitle,
          badgeText: l10n.survivalStateWastedBadge,
          mainDisplayHeading: l10n.survivalStateWastedHeading,
          punchline: l10n.survivalStateWastedPunchline,
          // 🛠️ Đảo màu Slate Grey thông minh khi bật Dark Mode
          accentColor: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF1E293B),
          textColor: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF1F5F9),
          icon: Icons.sentiment_very_dissatisfied,
          bottomIcon: Icons.refresh,
          borderWidth: 1.2,
        );
    }
  }
}

// --- ⚙️ TINH CHỈNH KIẾN TRÚC ENUM VÀ MODEL NỘI BỘ ---
enum _SurvivalState { notSet, godMode, danger, apocalypse, wasted }

class _CardDesignConfig {
  final String title;
  final String badgeText;
  final String mainDisplayHeading;
  final String punchline;
  final Color accentColor;
  final Color textColor;
  final Color? backgroundColor;
  final IconData icon;
  final IconData bottomIcon;
  final bool shouldPulse;
  final double borderWidth;

  _CardDesignConfig({
    required this.title,
    required this.badgeText,
    required this.mainDisplayHeading,
    required this.punchline,
    required this.accentColor,
    required this.textColor,
    this.backgroundColor,
    required this.icon,
    required this.bottomIcon,
    this.shouldPulse = false,
    this.borderWidth = 1.0,
  });
}

// --- 🔴 WIDGET HIỆU ỨNG NHẤP NHÁY BÁO ĐỘNG SINH TỒN ---
class _PulseIndicator extends StatefulWidget {
  final Color color;
  final bool isPulsing;
  const _PulseIndicator({required this.color, this.isPulsing = false});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPulsing) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(1.0 - _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 3 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
