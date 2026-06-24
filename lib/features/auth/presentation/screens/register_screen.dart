import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/features/auth/presentation/widgets/aurora_background.dart';
import 'package:moment_u_payment/features/auth/presentation/widgets/unified_text_field.dart';
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
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.registerSuccess) {
        Future.microtask(() {
          AppToast.showSuccess(context, l10n.registerSuccessMsg, appColors);
          ref.read(authProvider.notifier).resetState();
          Navigator.of(context).pop();
        });
      } else if (next == AuthState.emailAlreadyExists) {
        Future.microtask(() {
          AppToast.showError(context, l10n.emailExistsError, appColors);
          ref.read(authProvider.notifier).resetState();
        });
      } else if (next == AuthState.registerError) {
        Future.microtask(() {
          AppToast.showError(context, l10n.registerFailedError, appColors);
          ref.read(authProvider.notifier).resetState();
        });
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.text,
              size: 22,
            ),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
          ),
        ),

        // 🚀 SỬ DỤNG AURORA BACKGROUND ĐÃ TÁCH
        body: AuroraBackground(
          primaryColor: appColors.primary,
          backgroundColor: appColors.background,
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
                        const SizedBox(height: 10),

                        // 🌟 TITLE
                        Text(
                          l10n.loginCreateAccountTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            letterSpacing: -1.0,
                            color: appColors.text,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🌟 SUBTITLE (Đã bổ sung đầy đủ)
                        Text(
                          l10n.loginCreateAccountSub,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: appColors.textMuted,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // 🌟 UNIFIED INPUT CARD THỜI THƯỢNG
                        Container(
                          decoration: BoxDecoration(
                            color: appColors.cardBackground.withValues(
                              alpha: 0.45,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: appColors.textMuted.withValues(
                                alpha: 0.12,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // 🚀 SỬ DỤNG TEXTFIELD ĐÃ TÁCH
                              UnifiedTextField(
                                controller: _nameController,
                                label: l10n.name,
                                hint: l10n.nameHint,
                                icon: CupertinoIcons.person,
                                textInputAction: TextInputAction.next,
                                appColors: appColors,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: appColors.textMuted.withValues(
                                  alpha: 0.12,
                                ),
                                indent: 48,
                                endIndent: 16,
                              ),
                              UnifiedTextField(
                                controller: _emailController,
                                label: l10n.email,
                                hint: l10n.emailHint,
                                icon: CupertinoIcons.mail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                appColors: appColors,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: appColors.textMuted.withValues(
                                  alpha: 0.12,
                                ),
                                indent: 48,
                                endIndent: 16,
                              ),
                              UnifiedTextField(
                                controller: _passwordController,
                                label: l10n.password,
                                hint: l10n.passwordHint,
                                icon: CupertinoIcons.lock,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleRegister(),
                                appColors: appColors,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // 🌟 NÚT ĐĂNG KÝ
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
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColors.primary,
                                    foregroundColor: appColors.background,
                                    elevation: 0,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
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

                        const Spacer(),
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
}
