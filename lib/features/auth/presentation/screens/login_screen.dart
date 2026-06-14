import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  bool _isPasswordVisible = false;

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

  // 💡 HÀM HELPER: Dịch Error Key từ Backend thành Đa ngôn ngữ từ file ARB
  String _translateErrorMessage(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'error_email_already_exists':
        return l10n.errorEmailAlreadyExists;
      case 'error_invalid_credentials':
        return l10n.errorInvalidCredentials;
      case 'error_google_linked':
        return l10n.errorGoogleLinked;
      case 'error_email_not_found':
        return l10n.errorEmailNotFound;
      case 'error_invalid_account':
        return l10n.errorInvalidAccount;
      case 'error_invalid_otp':
        return l10n.errorInvalidOtp;
      case 'error_missing_password':
        return l10n.errorMissingPassword;
      case 'error_incorrect_old_password':
        return l10n.errorIncorrectOldPassword;
      case 'error_user_not_found':
        return l10n.errorUserNotFound;
      default:
        return l10n.errorDefault;
    }
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
      } else if (next == AuthState.appleLoginError) {
        AppToast.showError(
          context,
          l10n.appleLoginErrorNotification, // Hãy đảm bảo bạn đã thêm key này vào l10n
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),

                        // 🌟 TYPOGRAPHY MỀM MẠI, THANH LỊCH
                        Center(
                          child: Text(
                            l10n.welcomeBack,
                            style: TextStyle(
                              fontSize: 32,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: appColors.primary,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            l10n.subTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: appColors.textMuted,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // 🌟 TEXTFIELDS BO TRÒN (PILL-SHAPE)
                        _buildCustomTextField(
                          controller: _emailController,
                          label: l10n.email,
                          hint: l10n.emailHint,
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          appColors: appColors,
                        ),
                        const SizedBox(height: 20),
                        _buildCustomTextField(
                          controller: _passwordController,
                          label: l10n.password,
                          hint: l10n.passwordHint,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          appColors: appColors,
                        ),

                        const SizedBox(height: 12),

                        // 🌟 HÀNG NÚT QUÊN MẬT KHẨU VÀ ĐẶT LẠI MẬT KHẨU
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _showResetPasswordSheet(
                                  context,
                                  appColors,
                                  l10n,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.resetPasswordText,
                                style: TextStyle(
                                  color: appColors.textMuted.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _showForgotPasswordSheet(
                                  context,
                                  appColors,
                                  l10n,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.forgotPasswordText,
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // 🌟 NÚT ĐĂNG NHẬP (THÊM BÓNG ĐỔ SANG TRỌNG)
                        authState == AuthState.loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    appColors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: appColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColors.primary,
                                    foregroundColor: appColors.background,
                                    elevation: 0,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.loginButtonText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 36),

                        // 🌟 OR DIVIDER MỎNG, TINH TẾ
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: appColors.textMuted.withValues(
                                  alpha: 0.15,
                                ),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n.orContinueWith,
                                style: TextStyle(
                                  color: appColors.textMuted.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: appColors.textMuted.withValues(
                                  alpha: 0.15,
                                ),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 🌟 NHÓM NÚT SOCIAL LOGIN
                        OutlinedButton(
                          onPressed: authState == AuthState.loading
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  ref
                                      .read(authProvider.notifier)
                                      .loginWithGoogle();
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: appColors.background,
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 0,
                            side: BorderSide(
                              color: appColors.textMuted.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
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
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: appColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (Platform.isIOS || Platform.isMacOS) ...[
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: authState == AuthState.loading
                                ? null
                                : () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    ref
                                        .read(authProvider.notifier)
                                        .loginWithApple();
                                  },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appColors.text,
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 0,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apple,
                                  size: 26,
                                  color: appColors.background,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.loginAppleButtonText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: appColors.background,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Spacer(),

                        // 🌟 ĐĂNG KÝ (RICHTEXT CHUẨN)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 14,
                                  fontFamily:
                                      'Roboto', // Đảm bảo khớp fontFamily của app
                                ),
                                children: [
                                  TextSpan(
                                    text: l10n.dontHaveAccount,
                                    style: TextStyle(
                                      color: appColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 💡 HELPER: WIDGET TEXTFIELD BO TRÒN TINH TẾ CHO MAIN SCREEN
  // =========================================================================
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required dynamic appColors,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: TextStyle(
        color: appColors.text,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: appColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: appColors.textMuted.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(
            icon,
            color: appColors.textMuted.withValues(alpha: 0.6),
            size: 22,
          ),
        ),
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: appColors.textMuted.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              )
            : null,
        filled: true,
        fillColor: appColors.cardBackground.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: appColors.textMuted.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: appColors.textMuted.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: appColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // =========================================================================
  // 💡 BOTTOM SHEET: QUÊN MẬT KHẨU
  // =========================================================================
  void _showForgotPasswordSheet(
    BuildContext context,
    dynamic appColors,
    AppLocalizations l10n,
  ) {
    final forgotEmailController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            return Container(
              decoration: BoxDecoration(
                color: appColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 32,
                right: 32,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: appColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.forgotPasswordTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: appColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.forgotPasswordSubtitle, // Có thể map: "Nhập email của bạn để nhận mã khôi phục"
                    style: TextStyle(fontSize: 14, color: appColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Text Field cục bộ cho Sheet
                  TextFormField(
                    controller: forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: appColors.text),
                    decoration: InputDecoration(
                      labelText: l10n.emailAccountLabel,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: appColors.textMuted,
                      ),
                      filled: true,
                      fillColor: appColors.cardBackground.withValues(
                        alpha: 0.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appColors.primary,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final email = forgotEmailController.text.trim();

                            if (email.isEmpty) {
                              AppToast.showError(
                                context,
                                l10n.emptyFieldsWarning,
                                appColors,
                              );
                              return;
                            }

                            setStateSheet(() => isLoading = true);
                            final errorKey = await ref
                                .read(authProvider.notifier)
                                .forgotPassword(email);
                            setStateSheet(() => isLoading = false);

                            if (!context.mounted) return;

                            if (errorKey == null) {
                              // Tắt sheet hiện tại và mở thẳng sheet Reset
                              Navigator.pop(context);
                              AppToast.showSuccess(
                                context,
                                '${l10n.sendCodeSuccess} $email', // Đảm bảo l10n có biến này
                                appColors,
                              );
                              _showResetPasswordSheet(
                                context,
                                appColors,
                                l10n,
                                initialEmail: email,
                              );
                            } else {
                              final localizedError = _translateErrorMessage(
                                errorKey,
                                l10n,
                              );
                              AppToast.showError(
                                context,
                                localizedError,
                                appColors,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors.primary,
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            l10n.sendCodeButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 💡 BOTTOM SHEET: ĐẶT LẠI MẬT KHẨU BẰNG OTP
  // =========================================================================
  void _showResetPasswordSheet(
    BuildContext context,
    dynamic appColors,
    AppLocalizations l10n, {
    String? initialEmail,
  }) {
    final emailController = TextEditingController(text: initialEmail ?? '');
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();

    bool isLoading = false;
    bool isSheetPasswordVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            return Container(
              decoration: BoxDecoration(
                color: appColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 32,
                right: 32,
                top: 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: appColors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.resetPasswordTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: appColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: appColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.emailVerificationLabel,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: appColors.textMuted,
                        ),
                        filled: true,
                        fillColor: appColors.cardBackground.withValues(
                          alpha: 0.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: appColors.text,
                        letterSpacing: 4.0,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.otpLabel,
                        prefixIcon: Icon(
                          Icons.pin_outlined,
                          color: appColors.textMuted,
                        ),
                        filled: true,
                        fillColor: appColors.cardBackground.withValues(
                          alpha: 0.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !isSheetPasswordVisible,
                      style: TextStyle(color: appColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.newPasswordLabel,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: appColors.textMuted,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              isSheetPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: appColors.textMuted,
                            ),
                            onPressed: () {
                              setStateSheet(
                                () => isSheetPasswordVisible =
                                    !isSheetPasswordVisible,
                              );
                            },
                          ),
                        ),
                        filled: true,
                        fillColor: appColors.cardBackground.withValues(
                          alpha: 0.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                appColors.primary,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              final email = emailController.text.trim();
                              final otp = otpController.text.trim();
                              final newPw = newPasswordController.text.trim();

                              if (email.isEmpty ||
                                  otp.isEmpty ||
                                  newPw.isEmpty) {
                                AppToast.showError(
                                  context,
                                  l10n.emptyFieldsWarning,
                                  appColors,
                                );
                                return;
                              }

                              setStateSheet(() => isLoading = true);
                              final errorKey = await ref
                                  .read(authProvider.notifier)
                                  .resetPasswordWithOtp(email, otp, newPw);
                              setStateSheet(() => isLoading = false);

                              if (!context.mounted) return;

                              if (errorKey == null) {
                                Navigator.pop(context);
                                AppToast.showSuccess(
                                  context,
                                  l10n.resetPasswordSuccess,
                                  appColors,
                                );
                              } else {
                                final localizedError = _translateErrorMessage(
                                  errorKey,
                                  l10n,
                                );
                                AppToast.showError(
                                  context,
                                  localizedError,
                                  appColors,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.primary,
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              l10n.confirmButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
