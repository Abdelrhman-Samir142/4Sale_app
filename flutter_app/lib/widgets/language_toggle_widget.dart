import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../providers/language_provider.dart';

class LanguageToggleWidget extends ConsumerWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langState = ref.watch(languageProvider);
    final isAr = langState.locale == 'ar';

    return GestureDetector(
      onTap: () {
        ref.read(languageProvider.notifier).toggle();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 86.w,
              height: 44.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withAlpha(150), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Circular Sliding Highlight
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDFA), // Very soft Teal background
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Flags Row
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: !isAr ? 1.0 : 0.4,
                            child: Text(
                              '🇺🇸',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isAr ? 1.0 : 0.4,
                            child: Text(
                              '🇪🇬',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
    );
  }
}
