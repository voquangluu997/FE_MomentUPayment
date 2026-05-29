import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth_provider.dart';
import 'register_screen.dart';
import '../../../../core/providers/locale_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emptyFieldsWarning),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // Tiến hành gọi API đăng nhập thông thường
    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(
      localeProvider,
    ); // Lắng nghe để cập nhật trạng thái nút Switch

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.loginSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(authProvider.notifier).resetState();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next == AuthState.loginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ✨ ĐÃ SỬA: Đa ngôn ngữ hóa thông báo lỗi đăng nhập
            content: Text(l10n.loginErrorNotification),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).resetState();
      } else if (next == AuthState.googleLoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ✨ ĐÃ SỬA: Đa ngôn ngữ hóa thông báo lỗi Google
            content: Text(l10n.googleLoginErrorNotification),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 50,
                  ), // Tăng nhẹ khoảng cách để không đè vào nút Switch
                  Text(
                    l10n.welcomeBack,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subTitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Ô nhập Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: l10n.emailHint,
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ô nhập Mật khẩu
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: l10n.passwordHint,
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✨ CẬP NHẬT MỚI: Thanh nút bấm Quên / Đặt lại mật khẩu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showResetPasswordDialog(context),
                        child: const Text(
                          'Đặt lại mật khẩu',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nút Đăng Nhập
                  authState == AuthState.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _handleLogin,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.loginButtonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // 🌸 THANH PHÂN CÁCH HOẶC ĐĂNG NHẬP KHÁC
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🏅 NÚT BẤM ĐĂNG NHẬP BẰNG GOOGLE
                  InkWell(
                    onTap: authState == AuthState.loading
                        ? null
                        : () =>
                              ref.read(authProvider.notifier).loginWithGoogle(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://developers.google.com/static/identity/images/g-logo.png',
                            height: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.loginGGButtonText, // ✨ ĐÃ SỬA: Đa ngôn ngữ cụm này
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Điều hướng sang Đăng ký
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            // 🌐 NÚT SWITCH NGÔN NGỮ ĐẶT GÓC TRÊN CÙNG BÊN PHẢI (MÀU VÀNG PASTEL CUTE)
            Positioned(
              top: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7), // Màu nền vàng nhẹ cute
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFF59D),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🇺🇳',
                      style: TextStyle(fontSize: 13),
                    ), // Icon đại diện tổng quan hoặc giữ 🇻🇳 tùy ý
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: currentLocale.languageCode == 'en',
                        activeColor: const Color(0xFFFBC02D),
                        activeTrackColor: const Color(0xFFFFF59D),
                        inactiveThumbColor: Colors.amber,
                        inactiveTrackColor: const Color(0xFFEEEEEE),
                        onChanged: (_) {
                          ref.read(localeProvider.notifier).toggleLocale();
                        },
                      ),
                    ),
                    Text(
                      currentLocale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ CẬP NHẬT MỚI: Dialog gửi mã yêu cầu khôi phục mật khẩu
  void _showForgotPasswordDialog(BuildContext context) {
    final forgotEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Khôi phục mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hệ thống sẽ gửi một mã xác thực (OTP) hoặc liên kết đặt lại vào Email của bạn.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: forgotEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email tài khoản',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final email = forgotEmailController.text.trim();
              if (email.isNotEmpty) {
                ref.read(authProvider.notifier).forgotPassword(email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã gửi mã khôi phục đến email: $email'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Gửi mã', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✨ CẬP NHẬT MỚI: Dialog nhập OTP và đặt lại mật khẩu mới
  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đặt lại mật khẩu mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email xác thực'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã xác thực (OTP / Token)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final email = emailController.text.trim();
              final otp = otpController.text.trim();
              final newPw = newPasswordController.text.trim();

              if (email.isNotEmpty && otp.isNotEmpty && newPw.isNotEmpty) {
                ref
                    .read(authProvider.notifier)
                    .resetPasswordWithOtp(email, otp, newPw);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mật khẩu của bạn đã đổi thành công! Vui lòng đăng nhập.',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
