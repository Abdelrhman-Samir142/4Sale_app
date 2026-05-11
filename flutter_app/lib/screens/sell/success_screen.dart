import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC), // Light background
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Circular Container
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.auctionOrange.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        size: 64.w,
                        color: AppColors.auctionOrange,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    
                    SizedBox(height: 24.h),
                    
                    // Title
                    Text(
                      isAr ? 'تم رفع إعلانك بنجاح!' : 'Ad Uploaded Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    
                    SizedBox(height: 12.h),
                    
                    // Subtitle
                    Text(
                      isAr 
                        ? 'إعلانك قيد المراجعة من فريق الإدارة. هتوصلك إشعار فور الموافقة عليه وسيظهر في المتجر للمشترين.' 
                        : 'Your ad is under review by administration. You will receive a notification upon approval and it will appear in the store for buyers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.slate500,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    
                    SizedBox(height: 24.h),

                    // Info Box
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppColors.auctionOrange, size: 20.w),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              isAr ? 'عادةً بتتم المراجعة خلال دقائق' : 'Review is usually completed within minutes',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.auctionOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    
                    SizedBox(height: 32.h),
                    
                    // Action Buttons (Row)
                    Row(
                      children: [
                        // Primary Button
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => context.go('/store'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary700,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                isAr ? 'الذهاب للمتجر' : 'Go to Store',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Secondary Button
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: OutlinedButton(
                              onPressed: () => context.go('/sell'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary700,
                                side: BorderSide(color: AppColors.primary200, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                isAr ? 'إضافة منتج آخر' : 'Add Another',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
