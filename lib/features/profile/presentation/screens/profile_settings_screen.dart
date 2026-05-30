import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/transaction/data/transaction_repository.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPwController = TextEditingController();
  final _newPwController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<IconData> _avatarIcons = [
    Icons.pets_rounded,
    Icons.face_retouching_natural_rounded,
    Icons.emoji_people_rounded,
    Icons.face_rounded,
    Icons.psychology_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userInfoProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPwController.dispose();
    _newPwController.dispose();
    super.dispose();
  }

  IconData _getAvatarIcon(String userId) {
    return _avatarIcons[userId.hashCode % _avatarIcons.length];
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  /// Map các lỗi API sang key l10n
  String _getLocalizedErrorMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('wrong password') ||
        lowerError.contains('incorrect password') ||
        lowerError.contains('mật khẩu không đúng')) {
      return l10n.wrongOldPassword;
    }
    if (lowerError.contains('user not found') ||
        lowerError.contains('invalid user')) {
      return l10n.userNotFoundError;
    }
    if (lowerError.contains('weak password')) {
      return l10n.weakPasswordError;
    }
    return error;
  }

  Future<void> _handleUpdateProfile(AppLocalizations l10n) async {
    final appColors = ref.read(appColorsProvider);
    final user = ref.read(userInfoProvider);

    final hasNameChanged = _nameController.text.trim() != (user?.name ?? '');
    final hasImageChanged = _selectedImage != null;

    if (!hasNameChanged && !hasImageChanged) {
      AppToast.showSuccess(context, l10n.noChangeWarning, appColors);
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      AppToast.showError(context, l10n.nameEmptyError, appColors);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imageUrl = user?.avatar;
      if (_selectedImage != null) {
        imageUrl = await ref
            .read(transactionRepositoryProvider)
            .uploadInvoiceImage(_selectedImage!.path);
      }

      final errorMessage = await ref
          .read(authProvider.notifier)
          .updateProfile(_nameController.text.trim(), imageUrl);

      if (errorMessage == null) {
        if (mounted) {
          AppToast.showSuccess(context, l10n.updateSuccess, appColors);
        }
        setState(() => _selectedImage = null);
      } else {
        if (mounted) {
          AppToast.showError(
            context,
            _getLocalizedErrorMessage(errorMessage, l10n),
            appColors,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, l10n.systemError, appColors);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpdatePassword(AppLocalizations l10n) async {
    final appColors = ref.read(appColorsProvider);

    if (_oldPwController.text.isEmpty || _newPwController.text.isEmpty) {
      AppToast.showError(context, l10n.fillPasswordFieldsError, appColors);
      return;
    }

    if (_oldPwController.text.length < 4 || _newPwController.text.length < 4) {
      AppToast.showError(context, l10n.passwordLengthError, appColors);
      return;
    }

    if (_oldPwController.text == _newPwController.text) {
      AppToast.showError(context, l10n.samePasswordError, appColors);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final errorMessage = await ref
          .read(authProvider.notifier)
          .updatePassword(_oldPwController.text, _newPwController.text);

      if (errorMessage == null) {
        if (mounted) {
          AppToast.showSuccess(context, l10n.updateSuccess, appColors);
        }
        _oldPwController.clear();
        _newPwController.clear();
      } else {
        if (mounted) {
          AppToast.showError(
            context,
            _getLocalizedErrorMessage(errorMessage, l10n),
            appColors,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, l10n.systemError, appColors);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userInfoProvider);
    final userId = user?.email ?? "default_user";
    final userIcon = _getAvatarIcon(userId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.primaryDark),
            onPressed: _navigateToHome,
          ),
          title: Text(
            l10n.accountSettings,
            style: TextStyle(color: appColors.primaryDark),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildSettingsCard(
                title: l10n.personalInfo,
                appColors: appColors,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: appColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appColors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : (user?.avatar != null && user!.avatar!.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  user.avatar!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        userIcon,
                                        size: 50,
                                        color: appColors.primary,
                                      ),
                                ),
                              )
                            : Icon(
                                userIcon,
                                size: 50,
                                color: appColors.primary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    l10n.email,
                    _emailController,
                    appColors,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(l10n.fullName, _nameController, appColors),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    l10n.updateProfile,
                    () => _handleUpdateProfile(l10n),
                    appColors,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsCard(
                title: l10n.security,
                appColors: appColors,
                children: [
                  _buildTextField(
                    l10n.currentPassword,
                    _oldPwController,
                    appColors,
                    isPassword: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    l10n.newPassword,
                    _newPwController,
                    appColors,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    l10n.updatePassword,
                    () => _handleUpdatePassword(l10n),
                    appColors,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required AppColorTheme appColors,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: appColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    AppColorTheme appColors, {
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      style: TextStyle(color: enabled ? appColors.text : appColors.textMuted),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: appColors.textMuted),
        filled: true,
        fillColor: enabled ? appColors.background : appColors.cardBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: appColors.textMuted.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: appColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed,
    AppColorTheme appColors,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
