import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';

class AppSearchBar extends ConsumerWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Integrated emerald green magnifying glass
            Icon(Icons.search_rounded, color: AppColors.primary600, size: 22.w),
            SizedBox(width: 12.w),
            
            // Text prompt
            Expanded(
              child: Text(
                lang.locale == 'ar' ? 'ابحث عن المنتجات والمزادات...' : 'Search products & auctions...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Single, simplified emerald green Camera icon
            GestureDetector(
              onTap: () => context.push('/visual-search'),
              child: Icon(Icons.camera_alt_rounded, color: AppColors.primary600, size: 22.w),
            ),
          ],
        ),
      ),
    );
  }
}
