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

  final List<Color> _pageColors = [
    const Color(0xFF9D84B7),
    const Color(0xFFF2A6A6),
    const Color(0xFF83BCA9),
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
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) {
            var scaleTween = Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scaleTween, child: child),
            );
          },
        ),
      );
    }
  }

  Color _getAmbientTint() {
    if (_currentPage < 0) return Colors.transparent;
    if (_currentPage >= _pageColors.length - 1) {
      return _pageColors.last.withValues(alpha: 0.08);
    }

    int lowerIndex = _currentPage.floor();
    int upperIndex = lowerIndex + 1;
    double t = _currentPage - lowerIndex;

    Color startColor = _pageColors[lowerIndex];
    Color endColor = _pageColors[upperIndex];

    return Color.lerp(startColor, endColor, t)?.withValues(alpha: 0.08) ??
        Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> pagesData = [
      {
        'icon': CupertinoIcons.camera_fill,
        'title': l10n.obTitle1,
        'description': l10n.obDesc1,
        'color': _pageColors[0],
        'rotation': -0.05,
      },
      {
        'icon': CupertinoIcons.chart_pie_fill,
        'title': l10n.obTitle2,
        'description': l10n.obDesc2,
        'color': _pageColors[1],
        'rotation': 0.05,
      },
      {
        'icon': CupertinoIcons.lock_shield_fill,
        'title': l10n.obTitle3,
        'description': l10n.obDesc3,
        'color': _pageColors[2],
        'rotation': -0.02,
      },
    ];

    return Scaffold(
      backgroundColor: appColors.background,
      body: Stack(
        children: [
          // Lớp phủ màu Ambient Gradient mượt mà
          Positioned.fill(child: Container(color: _getAmbientTint())),

          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
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
                          double scale = (1 - (diff.abs() * 0.2)).clamp(
                            0.8,
                            1.0,
                          );
                          double opacity = (1 - (diff.abs() * 0.5)).clamp(
                            0.0,
                            1.0,
                          );

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: _buildMomentPage(
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

                Positioned(
                  top: 16.0,
                  right: 24.0,
                  child: AnimatedOpacity(
                    opacity: _isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: _isLastPage,
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _completeOnboarding(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: appColors.text.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        child: Text(
                          l10n.obSkip,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentPage({
    required AppColorTheme appColors,
    required Map<String, dynamic> data,
    required double parallaxOffset,
  }) {
    final Color color = data['color'];
    final double baseRotation = data['rotation'];
    final double iconTranslateX = parallaxOffset * 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: baseRotation + (parallaxOffset * 0.1),
            child: Container(
              height: 300,
              width: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Đổ bóng mịn màng và có màu sắc nhẹ ăn rơ với tone màu của trang hiện tại
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: -5,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              // 🚀 CẬP NHẬT: Thực hiện hiệu ứng Glassmorphic bằng BackdropFilter
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 16,
                    sigmaY: 16,
                  ), // Độ nhòe kính mờ cao cấp
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // Hạ opacity xuống khoảng 0.55 để lớp màu nền ambient lọt qua mờ ảo cực đẹp
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                      // Viền bán trong suốt giả lập ánh sáng phản chiếu cạnh kính
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        color.withValues(alpha: 0.25),
                                        color.withValues(alpha: 0.75),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -50,
                                  left: -50,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Transform.translate(
                                    offset: Offset(iconTranslateX, 0),
                                    child: Icon(
                                      data['icon'],
                                      size: 88,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 5,
                          width: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
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
              fontWeight: FontWeight.w500,
              color: appColors.text.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppColorTheme appColors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: ExpandingDotsEffect(
              spacing: 8,
              dotColor: appColors.primary.withValues(alpha: 0.15),
              activeDotColor: appColors.primary,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: _isLastPage ? 160 : 64,
            height: 64,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                padding: EdgeInsets.zero,
                elevation: _isLastPage ? 8 : 2,
                shadowColor: appColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              onPressed: () {
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _isLastPage
                    ? Text(
                        l10n.obStart,
                        key: const ValueKey('start_text'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
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
        ],
      ),
    );
  }
}
