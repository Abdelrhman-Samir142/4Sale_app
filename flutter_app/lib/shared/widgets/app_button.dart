import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import 'animated_press_wrapper.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final bgColor = _getBgColor();
    final fgColor = _getFgColor();
    final borderColor = _getBorderColor();

    final textStyle = AppTypography.getTextTheme('en').labelLarge?.copyWith(
      color: fgColor,
      fontWeight: FontWeight.w700,
    );

    Widget child = Text(
      text,
      style: textStyle,
    );

    if (isLoading) {
      child = SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: fgColor,
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: fgColor, size: 20.w),
            child: icon!,
          ),
          SizedBox(width: 8.w),
          child,
        ],
      );
    }

    final buttonNode = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        disabledBackgroundColor: bgColor.withAlpha(int.parse("150")), // fallback transparency
        disabledForegroundColor: fgColor.withAlpha(int.parse("150")),
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      ),
      child: child,
    );

    return AnimatedPressWrapper(child: buttonNode);
  }

  Color _getBgColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary600;
      case AppButtonVariant.secondary:
        return AppColors.slate100;
      case AppButtonVariant.outlined:
        return Colors.transparent;
      case AppButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getFgColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.slate900;
      case AppButtonVariant.outlined:
        return AppColors.primary600;
      case AppButtonVariant.text:
        return AppColors.primary600;
    }
  }

  Color? _getBorderColor() {
    if (variant == AppButtonVariant.outlined) {
      return AppColors.primary600;
    }
    return null;
  }
}
