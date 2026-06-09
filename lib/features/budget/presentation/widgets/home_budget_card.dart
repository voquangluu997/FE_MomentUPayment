import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';
import 'package:moment_u_payment/core/utils/currency_helper.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
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
        height: 160,
        decoration: BoxDecoration(
          color: appColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(child: CupertinoActivityIndicator()),
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
        borderRadius: BorderRadius.circular(32),
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

// --- 🌟 STATEFUL WIDGET ĐỂ QUẢN LÝ THÔNG ĐIỆP VŨ TRỤ ---
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
        _startAutoCollapseTimer();
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // 🚀 LẤY THÔNG TIN TIỀN TỆ HIỆN TẠI TỪ PROVIDER
    final currentCurrency = ref.watch(currencyProvider).toString();
    final bool isVND =
        currentCurrency.contains('đ') ||
        currentCurrency.contains('₫') ||
        currentCurrency.contains('VND');

    // --- 📅 LOGIC TÍNH TOÁN NGÂN SÁCH MỚI ---
    final now = DateTime.now();
    final currentDay = now.day;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDaysInMonth = lastDayOfMonth - currentDay + 1;

    final limit = summary.budgetLimit;
    final spent = summary.totalSpent;
    final remaining = limit - spent;

    // Tốc độ đốt tiền hiện tại
    final double dailyBurnRate = currentDay > 1
        ? (spent / (currentDay - 1))
        : spent;

    // 🚀 TÍNH VÀ LÀM TRÒN MỨC CHI TIÊU AN TOÀN TRUNG BÌNH MỖI NGÀY
    final double rawSafeDailySpend = remaining > 0
        ? (remaining / remainingDaysInMonth)
        : 0;

    final double safeDailySpend = isVND
        ? rawSafeDailySpend
              .roundToDouble() // Tiền Việt (đ): Không lấy thập phân, làm tròn chẵn
        : double.parse(
            rawSafeDailySpend.toStringAsFixed(2),
          ); // Ngoại tệ: Làm tròn 2 số thập phân

    // 🚀 ĐÃ SỬA: Ép cứng tham số currency vào hàm helper để không dùng '₫' mặc định
    final String safeDailySpendStr = CurrencyHelper.formatCompactAmount(
      safeDailySpend,
      symbol: currentCurrency,
    );

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

    final config = _getCardConfig(
      state,
      safeDailySpendStr,
      l10n,
      appColors,
      isDark,
    );

    final double spentPercentage = isNotSet ? 0.0 : (spent / limit);
    final double clampedPercentage = spentPercentage.clamp(0.0, 1.0);

    // 🚀 ĐÃ SỬA: Ép cứng tham số currency
    final String spentStr = CurrencyHelper.formatCompactAmount(
      spent,
      symbol: currentCurrency,
    );
    final String limitStr = CurrencyHelper.formatCompactAmount(
      limit,
      symbol: currentCurrency,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.backgroundColor ??
                      appColors.cardBackground.withOpacity(isDark ? 0.6 : 0.8),
                  (config.backgroundColor ?? appColors.cardBackground)
                      .withOpacity(isDark ? 0.4 : 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.08 : 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: config.shadowColor.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -10,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      config.icon,
                      key: ValueKey(config.icon),
                      size: 140,
                      color: config.shadowColor.withOpacity(
                        isDark ? 0.08 : 0.05,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => isNotSet
                            ? const SetBudgetScreen()
                            : const AnalyticsScreen(),
                      ),
                    ),
                    highlightColor: config.shadowColor.withOpacity(0.05),
                    splashColor: config.shadowColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: config.textColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: config.shadowColor.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _PulseIndicator(
                                      color: config.accentColors.last,
                                      isPulsing: config.shouldPulse,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      config.badgeText.toUpperCase(),
                                      style: TextStyle(
                                        color: config.textColor.withOpacity(
                                          0.9,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isNotSet)
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => const SetBudgetScreen(),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: config.textColor.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: config.textColor.withOpacity(
                                          0.1,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      size: 18,
                                      color: config.textColor.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Text(
                            config.mainDisplayHeading,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: config.textColor.withOpacity(0.95),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: config.textColor.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: config.textColor.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNotSet
                                      ? CupertinoIcons.compass
                                      : CupertinoIcons.chart_pie_fill,
                                  size: 14,
                                  color: config.accentColors.last,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isNotSet
                                        ? l10n.setupRadarNow
                                        : l10n.budgetSpentStatus(
                                            spentStr,
                                            limitStr,
                                          ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: config.textColor.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 8,
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
                                    curve: Curves.easeOutQuart,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: config.accentColors,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: config.shadowColor.withOpacity(
                                            0.6,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: _togglePunchline,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: _showPunchline ? 12 : 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    config.textColor.withOpacity(0.03),
                                    config.textColor.withOpacity(0.01),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: config.textColor.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        config.bottomIcon,
                                        size: 14,
                                        color: config.shadowColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _showPunchline
                                              ? l10n.budgetCardCosmicMessage
                                              : l10n.budgetCardTapToView,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: config.textColor.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        _showPunchline
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        size: 14,
                                        color: config.textColor.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    child: _showPunchline
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              left: 22,
                                            ),
                                            child: Text(
                                              config.punchline,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: config.textColor
                                                    .withOpacity(0.9),
                                                height: 1.4,
                                              ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🎨 BỘ MÀU TỪ APP COLORS ---
  _CardDesignConfig _getCardConfig(
    _SurvivalState state,
    String safeDailySpendStr,
    AppLocalizations l10n,
    AppColorTheme appColors,
    bool isDark,
  ) {
    switch (state) {
      case _SurvivalState.notSet:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateNotSetBadge,
          mainDisplayHeading: l10n.survivalStateNotSetHeading,
          punchline: l10n.survivalStateNotSetPunchline,
          accentColors: [appColors.primary.withOpacity(0.5), appColors.primary],
          shadowColor: appColors.primary,
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.sparkles,
          bottomIcon: Icons.auto_awesome,
        );
      case _SurvivalState.godMode:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateGodModeBadge,
          mainDisplayHeading: l10n.survivalStateGodModeHeading(
            safeDailySpendStr,
          ),
          punchline: l10n.survivalStateGodModePunchline,
          accentColors: [const Color(0xFF34D399), const Color(0xFF059669)],
          shadowColor: const Color(0xFF10B981),
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.leaf_arrow_circlepath,
          bottomIcon: Icons.celebration_rounded,
        );
      case _SurvivalState.danger:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateDangerBadge,
          mainDisplayHeading: l10n.survivalStateDangerHeading(
            safeDailySpendStr,
          ),
          punchline: l10n.survivalStateDangerPunchline,
          accentColors: [const Color(0xFFFBBF24), const Color(0xFFD97706)],
          shadowColor: const Color(0xFFF59E0B),
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.speedometer,
          bottomIcon: Icons.warning_amber_rounded,
        );
      case _SurvivalState.apocalypse:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateApocalypseBadge,
          mainDisplayHeading: l10n.survivalStateApocalypseHeading(
            safeDailySpendStr,
          ),
          punchline: l10n.survivalStateApocalypsePunchline,
          accentColors: [const Color(0xFFF87171), const Color(0xFFDC2626)],
          shadowColor: const Color(0xFFEF4444),
          textColor: isDark ? const Color(0xFFFEE2E2) : const Color(0xFF7F1D1D),
          backgroundColor: isDark
              ? const Color(0xFF3B1212)
              : const Color(0xFFFEF2F2),
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          bottomIcon: Icons.sos_rounded,
          shouldPulse: true,
        );
      case _SurvivalState.wasted:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateWastedBadge,
          mainDisplayHeading: l10n.survivalStateWastedHeading,
          punchline: l10n.survivalStateWastedPunchline,
          accentColors: [const Color(0xFF94A3B8), const Color(0xFF475569)],
          shadowColor: const Color(0xFF64748B),
          textColor: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          icon: CupertinoIcons.burn,
          bottomIcon: Icons.money_off_csred_rounded,
        );
    }
  }
}

// --- KIẾN TRÚC ENUM VÀ MODEL ---
enum _SurvivalState { notSet, godMode, danger, apocalypse, wasted }

class _CardDesignConfig {
  final String badgeText;
  final String mainDisplayHeading;
  final String punchline;
  final List<Color> accentColors;
  final Color shadowColor;
  final Color textColor;
  final Color? backgroundColor;
  final IconData icon;
  final IconData bottomIcon;
  final bool shouldPulse;

  _CardDesignConfig({
    required this.badgeText,
    required this.mainDisplayHeading,
    required this.punchline,
    required this.accentColors,
    required this.shadowColor,
    required this.textColor,
    this.backgroundColor,
    required this.icon,
    required this.bottomIcon,
    this.shouldPulse = false,
  });
}

// --- WIDGET HIỆU ỨNG NHẤP NHÁY BÁO ĐỘNG SINH TỒN ---
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
        width: 8,
        height: 8,
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
                blurRadius: 10 * _controller.value,
                spreadRadius: 4 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
