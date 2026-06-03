import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moment_u_payment/features/auth/auth_checker.dart';
// 👇 Nhớ import màn hình Onboarding của bạn vào đây
import 'package:moment_u_payment/features/onboarding/presentation/onboarding_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  // 👇 Thêm biến nhận trạng thái Onboarding từ main.dart
  final bool hasSeenOnboarding;

  const SplashScreen({super.key, required this.hasSeenOnboarding});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. GỠ BỎ MÀN HÌNH NATIVE SPLASH CỦA HỆ THỐNG NGAY LẬP TỨC
    FlutterNativeSplash.remove();

    // 2. THIẾT LẬP BỘ ĐIỀU KHIỂN ANIMATION (1.2 GIÂY)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 🔥 HIỆU ỨNG NẢY (Curves.easeOutBack): Logo phóng từ nhỏ (0.3) ra lớn (1.0)
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Hiệu ứng mờ dần (Fade In)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Kích hoạt chạy hiệu ứng ngay khi màn hình vừa mount
    _animationController.forward();

    // 3. ĐIỀU HƯỚNG TỰ ĐỘNG SAU 2.8 GIÂY
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        // 👇 KIỂM TRA TRẠNG THÁI ONBOARDING ĐỂ QUYẾT ĐỊNH MÀN HÌNH TIẾP THEO
        Widget nextScreen = widget.hasSeenOnboarding
            ? const AuthChecker()
            : const OnboardingScreen();

        // Chuyển sang màn hình tiếp theo bằng hiệu ứng mờ mượt mà (FadeTransition).
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => nextScreen,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          // Lồng ghép hiệu ứng mờ dần và phóng to nảy nhẹ vào cụm Logo + Text
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HIỂN THỊ LOGO
                  Image.asset(
                    'assets/images/splash_logo.png',
                    width: 140, // Kích thước hiển thị tối ưu
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // TÊN ỨNG DỤNG
                  Text(
                    l10n.subTitle1, // "Moments U Payment"
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // SLOGAN
                  Text(
                    l10n.subTitle2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
