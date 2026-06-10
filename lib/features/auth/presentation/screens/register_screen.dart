import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth_provider.dart';
import '../../../../core/utils/app_toast.dart';

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
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusManager.instance.primaryFocus?.unfocus();

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final appColors = ref.read(appColorsProvider);

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
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
        AppToast.showSuccess(context, l10n.registerSuccessMsg, appColors);
        ref.read(authProvider.notifier).resetState();
        Navigator.of(context).pop();
      } else if (next == AuthState.emailAlreadyExists) {
        AppToast.showError(context, l10n.emailExistsError, appColors);
        ref.read(authProvider.notifier).resetState();
      } else if (next == AuthState.registerError) {
        AppToast.showError(context, l10n.registerFailedError, appColors);
        ref.read(authProvider.notifier).resetState();
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons
                  .arrow_back_ios_new_rounded, // Đổi sang icon bo tròn tinh tế hơn
              color: appColors.text,
              size: 22,
            ),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 12.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🌟 TYPOGRAPHY MỀM MẠI (Đồng bộ với Login)
                        Center(
                          child: Text(
                            l10n.loginCreateAccountTitle,
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
                            l10n.loginCreateAccountSub,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: appColors.textMuted,
                              letterSpacing: 0.2,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // 🌟 TEXTFIELDS BO TRÒN (PILL-SHAPE)
                        _buildCustomTextField(
                          controller: _nameController,
                          label: l10n.name,
                          hint: l10n.nameHint,
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          appColors: appColors,
                        ),
                        const SizedBox(height: 20),

                        _buildCustomTextField(
                          controller: _emailController,
                          label: l10n.email,
                          hint: l10n.emailHint,
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          appColors: appColors,
                        ),
                        const SizedBox(height: 20),

                        _buildCustomTextField(
                          controller: _passwordController,
                          label: l10n.password,
                          hint: l10n.passwordHint,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleRegister(),
                          appColors: appColors,
                        ),

                        const SizedBox(height: 50),

                        // 🌟 NÚT ĐĂNG KÝ (THÊM BÓNG ĐỔ SANG TRỌNG)
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
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColors.primary,
                                    foregroundColor: appColors.background,
                                    elevation: 0, // Tắt elevation mặc định
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ), // Bo tròn tuyệt đối
                                    ),
                                  ),
                                  child: Text(
                                    l10n.registerButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),

                        const Spacer(), // Đẩy phần nội dung lên trên, tạo khoảng trống thanh lịch phía dưới
                        const SizedBox(height: 24),
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

  // 💡 HELPER: Hàm tạo TextField bo tròn tinh tế (Đồng bộ chuẩn 100% với LoginScreen)
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required dynamic appColors,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
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
        fillColor: appColors.cardBackground.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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
}
