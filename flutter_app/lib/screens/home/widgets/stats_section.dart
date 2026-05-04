import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.icon, required this.value, required this.label, required this.color});
}

class StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool loading;
  final Map<String, dynamic> dict;

  const StatsSection({super.key, required this.stats, required this.loading, required this.dict});

  @override
  Widget build(BuildContext context) {
    final statItems = [
      _StatItem(icon: Icons.people_rounded, value: stats['total_users']?.toString() ?? '0',
          label: dict['stats']['activeUsers'] as String, color: AppColors.primary600),
      _StatItem(icon: Icons.shopping_bag_rounded, value: stats['total_products']?.toString() ?? '0',
          label: dict['stats']['productsSold'] as String, color: AppColors.latestBlue),
      _StatItem(icon: Icons.gavel_rounded, value: stats['active_auctions']?.toString() ?? '0',
          label: dict['stats']['scrapTons'] as String, color: AppColors.auctionOrange),
      _StatItem(icon: Icons.location_on_rounded, value: '27',
          label: dict['stats']['governorates'] as String, color: AppColors.recommendedPurple),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 16, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: statItems.asMap().entries.map((entry) {
            final i = entry.key;
            final stat = entry.value;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40.w, height: 40.w,
                    decoration: BoxDecoration(color: stat.color.withAlpha(15), borderRadius: BorderRadius.circular(10.r)),
                    child: Icon(stat.icon, size: 20.w, color: stat.color),
                  ),
                  SizedBox(height: 8.h),
                  Text(loading ? '...' : stat.value,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                  SizedBox(height: 2.h),
                  Text(stat.label,
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: AppColors.slate400),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + (i * 80)), duration: 400.ms),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
