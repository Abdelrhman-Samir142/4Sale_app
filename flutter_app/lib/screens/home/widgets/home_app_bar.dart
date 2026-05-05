import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/notifications_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final auth = ref.watch(authProvider);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
        child: Row(
          children: [
            // Logo
            const AppLogo(scale: 0.8, withAnimation: false),
            SizedBox(width: 12.w),
            // Greeting + Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang.locale == 'ar' ? 'أهلاً' : 'Welcome',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text('👋', style: TextStyle(fontSize: 13.sp)),
                    ],
                  ),
                  Text(
                    auth.username ?? '4Sale',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Search button
            _IconBtn(
              icon: Icons.search_rounded,
              onTap: () => context.push('/search'),
            ),
            // Notifications button with badge
            const _NotificationBtn(),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
    );
  }
}

// ── Icon button ──────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEF0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.w, color: AppColors.slate600),
      ),
    );
  }
}

// ── Notification button with live badge ─────────────────────────────────
class _NotificationBtn extends ConsumerWidget {
  const _NotificationBtn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadNotificationsProvider);
    final unreadCount = unreadAsync.asData?.value ?? 0;

    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEF0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 20.w, color: AppColors.slate600),
            if (unreadCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints:
                      BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    shape: unreadCount < 10
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius:
                        unreadCount >= 10 ? BorderRadius.circular(8.r) : null,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
