
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

    final String firstName = auth.user?['user']?['first_name'] ?? '';
    final String lastName = auth.user?['user']?['last_name'] ?? '';
    final String fullName = '$firstName $lastName'.trim().isNotEmpty 
        ? '$firstName $lastName'.trim() 
        : (auth.username ?? 'Omar Hussein');
        
    final String? avatarUrl = auth.user?['profile_picture'] ?? auth.user?['user']?['profile_picture'] ?? auth.user?['avatar'];

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        color: Colors.white,
        child: Column(
          children: [
            // TOP TIER: Logo and Profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Far Left: App Logo
                const AppLogo(scale: 0.85, withAnimation: false),

                // Far Right: User Area & Notification
                Row(
                  children: [
                    // Notification Bell (Emerald Green)
                    const _NotificationBtn(),
                    SizedBox(width: 12.w),
                    
                    // Profile Section
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lang.locale == 'ar' ? 'أهلاً،' : 'Welcome,',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    fullName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.slate900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 16.w, color: AppColors.slate500),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: AppColors.primary100,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage('$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}') as ImageProvider
                                : null,
                            child: avatarUrl == null
                                ? Icon(Icons.person_rounded, color: AppColors.primary600, size: 24.w)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
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
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_active_rounded,
                size: 22.w, color: AppColors.primary600),
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
                        color: Colors.white,
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
