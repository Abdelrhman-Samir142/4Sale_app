import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.ctaText,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                width: 120.w,
                height: 120.w,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: const BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon!,
                  size: 64.w,
                  color: AppColors.primary600,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.getTextTheme('en').headlineMedium?.copyWith(
                    color: AppColors.slate900,
                  ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            SizedBox(height: 12.h),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.getTextTheme('en').bodyLarge?.copyWith(
                    color: AppColors.slate500,
                  ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            if (ctaText != null && onCtaPressed != null) ...[
              SizedBox(height: 32.h),
              AppButton(
                text: ctaText!,
                onPressed: onCtaPressed,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ]
          ],
        ),
      ),
    );
  }
}
