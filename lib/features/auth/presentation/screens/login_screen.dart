import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Thêm import này cho RichText
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
                              fontSize: 32, // Nhỏ lại một chút
                              fontStyle:
                                  FontStyle.italic, // Tạo độ nghiêng mềm mại
                              fontWeight: FontWeight
                                  .w500, // Nhẹ nhàng hơn, không quá thô
                              color: appColors.primary,
                              // fontFamily: 'PlayfairDisplay', // 💡 Khuyên dùng: Tích hợp Google Fonts
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

                        // 🌟 NÚT QUÊN MẬT KHẨU
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _showForgotPasswordSheet(context);
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
                                color: appColors
                                    .textMuted, // Màu trầm lại để sang trọng hơn
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
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
                                      color: appColors.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(
                                        0,
                                        8,
                                      ), // Bóng đổ hắt xuống dưới
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColors.primary,
                                    foregroundColor: appColors.background,
                                    elevation:
                                        0, // Tắt elevation mặc định để dùng boxShadow
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ), // Pill-shape tuyệt đối
                                    ),
                                  ),
                                  child: Text(
                                    l10n.loginButtonText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing:
                                          1.2, // Chữ thưa ra một chút cho thoáng
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
                                color: appColors.textMuted.withOpacity(0.15),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Hoặc tiếp tục với',
                                style: TextStyle(
                                  color: appColors.textMuted.withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: appColors.textMuted.withOpacity(0.15),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // 🌟 NÚT GOOGLE TINH GỌN, BO TRÒN ĐỒNG BỘ
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
                              color: appColors.textMuted.withOpacity(0.2),
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

                        const Spacer(),

                        // 🌟 ĐÃ FIX LỖI RENDERFLEX (SỬ DỤNG RICHTEXT)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ), // Đảm bảo fontFamily khớp app
                                children: [
                                  TextSpan(
                                    text: l10n
                                        .dontHaveAccount, // Text: "Đăng ký ngay"
                                    style: TextStyle(
                                      color: appColors.primary,
                                      fontWeight: FontWeight.bold,
                                      // decoration: TextDecoration.underline, // Tùy chọn bỏ gạch chân cho thanh lịch hơn
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

  // 💡 HELPER: Cấu hình TextField bo tròn tinh tế
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
          color: appColors.textMuted.withOpacity(0.4),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(
            icon,
            color: appColors.textMuted.withOpacity(0.6),
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
                    color: appColors.textMuted.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              )
            : null,
        filled: true,
        fillColor: appColors.cardBackground.withOpacity(0.5), // Xuyên thấu nhẹ
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ), // Rộng rãi hơn
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ), // Bo tròn thành hình viên thuốc
          borderSide: BorderSide(
            color: appColors.textMuted.withOpacity(0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: appColors.textMuted.withOpacity(0.15),
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

  // ... (Giữ nguyên các hàm _showForgotPasswordSheet và _showResetPasswordSheet của bản trước,
  // chỉ cần thay borderRadius: BorderRadius.circular(20) thành BorderRadius.circular(30) bên trong các nút bấm của BottomSheet để đồng bộ).

  // 💡 Để code không quá dài, tôi xin giữ nguyên BottomSheet ở trên, bạn áp dụng lại nhé.

  void _showForgotPasswordSheet(BuildContext context) {
    // Tương tự bản trước, nhớ update ElevatedButton dùng borderRadius: BorderRadius.circular(30)
  }

  void _showResetPasswordSheet(BuildContext context) {
    // Tương tự bản trước, nhớ update ElevatedButton dùng borderRadius: BorderRadius.circular(30)
  }
}
