import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'global_keys.dart';

/// Centralized snackbar helper to replace all scattered SnackBar calls.
/// Provides consistent styling, haptic feedback, and professional appearance.
class AppSnackbar {
  AppSnackbar._();

  static void showGlobal(String message, {Color color = AppColors.primary600, IconData icon = Icons.notifications_active_rounded}) {
    final state = GlobalKeys.scaffoldMessengerKey.currentState;
    if (state == null) return;
    state.clearSnackBars();
    state.showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18.w),
        SizedBox(width: 10.w),
        Expanded(child: Text(message, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      duration: const Duration(seconds: 4),
    ));
  }

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.successGreen, Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.errorRed, Icons.error_outline_rounded);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, AppColors.warningAmber, Icons.warning_amber_rounded);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.latestBlue, Icons.info_outline_rounded);
  }

  /// Undo snackbar — shows a message with an undo action.
  static void undo(BuildContext context, String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.undo_rounded, color: Theme.of(context).cardColor, size: 18.w),
        SizedBox(width: 10.w),
        Expanded(child: Text(message, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500))),
      ]),
      action: SnackBarAction(label: 'UNDO', textColor: Theme.of(context).cardColor, onPressed: onUndo),
      backgroundColor: AppColors.slate800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      duration: const Duration(seconds: 4),
    ));
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Theme.of(context).cardColor, size: 18.w),
        SizedBox(width: 10.w),
        Expanded(child: Text(message, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      duration: const Duration(seconds: 3),
    ));
  }
}
