import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UnifiedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final dynamic appColors; // Truyền appColors từ file constants của bạn
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  const UnifiedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.appColors,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<UnifiedTextField> createState() => _UnifiedTextFieldState();
}

class _UnifiedTextFieldState extends State<UnifiedTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_isPasswordVisible,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      style: TextStyle(
        color: widget.appColors.text,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: widget.appColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: widget.appColors.textMuted.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(
            widget.icon,
            color: widget.appColors.textMuted.withValues(alpha: 0.8),
            size: 20,
          ),
        ),
        suffixIcon: widget.isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    color: widget.appColors.textMuted.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              )
            : null,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
