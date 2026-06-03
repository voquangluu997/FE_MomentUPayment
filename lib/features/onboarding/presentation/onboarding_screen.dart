import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final PageController _controller = PageController();
  bool _isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  // 🌍 Lấy ngôn ngữ từ thiết bị, mặc định là Tiếng Anh
  Locale _getDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'vi') {
      return const Locale('vi');
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);

    // Sử dụng localization dựa trên thiết bị (hoặc giữ nguyên AppLocalizations.of(context)! nếu đã cấu hình ở MaterialApp)
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 🌸 Nút "Bỏ qua" (Skip) - Đặt nổi lên trên cùng
            Positioned(
              top: 16.0,
              right: 24.0,
              child: AnimatedOpacity(
                opacity: _isLastPage ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: () => _completeOnboarding(context),
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.primaryDark.withOpacity(0.5),
                  ),
                  child: Text(
                    l10n.obSkip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            // 🌸 Khu vực nội dung vuốt chính
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _isLastPage = index == 2);
                    },
                    children: [
                      _buildMomentPage(
                        appColors: appColors,
                        icon: CupertinoIcons
                            .camera_fill, // Icon máy ảnh/khoảnh khắc
                        title: l10n.obTitle1,
                        description: l10n.obDesc1,
                        color: const Color(0xFF9D84B7), // Tím pastel hoài niệm
                        rotation:
                            -0.05, // Nghiêng nhẹ ảnh tạo cảm giác tự nhiên
                      ),
                      _buildMomentPage(
                        appColors: appColors,
                        icon: CupertinoIcons.chart_pie_fill,
                        title: l10n.obTitle2,
                        description: l10n.obDesc2,
                        color: const Color(0xFFF2A6A6), // Hồng cam hoàng hôn
                        rotation: 0.05,
                      ),
                      _buildMomentPage(
                        appColors: appColors,
                        icon: CupertinoIcons.lock_shield_fill,
                        title: l10n.obTitle3,
                        description: l10n.obDesc3,
                        color: const Color(0xFF83BCA9), // Xanh vintage mint
                        rotation: -0.02,
                      ),
                    ],
                  ),
                ),

                // 🌸 Bottom Controls (Chỉ báo & Nút)
                _buildBottomControls(appColors, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 📸 Widget tạo giao diện theo phong cách "Khung ảnh lấy liền (Polaroid)"
  Widget _buildMomentPage({
    required AppColorTheme appColors,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required double rotation,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiệu ứng khung ảnh nghiêng
          Transform.rotate(
            angle: rotation,
            child: Container(
              height: 280,
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Phần hình ảnh bên trong thẻ
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phần viền ghi chú giả lập ở dưới thẻ ảnh
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 56),

          // Typography phong cách sang trọng, mềm mại
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: appColors.primaryDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: appColors.primaryDark.withOpacity(0.6),
              height: 1.6, // Tăng khoảng cách dòng để dễ đọc hơn
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 🎛️ Khu vực điều hướng bên dưới
  Widget _buildBottomControls(AppColorTheme appColors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chỉ báo chấm động (Smooth Indicator)
          SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: WormEffect(
              spacing: 12,
              dotColor: appColors.primary.withOpacity(0.15),
              activeDotColor: appColors.primary,
              dotHeight: 10,
              dotWidth: 10,
              type: WormType.thinUnderground, // Hiệu ứng lướt nhẹ nhàng
            ),
          ),

          // Nút bấm mềm mại
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            width: _isLastPage ? 180 : 70, // Dài ra mềm mại khi đến trang cuối
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                padding: EdgeInsets.zero,
                elevation: 0, // Bỏ bóng đổ cục bộ để dùng bóng tổng thể
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_isLastPage) {
                  _completeOnboarding(context);
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                  );
                }
              },
              child: _isLastPage
                  ? Text(
                      l10n.obStart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    )
                  : const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 26,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
