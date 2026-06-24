import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/app_toast.dart';
import '../auth_provider.dart';

class AuthBottomSheets {
  // 💡 HÀM HELPER: Dịch Error Key từ Backend thành Đa ngôn ngữ từ file ARB
  static String translateErrorMessage(String errorKey, AppLocalizations l10n) {
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

  // =========================================================================
  // 💡 BOTTOM SHEET: QUÊN MẬT KHẨU
  // =========================================================================
  static void showForgotPasswordSheet(
    BuildContext context,
    WidgetRef ref,
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
                    l10n.forgotPasswordSubtitle,
                    style: TextStyle(fontSize: 14, color: appColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: appColors.text),
                    decoration: InputDecoration(
                      labelText: l10n.emailAccountLabel,
                      prefixIcon: Icon(
                        CupertinoIcons.mail,
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
                              Navigator.pop(context);
                              AppToast.showSuccess(
                                context,
                                '${l10n.sendCodeSuccess} $email',
                                appColors,
                              );
                              showResetPasswordSheet(
                                context,
                                ref,
                                appColors,
                                l10n,
                                initialEmail: email,
                              );
                            } else {
                              final localizedError = translateErrorMessage(
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
  static void showResetPasswordSheet(
    BuildContext context,
    WidgetRef ref,
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
                          CupertinoIcons.mail,
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
                          CupertinoIcons.number,
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
                          CupertinoIcons.lock,
                          color: appColors.textMuted,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              isSheetPasswordVisible
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
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
                                final localizedError = translateErrorMessage(
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
