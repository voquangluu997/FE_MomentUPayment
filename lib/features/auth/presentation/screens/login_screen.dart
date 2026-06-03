import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth_provider.dart';
import 'register_screen.dart';
import '../../../../core/utils/app_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusManager.instance.primaryFocus?.unfocus();

    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final appColors = ref.read(appColorsProvider);

    if (email.isEmpty || password.isEmpty) {
      AppToast.showError(context, l10n.emptyFieldsWarning, appColors);
      return;
    }
    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final appColors = ref.watch(appColorsProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.loginSuccess) {
        // AppToast.showSuccess(context, l10n.loginSuccess, appColors);
        ref.read(authProvider.notifier).completeLogin();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth_check', (route) => false);
      } else if (next == AuthState.loginError) {
        AppToast.showError(context, l10n.loginErrorNotification, appColors);
        ref.read(authProvider.notifier).resetState();
      } else if (next == AuthState.googleLoginError) {
        AppToast.showError(
          context,
          l10n.googleLoginErrorNotification,
          appColors,
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // 🌸 ĐIỂM NHẤN THỊ GIÁC (Icon/Logo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.person_crop_circle_fill_badge_checkmark,
                      size: 64,
                      color: appColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tiêu đề & Lời chào
                Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: appColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.subTitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: appColors.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 🌸 NÂNG CẤP: Ô Nhập Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    color: appColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    labelStyle: TextStyle(color: appColors.textMuted),
                    hintText: l10n.emailHint,
                    prefixIcon: Icon(
                      CupertinoIcons.mail,
                      color: appColors.textMuted,
                    ),
                    filled: true,
                    fillColor: appColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: appColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🌸 NÂNG CẤP: Ô Nhập Mật Khẩu (Có nút Show/Hide)
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) =>
                      _handleLogin(), // Hỗ trợ bấm Enter/Done trên bàn phím để login
                  style: TextStyle(
                    color: appColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    labelStyle: TextStyle(color: appColors.textMuted),
                    hintText: l10n.passwordHint,
                    prefixIcon: Icon(
                      CupertinoIcons.lock,
                      color: appColors.textMuted,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: _obscurePassword
                            ? appColors.textMuted
                            : appColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: appColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: appColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Thanh nút bấm Quên / Đặt lại mật khẩu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _showForgotPasswordDialog(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: appColors.primary,
                      ),
                      child: Text(
                        l10n.forgotPasswordText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _showResetPasswordDialog(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: appColors.primaryDark,
                      ),
                      child: Text(
                        l10n.resetPasswordText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🌸 NÂNG CẤP: Nút Đăng Nhập
                ElevatedButton(
                  onPressed: authState == AuthState.loading
                      ? null
                      : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: appColors.primary.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: appColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: authState == AuthState.loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          l10n.loginButtonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),

                const SizedBox(height: 32),

                // Thanh ngăn cách (Divider)
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: appColors.textMuted.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: appColors.textMuted.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: appColors.textMuted.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 🌸 NÂNG CẤP: Nút Đăng nhập Google
                OutlinedButton(
                  onPressed: authState == AuthState.loading
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          ref.read(authProvider.notifier).loginWithGoogle();
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: appColors.cardBackground,
                    foregroundColor: appColors.text,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: appColors.textMuted.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://developers.google.com/static/identity/images/g-logo.png',
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.loginGGButtonText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Điều hướng sang Đăng ký
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.dontHaveAccount, // Giữ nguyên thông báo gốc của bạn
                    textAlign: TextAlign
                        .center, // Xử lý tràn viền: Tự động xuống dòng ở giữa nếu text dài
                    style: TextStyle(
                      color: appColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  // Dialog gửi mã yêu cầu khôi phục mật khẩu
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
              style: TextStyle(color: appColors.text),
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
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
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
              FocusManager.instance.primaryFocus?.unfocus();
              final email = forgotEmailController.text.trim();
              if (email.isNotEmpty) {
                ref.read(authProvider.notifier).forgotPassword(email);
                Navigator.pop(context);

                AppToast.showSuccess(
                  context,
                  '${l10n.sendCodeSuccess} $email',
                  appColors,
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

  // Dialog nhập OTP và đặt lại mật khẩu mới
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
                style: TextStyle(color: appColors.text),
                decoration: InputDecoration(
                  labelText: l10n.emailVerificationLabel,
                  labelStyle: TextStyle(color: appColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: appColors.text),
                decoration: InputDecoration(
                  labelText: l10n.otpLabel,
                  labelStyle: TextStyle(color: appColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: appColors.text),
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
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
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
              FocusManager.instance.primaryFocus?.unfocus();
              final email = emailController.text.trim();
              final otp = otpController.text.trim();
              final newPw = newPasswordController.text.trim();

              if (email.isNotEmpty && otp.isNotEmpty && newPw.isNotEmpty) {
                ref
                    .read(authProvider.notifier)
                    .resetPasswordWithOtp(email, otp, newPw);
                Navigator.pop(context);

                AppToast.showSuccess(
                  context,
                  l10n.resetPasswordSuccess,
                  appColors,
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
