import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:moment_u_payment/features/auth/presentation/widgets/aurora_background.dart';
import 'package:moment_u_payment/features/auth/presentation/widgets/auth_bottom_sheets.dart';
import 'package:moment_u_payment/features/auth/presentation/widgets/unified_text_field.dart';
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
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.loginSuccess) {
        Future.microtask(() {
          ref.read(authProvider.notifier).completeLogin();
        });
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth_check', (route) => false);
      } else if (next == AuthState.loginError) {
        AppToast.showError(context, l10n.loginErrorNotification, appColors);
        Future.microtask(() => ref.read(authProvider.notifier).resetState());
      } else if (next == AuthState.googleLoginError) {
        AppToast.showError(
          context,
          l10n.googleLoginErrorNotification,
          appColors,
        );
        Future.microtask(() => ref.read(authProvider.notifier).resetState());
      } else if (next == AuthState.appleLoginError) {
        AppToast.showError(
          context,
          l10n.appleLoginErrorNotification,
          appColors,
        );
        Future.microtask(() => ref.read(authProvider.notifier).resetState());
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // 🚀 SỬ DỤNG AURORA BACKGROUND
        body: AuroraBackground(
          primaryColor: appColors.primary,
          backgroundColor: appColors.background,
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
                        const SizedBox(height: 10),

                        // 🌟 TITLE & SLOGAN
                        Builder(
                          builder: (context) {
                            final titleParts = l10n.subTitle.split(' - ');
                            final appName = titleParts.isNotEmpty
                                ? titleParts[0]
                                : 'Moments U';
                            final slogan = titleParts.length > 1
                                ? titleParts[1]
                                : '';

                            return Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      appColors.primary,
                                      const Color(0xFFE040FB),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    appName,
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 38,
                                      letterSpacing: -1.5,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                if (slogan.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: appColors.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.sparkles,
                                          size: 16,
                                          color: appColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          slogan,
                                          style: textTheme.labelLarge?.copyWith(
                                            color: appColors.primary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 48),

                        // 🌟 UNIFIED INPUT CARD (GLASSMORPHISM)
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
                              // 🚀 SỬ DỤNG UNIFIED TEXTFIELD ĐÃ TÁCH
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
                                onSubmitted: (_) => _handleLogin(),
                                appColors: appColors,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🌟 QUÊN MẬT KHẨU
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              AuthBottomSheets.showForgotPasswordSheet(
                                context,
                                ref,
                                appColors,
                                l10n,
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.forgotPasswordText,
                              style: TextStyle(
                                color: appColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 🌟 NÚT ĐĂNG NHẬP
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
                                      borderRadius: BorderRadius.circular(20),
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

                        // 🌟 OR DIVIDER
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
                                  fontWeight: FontWeight.w500,
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

                        // 🌟 BENTO GRID SOCIAL LOGIN
                        Row(
                          children: [
                            // Nút Google
                            Expanded(
                              child: OutlinedButton(
                                onPressed: authState == AuthState.loading
                                    ? null
                                    : () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        ref
                                            .read(authProvider.notifier)
                                            .loginWithGoogle();
                                      },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: appColors.background
                                      .withValues(alpha: 0.5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                  side: BorderSide(
                                    color: appColors.textMuted.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://developers.google.com/static/identity/images/g-logo.png',
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Google",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: appColors.text,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Nút Apple (Chỉ hiện trên iOS/MacOS)
                            if (Platform.isIOS || Platform.isMacOS) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 0,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        size: 24,
                                        color: appColors.background,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "Apple",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: appColors.background,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 36),

                        // 🌟 ĐĂNG KÝ
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                            top: 24.0,
                          ),
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.dontHaveAccount,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: appColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: appColors.primary,
                                  height: 1.5,
                                ),
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
}
