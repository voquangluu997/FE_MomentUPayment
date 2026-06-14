import 'dart:math' as math;
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
          color: appColors.cardBackground.withValues(alpha: 0.5),
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
        color: const Color(0xFFFF4B4B).withValues(alpha: 0.08),
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

class _HomeBudgetCardContent extends ConsumerStatefulWidget {
  final dynamic summary;
  const _HomeBudgetCardContent({required this.summary});

  @override
  ConsumerState<_HomeBudgetCardContent> createState() =>
      _HomeBudgetCardContentState();
}

class _HomeBudgetCardContentState extends ConsumerState<_HomeBudgetCardContent>
    with SingleTickerProviderStateMixin {
  // 🌟 Controller tạo chuyển động đi bộ cho chú cún
  late AnimationController _walkController;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final l10n = AppLocalizations.of(context)!;
    final appColors = ref.watch(appColorsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final currentCurrency = ref.watch(currencyProvider).toString();
    final bool isVND =
        currentCurrency.contains('đ') ||
        currentCurrency.contains('₫') ||
        currentCurrency.contains('VND');

    // --- LOGIC TÍNH TOÁN NGÂN SÁCH ---
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

    final double rawSafeDailySpend = remaining > 0
        ? (remaining / remainingDaysInMonth)
        : 0;
    final double safeDailySpend = isVND
        ? rawSafeDailySpend.roundToDouble()
        : double.parse(rawSafeDailySpend.toStringAsFixed(2));

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

    final String leftStr = CurrencyHelper.formatCompactAmount(
      remaining > 0 ? remaining : 0,
      symbol: currentCurrency,
    );
    final String limitStr = CurrencyHelper.formatCompactAmount(
      limit,
      symbol: currentCurrency,
    );
    final String spentStr = CurrencyHelper.formatCompactAmount(
      spent,
      symbol: currentCurrency,
    );

    // Chuỗi văn bản gợi ý chi tiêu và đếm ngược ngày
    String adviceText;
    if (isNotSet) {
      adviceText = l10n.survivalStateNotSetHeading;
    } else if (remaining <= 0) {
      adviceText = l10n.budgetAdviceExceeded;
    } else {
      adviceText = l10n.budgetAdviceSafeDaily(
        remainingDaysInMonth,
        safeDailySpendStr,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.backgroundColor ??
                      appColors.cardBackground.withValues(
                        alpha: isDark ? 0.6 : 0.8,
                      ),
                  (config.backgroundColor ?? appColors.cardBackground)
                      .withValues(alpha: isDark ? 0.4 : 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: config.shadowColor.withValues(alpha: 0.15),
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
                      color: config.shadowColor.withValues(
                        alpha: isDark ? 0.08 : 0.05,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => isNotSet
                          ? const SetBudgetScreen()
                          : const AnalyticsScreen(),
                    ),
                  ),
                  highlightColor: config.shadowColor.withValues(alpha: 0.05),
                  splashColor: config.shadowColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PHẦN 1: HEADER TAG PHÁT SÁNG ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: config.textColor.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: config.shadowColor.withValues(
                                    alpha: 0.15,
                                  ),
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
                                    isNotSet
                                        ? l10n.setupRadarNow.toUpperCase()
                                        : l10n.mySpendingSafeZone.toUpperCase(),
                                    style: TextStyle(
                                      color: config.textColor.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Nút chuyển hướng chỉnh sửa nhanh ngân sách
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => const SetBudgetScreen(),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: config.accentColors.last.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: config.accentColors.last.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.pencil,
                                  size: 12,
                                  color: config.accentColors.last,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // --- PHẦN 2: TÌNH TRẠNG HẠN MỨC & GỢI Ý CHI TIÊU ---
                        Text(
                          isNotSet
                              ? l10n.budgetStatusTitleNotSet
                              : l10n.budgetStatusTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: config.textColor.withValues(alpha: 0.45),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adviceText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: config.textColor.withValues(alpha: 0.95),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- PHẦN 3: THANH PROGRESS BAR ĐỘC QUYỀN (CHÚ CÚN BIẾT ĐI) ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const double dogBoxWidth = 60.0;
                            final double trackWidth = constraints.maxWidth;
                            final double usableTrackWidth =
                                trackWidth - dogBoxWidth;
                            final double dogLeftOffset =
                                usableTrackWidth * clampedPercentage;

                            return SizedBox(
                              height:
                                  85, // Không gian chứa số tiền đã tiêu, cún và số tiền bên dưới
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Nền thanh tiến trình chìm phía dưới
                                  Positioned(
                                    top: 42,
                                    left: dogBoxWidth / 2,
                                    right: dogBoxWidth / 2,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: config.textColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Thanh tiến trình đã nạp đầy màu sắc gradient sinh động
                                  Positioned(
                                    top: 42,
                                    left: dogBoxWidth / 2,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.easeOutQuart,
                                      height: 6,
                                      width: dogLeftOffset,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: config.accentColors,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Đầu thanh tiến trình: Số tiền CÒN LẠI
                                  Positioned(
                                    top: 64,
                                    left: 4,
                                    child: Text(
                                      isNotSet
                                          ? l10n.budgetBarLeftNotSet
                                          : l10n.budgetBarLeft(leftStr),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: remaining > 0
                                            ? (isDark
                                                  ? const Color(0xFF34D399)
                                                  : const Color(0xFF059669))
                                            : config.textColor.withValues(
                                                alpha: 0.4,
                                              ),
                                      ),
                                    ),
                                  ),
                                  // Cuối thanh tiến trình: Số tiền HẠN MỨC
                                  Positioned(
                                    top: 64,
                                    right: 4,
                                    child: Text(
                                      l10n.budgetBarLimit(limitStr),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: config.textColor.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Widget chú cún chuyển động kết hợp số tiền ĐÃ TIÊU ở trên đầu
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutQuart,
                                    left: dogLeftOffset,
                                    top: 0,
                                    child: SizedBox(
                                      width: dogBoxWidth,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Bong bóng số tiền ĐÃ TIÊU nổi phía trên
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: config.accentColors.last,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: config
                                                        .accentColors
                                                        .last
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                spentStr,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          // Chú cún di chuyển sinh động bước đi bộ (Wobble & Bounce)
                                          AnimatedBuilder(
                                            animation: _walkController,
                                            builder: (context, child) {
                                              // Không nhảy lắc lắc nếu chưa thiết lập ví hoặc đã dùng hết ví
                                              final double bounce =
                                                  (isNotSet || remaining <= 0)
                                                  ? 0
                                                  : math.sin(
                                                          _walkController
                                                                  .value *
                                                              math.pi,
                                                        ) *
                                                        -3.5;
                                              final double wobble =
                                                  (isNotSet || remaining <= 0)
                                                  ? 0
                                                  : math.cos(
                                                          _walkController
                                                                  .value *
                                                              math.pi,
                                                        ) *
                                                        0.08;

                                              return Transform.translate(
                                                offset: Offset(0, bounce),
                                                child: Transform.rotate(
                                                  angle: wobble,
                                                  child: Transform(
                                                    alignment: Alignment.center,
                                                    transform:
                                                        Matrix4.identity()
                                                          ..rotateY(math.pi),
                                                    child: Text(
                                                      remaining <= 0
                                                          ? '😵'
                                                          : '🐕',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

  // --- BỘ CẤU HÌNH THEO TRẠNG THÁI TÀI CHÍNH ---
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
          accentColors: [
            appColors.primary.withValues(alpha: 0.5),
            appColors.primary,
          ],
          shadowColor: appColors.primary,
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.sparkles,
        );
      case _SurvivalState.godMode:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateGodModeBadge,
          mainDisplayHeading: l10n.survivalStateGodModeHeading(
            safeDailySpendStr,
          ),
          accentColors: [const Color(0xFF34D399), const Color(0xFF059669)],
          shadowColor: const Color(0xFF10B981),
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.leaf_arrow_circlepath,
        );
      case _SurvivalState.danger:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateDangerBadge,
          mainDisplayHeading: l10n.survivalStateDangerHeading(
            safeDailySpendStr,
          ),
          accentColors: [const Color(0xFFFBBF24), const Color(0xFFD97706)],
          shadowColor: const Color(0xFFF59E0B),
          textColor: appColors.textPrimary,
          icon: CupertinoIcons.speedometer,
        );
      case _SurvivalState.apocalypse:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateApocalypseBadge,
          mainDisplayHeading: l10n.survivalStateApocalypseHeading(
            safeDailySpendStr,
          ),
          accentColors: [const Color(0xFFF87171), const Color(0xFFDC2626)],
          shadowColor: const Color(0xFFEF4444),
          textColor: isDark ? const Color(0xFFFEE2E2) : const Color(0xFF7F1D1D),
          backgroundColor: isDark
              ? const Color(0xFF3B1212)
              : const Color(0xFFFEF2F2),
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          shouldPulse: true,
        );
      case _SurvivalState.wasted:
        return _CardDesignConfig(
          badgeText: l10n.survivalStateWastedBadge,
          mainDisplayHeading: l10n.survivalStateWastedHeading,
          accentColors: [const Color(0xFF94A3B8), const Color(0xFF475569)],
          shadowColor: const Color(0xFF64748B),
          textColor: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          icon: CupertinoIcons.burn,
        );
    }
  }
}

// --- KIẾN TRÚC ENUM VÀ MODEL ---
enum _SurvivalState { notSet, godMode, danger, apocalypse, wasted }

class _CardDesignConfig {
  final String badgeText;
  final String mainDisplayHeading;
  final List<Color> accentColors;
  final Color shadowColor;
  final Color textColor;
  final Color? backgroundColor;
  final IconData icon;
  final bool shouldPulse;

  _CardDesignConfig({
    required this.badgeText,
    required this.mainDisplayHeading,
    required this.accentColors,
    required this.shadowColor,
    required this.textColor,
    this.backgroundColor,
    required this.icon,
    this.shouldPulse = false,
  });
}

// --- WIDGET HIỆU ỨNG NHẤP NHÁY ---
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
                color: widget.color.withValues(alpha: 1.0 - _controller.value),
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
