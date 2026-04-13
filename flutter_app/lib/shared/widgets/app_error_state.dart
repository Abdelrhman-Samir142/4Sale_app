import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String retryText;

  const AppErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.retryText = "Try Again",
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
            Container(
              width: 120.w,
              height: 120.w,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64.w,
                color: AppColors.errorRed,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            Text(
              "Oops, something went wrong!",
              textAlign: TextAlign.center,
              style: AppTypography.getTextTheme('en').titleLarge?.copyWith(
                    color: AppColors.slate900,
                  ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            SizedBox(height: 12.h),

            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.getTextTheme('en').bodyMedium?.copyWith(
                    color: AppColors.slate500,
                  ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            SizedBox(height: 32.h),

            AppButton.secondary(
              text: retryText,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
