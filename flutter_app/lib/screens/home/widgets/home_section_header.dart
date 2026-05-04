import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onAction;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.icon,
    required this.accentColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.w, color: accentColor),
          ),
          SizedBox(width: 8.w),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const Spacer(),
          // View all button
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10.w, color: accentColor),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
