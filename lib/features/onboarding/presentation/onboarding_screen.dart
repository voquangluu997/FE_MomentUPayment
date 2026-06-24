import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  double _currentPage = 0.0;
  bool _isLastPage = false;

  // Bảng màu gradient mới phù hợp với concept "Moment", "Insight" và "Cloud"
  final List<List<Color>> _pageGradients = [
    [
      const Color(0xFFFC466B),
      const Color(0xFF3F5EFB),
    ], // Moments: Cảm xúc, Kỷ niệm (Hồng/Tím)
    [
      const Color(0xFFFF8008),
      const Color(0xFFFFC837),
    ], // Insights & Splurges: Phân tích (Cam/Vàng)
    [
      const Color(0xFF11998E),
      const Color(0xFF2575FC),
    ], // Cloud Security: An tâm, Bảo mật (Ngọc/Xanh lam)
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) {
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            var slideTween =
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            return FadeTransition(
              opacity: fadeTween,
              child: SlideTransition(position: slideTween, child: child),
            );
          },
        ),
      );
    }
  }

  Color _getAmbientTint() {
    if (_currentPage < 0) return Colors.transparent;
    int lowerIndex = _currentPage.floor();
    if (lowerIndex >= _pageGradients.length - 1) {
      return _pageGradients.last[0].withValues(alpha: 0.05);
    }
    int upperIndex = lowerIndex + 1;
    double t = _currentPage - lowerIndex;

    Color startColor = _pageGradients[lowerIndex][0];
    Color endColor = _pageGradients[upperIndex][0];

    return Color.lerp(startColor, endColor, t)?.withValues(alpha: 0.05) ??
        Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    // Dữ liệu được cập nhật icon theo concept mới
    final List<Map<String, dynamic>> pagesData = [
      {
        'mainIcon': CupertinoIcons.camera_fill,
        'subIcon': CupertinoIcons.heart_fill,
        'title': l10n.obTitle1,
        'description': l10n.obDesc1,
        'gradient': _pageGradients[0],
      },
      {
        'mainIcon': CupertinoIcons.chart_pie_fill,
        'subIcon': CupertinoIcons
            .sparkles, // Icon tia lửa đại diện cho "Biggest Splurges" & Insight
        'title': l10n.obTitle2,
        'description': l10n.obDesc2,
        'gradient': _pageGradients[1],
      },
      {
        'mainIcon': CupertinoIcons.cloud_fill,
        'subIcon': CupertinoIcons.lock_shield_fill,
        'title': l10n.obTitle3,
        'description': l10n.obDesc3,
        'gradient': _pageGradients[2],
      },
    ];

    return Scaffold(
      backgroundColor: appColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _getAmbientTint(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 24.0),
                    child: AnimatedOpacity(
                      opacity: _isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: _isLastPage,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _controller.animateToPage(
                              pagesData.length - 1,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: appColors.textMuted,
                          ),
                          child: Text(
                            l10n.obSkip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: pagesData.length,
                    onPageChanged: (index) {
                      HapticFeedback.lightImpact();
                      setState(
                        () => _isLastPage = index == pagesData.length - 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      double diff = (_currentPage - index);

                      double scale = (1 - (diff.abs() * 0.15)).clamp(0.85, 1.0);
                      double opacity = (1 - (diff.abs() * 0.8)).clamp(0.0, 1.0);

                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: _buildFeaturePage(
                            appColors: appColors,
                            data: pagesData[index],
                            parallaxOffset: diff,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomControls(appColors, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage({
    required AppColorTheme appColors,
    required Map<String, dynamic> data,
    required double parallaxOffset,
  }) {
    final List<Color> gradientColors = data['gradient'];
    final IconData mainIcon = data['mainIcon'];
    final IconData subIcon = data['subIcon'];

    final double fastTranslate = parallaxOffset * 100;
    final double slowTranslate = parallaxOffset * 40;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints
                  .maxHeight, // Đảm bảo luôn giãn đầy chiều cao để căn giữa
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🚀 Dùng FittedBox để đồ họa 3D tự động co lại nếu màn hình ngang (bị lùn)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      height: 340,
                      width:
                          340, // Chiều rộng cố định để FittedBox giữ đúng khung tỷ lệ
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 80,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(slowTranslate, 0),
                            child: Container(
                              width: 220,
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[1].withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -30,
                                    right: -30,
                                    child: Icon(
                                      CupertinoIcons.circle_fill,
                                      size: 140,
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      mainIcon,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            right: 20,
                            child: Transform.translate(
                              offset: Offset(fastTranslate, 0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: appColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  subIcon,
                                  size: 36,
                                  color: gradientColors[0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    data['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: appColors.text,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    data['description'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: appColors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(AppColorTheme appColors, AppLocalizations l10n) {
    // 🚀 Giảm padding bottom từ 48 xuống 24 để màn hình ngang có thêm không gian thở
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: ExpandingDotsEffect(
              spacing: 8,
              dotColor: appColors.primary.withValues(alpha: 0.2),
              activeDotColor:
                  _pageGradients[_currentPage.round().clamp(0, 2)][0],
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: _isLastPage ? 150 : 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                colors: _isLastPage
                    ? _pageGradients[2]
                    : [appColors.primary, appColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (_isLastPage ? _pageGradients[2][0] : appColors.primary)
                          .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (_isLastPage) {
                    _completeOnboarding(context);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.fastOutSlowIn,
                    );
                  }
                },
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                    child: _isLastPage
                        ? Text(
                            l10n.obStart,
                            key: const ValueKey('start_text'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          )
                        : const Icon(
                            CupertinoIcons.arrow_right,
                            key: ValueKey('arrow_icon'),
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
