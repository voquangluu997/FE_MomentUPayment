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
    final appColors = ref.read(appColorsProvider);

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emptyFieldsWarning),
          backgroundColor: appColors.error,
        ),
      );
      return;
    }
    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final appColors = ref.watch(appColorsProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.loginSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginSuccess),
            backgroundColor: appColors.success,
          ),
        );
        ref.read(authProvider.notifier).resetState();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next == AuthState.loginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginErrorNotification),
            backgroundColor: appColors.error,
          ),
        );
        ref.read(authProvider.notifier).resetState();
      } else if (next == AuthState.googleLoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleLoginErrorNotification),
            backgroundColor: appColors.error,
          ),
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    l10n.welcomeBack,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: appColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subTitle,
                    style: TextStyle(fontSize: 14, color: appColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Ô nhập Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: appColors.text,
                    ), // ✨ Sửa màu chữ nhập từ AppColors
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      labelStyle: TextStyle(color: appColors.textMuted),
                      hintText: l10n.emailHint,
                      hintStyle: TextStyle(
                        color: appColors.textMuted.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: appColors.cardBackground,
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
                    style: TextStyle(
                      color: appColors.text,
                    ), // ✨ Sửa màu chữ nhập từ AppColors
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      labelStyle: TextStyle(color: appColors.textMuted),
                      hintText: l10n.passwordHint,
                      hintStyle: TextStyle(
                        color: appColors.textMuted.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: appColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Thanh nút bấm Quên / Đặt lại mật khẩu (Đã đa ngôn ngữ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: Text(
                          l10n.forgotPasswordText,
                          style: TextStyle(
                            color: appColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showResetPasswordDialog(context),
                        child: Text(
                          l10n.resetPasswordText,
                          style: TextStyle(
                            color: appColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nút Đăng Nhập
                  authState == AuthState.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appColors.primary,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _handleLogin,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: appColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.loginButtonText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: appColors.background,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: appColors.textMuted.withOpacity(0.3),
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: appColors.textMuted.withOpacity(0.3),
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // NÚT BẤM ĐĂNG NHẬP BẰNG GOOGLE
                  InkWell(
                    onTap: authState == AuthState.loading
                        ? null
                        : () =>
                              ref.read(authProvider.notifier).loginWithGoogle(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: appColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: appColors.textMuted.withOpacity(0.2),
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
                            l10n.loginGGButtonText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appColors
                                  .text, // ✨ Sử dụng AppColors đồng bộ text
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
                      style: TextStyle(color: appColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            // NÚT SWITCH NGÔN NGỮ ĐẶT GÓC TRÊN CÙNG BÊN PHẢI
            Positioned(
              top: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: appColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: appColors.textMuted.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇺🇳', style: TextStyle(fontSize: 13)),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: appColors.primaryDark,
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

  // Dialog gửi mã yêu cầu khôi phục mật khẩu (Đã đa ngôn ngữ & Đồng bộ AppColors)
  void _showForgotPasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final forgotEmailController = TextEditingController();
    final appColors = ref.read(appColorsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.forgotPasswordTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.forgotPasswordSubtitle,
              style: TextStyle(fontSize: 13, color: appColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: forgotEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: appColors.text,
              ), // ✨ Đồng bộ màu text nhập
              decoration: InputDecoration(
                labelText: l10n.emailAccountLabel,
                labelStyle: TextStyle(color: appColors.textMuted),
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
            child: Text(
              l10n.cancelButton,
              style: TextStyle(color: appColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primary,
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
                    content: Text('${l10n.sendCodeSuccess} $email'),
                    backgroundColor: appColors.success,
                  ),
                );
              }
            },
            child: Text(
              l10n.sendCodeButton,
              style: TextStyle(color: appColors.background),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog nhập OTP và đặt lại mật khẩu mới (Đã đa ngôn ngữ & Đồng bộ AppColors)
  void _showResetPasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final appColors = ref.read(appColorsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.resetPasswordTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: appColors.text,
                ), // ✨ Đồng bộ màu text nhập
                decoration: InputDecoration(
                  labelText: l10n.emailVerificationLabel,
                  labelStyle: TextStyle(color: appColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: appColors.text,
                ), // ✨ Đồng bộ màu text nhập
                decoration: InputDecoration(
                  labelText: l10n.otpLabel,
                  labelStyle: TextStyle(color: appColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(
                  color: appColors.text,
                ), // ✨ Đồng bộ màu text nhập
                decoration: InputDecoration(
                  labelText: l10n.newPasswordLabel,
                  labelStyle: TextStyle(color: appColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancelButton,
              style: TextStyle(color: appColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primary,
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
                  SnackBar(
                    content: Text(l10n.resetPasswordSuccess),
                    backgroundColor: appColors.success,
                  ),
                );
              }
            },
            child: Text(
              l10n.confirmButton,
              style: TextStyle(color: appColors.background),
            ),
          ),
        ],
      ),
    );
  }
}
