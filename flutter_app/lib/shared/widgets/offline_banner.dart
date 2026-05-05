import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/connectivity_service.dart';

/// Shows a slim animated banner at the top of any screen when offline.
/// Automatically hides when connectivity is restored.
///
/// Usage: wrap your body with [OfflineBanner] + [child]:
///   Stack(children: [child, const OfflineBanner()])
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectivityProvider);

    return conn.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return _BannerContent();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: const Color(0xFF1E293B),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 14.w,
                  color: Colors.white.withAlpha(180),
                ),
                SizedBox(width: 8.w),
                Text(
                  'أنت غير متصل • البيانات المعروضة محفوظة مسبقاً',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withAlpha(200),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .slideY(begin: -1, end: 0, duration: 300.ms, curve: Curves.easeOut)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
