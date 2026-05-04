import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';

class _BannerData {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  const _BannerData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class HeroBanner extends StatefulWidget {
  final LanguageState lang;
  final Map<String, dynamic> homeDict;

  const HeroBanner({super.key, required this.lang, required this.homeDict});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _pulseCtrl;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageCtrl.hasClients) {
        final next = (_currentPage + 1) % _banners.length;
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  List<_BannerData> get _banners {
    final isAr = widget.lang.locale == 'ar';
    final d = widget.homeDict;
    return [
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.shopping_bag_rounded,
        title: d['bannerTitle1'] as String? ??
            (isAr ? 'اكتشف أحدث المنتجات' : 'Discover Latest Products'),
        subtitle: d['bannerSub1'] as String? ??
            (isAr
                ? 'آلاف المنتجات بأسعار تنافسية'
                : 'Thousands of products at competitive prices'),
      ),
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.gavel_rounded,
        title: d['bannerTitle2'] as String? ??
            (isAr ? 'مزادات مباشرة الآن' : 'Live Auctions Now'),
        subtitle: d['bannerSub2'] as String? ??
            (isAr ? 'زايد واكسب الصفقة!' : 'Bid and win the deal!'),
      ),
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.smart_toy_rounded,
        title: d['bannerTitle3'] as String? ??
            (isAr ? 'وكيل ذكي للمزايدة' : 'AI Bidding Agent'),
        subtitle: d['bannerSub3'] as String? ??
            (isAr
                ? 'خلّي الذكاء الاصطناعي يزايد بدلك'
                : 'Let AI bid for you automatically'),
      ),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = _banners;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          SizedBox(
            height: 165.h,
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: banners.length,
              itemBuilder: (_, index) {
                return AnimatedBuilder(
                  animation: _pageCtrl,
                  builder: (_, child) {
                    double value = 1.0;
                    if (_pageCtrl.position.haveDimensions) {
                      value = (_pageCtrl.page! - index).abs().clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: 1.0 - (value * 0.05),
                      child: Opacity(
                        opacity: 1.0 - (value * 0.3),
                        child: child,
                      ),
                    );
                  },
                  child: _BannerCard(
                    banner: banners[index],
                    pulseCtrl: _pulseCtrl,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 24.w : 8.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary600 : AppColors.slate200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData banner;
  final AnimationController pulseCtrl;

  const _BannerCard({required this.banner, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: banner.gradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: banner.gradient.colors.first.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated icon bg
          Positioned(
            right: -20,
            bottom: -20,
            child: AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + (pulseCtrl.value * 0.1),
                child: Opacity(
                  opacity: 0.15 + (pulseCtrl.value * 0.05),
                  child: child,
                ),
              ),
              child: Icon(banner.icon, size: 120.w, color: Colors.white),
            ),
          ),
          // Decorative circles
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -20,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(banner.icon, size: 14.w, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        '4Sale',
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  banner.title,
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
