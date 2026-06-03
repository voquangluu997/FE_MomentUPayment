import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth_provider.dart';
import '../../../../core/utils/app_toast.dart'; // ✨ Thêm import Toast cute đồng bộ cho app nha!
import 'package:flutter/cupertino.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✨ Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    // 🔥 TẮT BÀN PHÍM XUỐNG NGAY LẬP TỨC
    FocusManager.instance.primaryFocus?.unfocus();

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final appColors = ref.read(appColorsProvider);

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      // ✨ Thay thế SnackBar cảnh báo trống trường bằng AppToast.showError
      AppToast.showError(context, l10n.emptyFieldsWarning, appColors);
      return;
    }

    ref.read(authProvider.notifier).register(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final appColors = ref.watch(appColorsProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.registerSuccess) {
        // ✨ Toast ngôi sao lấp lánh khi đăng ký thành công tài khoản mới
        AppToast.showSuccess(
          context,
          'Đăng ký tài khoản thành công rùi! Đăng nhập thui nào 💕',
          appColors,
        );
        ref.read(authProvider.notifier).resetState();
        Navigator.of(context).pop();
      } else if (next == AuthState.emailAlreadyExists) {
        // ✨ Toast trái tim tan vỡ kèm icon cute khi trùng email
        AppToast.showError(
          context,
          'Email này đã được đăng ký trước đó rồi bạn ơi! 🌸',
          appColors,
        );
        ref.read(authProvider.notifier).resetState();
      } else if (next == AuthState.registerError) {
        // ✨ Toast trái tim vỡ báo lỗi hệ thống / lỗi kết nối BE
        AppToast.showError(
          context,
          'Đăng ký thất bại! Vui lòng kiểm tra lại kết nối BE hoặc log hệ thống 😢',
          appColors,
        );
        ref.read(authProvider.notifier).resetState();
      }
    });

    // 🔥 BỌC GESTURE DETECTOR ĐỂ TẮT BÀN PHÍM KHI CHẠM RA NGOÀI
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_back, color: appColors.primary),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Cuộn mượt mà chuẩn iOS
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🌸 ĐIỂM NHẤN THỊ GIÁC (Icon Header)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.person_badge_plus,
                      size: 56,
                      color: appColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  l10n.loginCreateAccountTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: appColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginCreateAccountSub,
                  style: TextStyle(
                    fontSize: 15,
                    color: appColors.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 🌸 NÂNG CẤP: Họ tên
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    color: appColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    labelStyle: TextStyle(color: appColors.textMuted),
                    hintText: l10n.nameHint,
                    prefixIcon: Icon(
                      CupertinoIcons.person,
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
                const SizedBox(height: 16),

                // 🌸 NÂNG CẤP: Email
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
                const SizedBox(height: 16),

                // 🌸 NÂNG CẤP: Mật khẩu (Có nút Show/Hide)
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
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
                const SizedBox(height: 32),

                // 🌸 NÂNG CẤP: Nút Đăng ký (Đồng bộ với LoginScreen)
                ElevatedButton(
                  onPressed: authState == AuthState.loading
                      ? null
                      : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor:
                        Colors.white, // Text color luôn màu trắng để nổi bật
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
                          l10n.registerButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
