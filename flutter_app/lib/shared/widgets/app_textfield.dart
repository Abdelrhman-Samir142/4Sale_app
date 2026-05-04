import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.errorText,
    this.onChanged,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    Color borderColor = AppColors.slate200;
    if (hasError) {
      borderColor = AppColors.errorRed;
    } else if (_hasFocus) {
      borderColor = AppColors.primary600;
    }

    Widget textField = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.readOnly ? AppColors.slate50 : Colors.white,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: borderColor,
          width: _hasFocus || hasError ? 1.5 : 1.0,
        ),
        boxShadow: _hasFocus && !hasError
            ? [
                BoxShadow(
                  color: AppColors.primary600.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _obscureText : false,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        style: AppTypography.getTextTheme('en').bodyLarge?.copyWith(
              color: AppColors.slate900,
            ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.getTextTheme('en').bodyLarge?.copyWith(
                color: AppColors.slate400,
              ),
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color: _hasFocus ? AppColors.primary600 : AppColors.slate400,
                    size: 20.w,
                  ),
                  child: widget.prefixIcon!,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.slate400,
                    size: 20.w,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );

    if (hasError) {
      textField = textField
          .animate(key: ValueKey(widget.errorText))
          .shakeX(hz: 8, amount: 4, duration: 400.ms);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField,
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: AppTypography.getTextTheme('en').labelSmall?.copyWith(
                  color: AppColors.errorRed,
                ),
          ).animate().fadeIn().slideY(begin: -0.5, duration: 200.ms),
        ]
      ],
    );
  }
}
