import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth_provider.dart';
import '../../../../core/utils/app_toast.dart'; // ✨ Thêm import Toast cute đồng bộ cho app nha!

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
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

    // ✨ SỬA LỖI: Xác định Dark Mode chính xác dựa trên màu nền của Provider
    final isDark = appColors.background.computeLuminance() < 0.5;

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

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: appColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.loginCreateAccountTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginCreateAccountSub,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Họ tên
              TextField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: l10n.name,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  hintText: l10n.nameHint,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
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

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  hintText: l10n.emailHint,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
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

              // Mật khẩu
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: l10n.password,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  hintText: l10n.passwordHint,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: appColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              authState == AuthState.loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appColors.primary,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _handleRegister,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: appColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.registerButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
