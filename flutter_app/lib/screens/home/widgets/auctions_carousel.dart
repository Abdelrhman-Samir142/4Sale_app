import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_shimmer.dart';

class AuctionsCarousel extends StatelessWidget {
  final bool loading;
  final List<dynamic> auctions;
  final LanguageState lang;

  const AuctionsCarousel({
    super.key,
    required this.loading,
    required this.auctions,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 185.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 260.w,
            margin: EdgeInsets.only(right: 12.w),
            child: AppShimmer(
                width: 260.w,
                height: 185.h,
                borderRadius: BorderRadius.circular(18.r)),
          ),
        ),
      );
    }

    if (auctions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.auctionOrange.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.gavel_rounded,
                  size: 32.w, color: AppColors.auctionOrange.withAlpha(100)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  lang.locale == 'ar'
                      ? 'لا توجد مزادات نشطة حالياً'
                      : 'No active auctions right now',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 185.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: auctions.length,
        itemBuilder: (_, i) => _AuctionCard(auction: auctions[i], lang: lang)
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 100 + (i * 80)), duration: 350.ms)
            .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: 100 + (i * 80))),
      ),
    );
  }
}

// ── Auction Card ─────────────────────────────────────────────────────────
class _AuctionCard extends StatefulWidget {
  final dynamic auction;
  final LanguageState lang;
  const _AuctionCard({required this.auction, required this.lang});
  @override
  State<_AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<_AuctionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _timeLeft() {
    final a = widget.auction;
    final isAr = widget.lang.locale == 'ar';
    final endStr =
        a['auction_end_time'] as String? ?? a['end_time'] as String?;
    if (endStr == null) return '';
    try {
      final end = DateTime.parse(endStr);
      final rem = end.difference(DateTime.now());
      if (rem.isNegative) return isAr ? 'انتهى' : 'Ended';
      if (rem.inDays > 0) return '${rem.inDays}${isAr ? ' يوم' : 'd'}';
      if (rem.inHours > 0) return '${rem.inHours}${isAr ? ' ساعة' : 'h'}';
      return '${rem.inMinutes}${isAr ? ' دقيقة' : 'm'}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final isAr = widget.lang.locale == 'ar';
    final image =
        a['product']?['primary_image'] as String? ?? a['primary_image'] as String?;
    final title =
        a['product']?['title'] as String? ?? a['title'] as String? ?? '';
    final currentBid =
        a['current_bid']?.toString() ?? a['price']?.toString() ?? '0';
    final currency = widget.lang.dict['currency'] as String;
    final productId =
        a['product']?['id']?.toString() ?? a['id']?.toString() ?? '';
    final timeLeft = _timeLeft();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.push('/product/$productId');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 260.w,
          margin: EdgeInsets.only(right: 12.w, top: 4.h, bottom: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.auctionOrange.withAlpha(12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: AppColors.auctionOrange.withAlpha(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ─────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (image != null)
                      CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF3F4F6)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFFFF7ED),
                          child: Icon(Icons.gavel_rounded,
                              size: 36.w,
                              color: AppColors.auctionOrange.withAlpha(80)),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFFFF7ED),
                        child: Icon(Icons.gavel_rounded,
                            size: 36.w,
                            color: AppColors.auctionOrange.withAlpha(80)),
                      ),
                    // LIVE badge
                    Positioned(
                      top: 8.w,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: AppColors.auctionGradient,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auctionOrange.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isAr ? 'مباشر' : 'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Time left
                    if (timeLeft.isNotEmpty)
                      Positioned(
                        top: 8.w,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_rounded,
                                  size: 11.w, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(
                                timeLeft,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Info ──────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'المزايدة الحالية' : 'Current Bid',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${double.tryParse(currentBid)?.toStringAsFixed(0) ?? currentBid} $currency',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.auctionOrange,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: AppColors.auctionGradient,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isAr ? 'زايد' : 'Bid',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
