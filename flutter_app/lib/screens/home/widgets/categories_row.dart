import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

class CategoriesRow extends StatelessWidget {
  final LanguageState lang;

  const CategoriesRow({super.key, required this.lang});

  static const _categoryKeys = [
    'electronics',
    'furniture',
    'scrap',
    'fashion',
    'vehicles',
    'books'
  ];

  List<_CategoryItem> _buildCategories() {
    final dict = lang.dict['categories'] as Map<String, dynamic>;
    return [
      _CategoryItem(
        icon: Icons.devices_rounded,
        label: dict['electronics'] as String,
        color: AppColors.latestBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _CategoryItem(
        icon: Icons.chair_rounded,
        label: dict['furniture'] as String,
        color: AppColors.warningAmber,
        bgColor: const Color(0xFFFFFBEB),
      ),
      _CategoryItem(
        icon: Icons.recycling_rounded,
        label: dict['scrap'] as String,
        color: AppColors.successGreen,
        bgColor: const Color(0xFFF0FDF4),
      ),
      _CategoryItem(
        icon: Icons.checkroom_rounded,
        label: dict['fashion'] as String,
        color: AppColors.recommendedPurple,
        bgColor: const Color(0xFFFAF5FF),
      ),
      _CategoryItem(
        icon: Icons.directions_car_rounded,
        label: dict['vehicles'] as String,
        color: AppColors.auctionOrange,
        bgColor: const Color(0xFFFFF7ED),
      ),
      _CategoryItem(
        icon: Icons.menu_book_rounded,
        label: dict['books'] as String,
        color: AppColors.primary600,
        bgColor: AppColors.primary50,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = _buildCategories();
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => context.push(
              '/search?category=${_categoryKeys[i]}&label=${cat.label}',
            ),
            child: Container(
              width: 82.w,
              margin: EdgeInsets.only(right: 10.w),
              child: Column(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: cat.bgColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: cat.color.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(cat.icon, size: 26.w, color: cat.color),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: 100 + (i * 60)),
                  duration: 300.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                delay: Duration(milliseconds: 100 + (i * 60)),
              );
        },
      ),
    );
  }
}
