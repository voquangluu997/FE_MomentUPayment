import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/screens/main_layout_screen.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/auth/presentation/screens/login_screen.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 1. 🟢 ĐĂNG NHẬP THÀNH CÔNG hoặc ĐÃ XÁC THỰC: Vào thẳng giao diện chính
    if (authState == AuthState.authenticated ||
        authState == AuthState.loginSuccess) {
      return const MainLayoutScreen();
    }

    return const LoginScreen();
  }
}
