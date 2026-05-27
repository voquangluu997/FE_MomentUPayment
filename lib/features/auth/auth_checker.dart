import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/features/home/presentation/screens/home_screen.dart';
// 📝 LƯU Ý: Thay thế bằng đường dẫn import chuẩn tới LoginScreen thực tế của bạn

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // ⏳ Đang check token ngầm dưới nền -> Show màn chờ xoay tròn thanh lịch
    if (authState == AuthState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF2196F3),
            ), // Thay bằng AppColors.primary của bạn
          ),
        ),
      );
    }

    // 🎉 Đăng nhập cũ thành công HOẶC vừa đăng nhập form thành công -> Cho vào Home
    if (authState == AuthState.authenticated ||
        authState == AuthState.loginSuccess) {
      return const HomeScreen();
    }

    // 🔒 Các trường hợp còn lại (chưa login, lỗi login, hết hạn token) -> Giữ ở LoginScreen
    return const LoginScreen();
  }
}
