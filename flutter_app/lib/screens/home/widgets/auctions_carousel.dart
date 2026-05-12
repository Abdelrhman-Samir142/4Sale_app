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
        height: 380.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 240.w,
            margin: EdgeInsets.only(right: 12.w),
            child: AppShimmer(
                width: 240.w,
                height: 380.h,
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
      height: 380.h,
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
    if (a is! Map) return '';
    final isAr = widget.lang.locale == 'ar';
    // Backend AuctionSerializer returns 'end_time'
    final endStr = a['end_time'] as String? ?? a['auction_end_time'] as String?;
    if (endStr == null) return '';
    try {
      final end = DateTime.parse(endStr);
      final rem = end.difference(DateTime.now());
      if (rem.isNegative) return isAr ? 'انتهى' : 'Ended';
      
      final hours = rem.inHours.toString().padLeft(2, '0');
      final minutes = (rem.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (rem.inSeconds % 60).toString().padLeft(2, '0');
      
      return isAr ? 'ينتهي خلال: ${hours}س : ${minutes}د : ${seconds}ث' : 'Ends in: ${hours}h : ${minutes}m : ${seconds}s';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final isAr = widget.lang.locale == 'ar';
    
    // ── Correct Data Extraction (matches AuctionSerializer flat keys) ──
    // Backend returns: product_image (absolute URL), product_title (string),
    // product (integer ID), current_bid, total_bids, end_time
    final image = (a is Map ? a['product_image'] as String? : null);
    final title = (a is Map ? a['product_title'] as String? ?? a['title'] as String? : null) ?? '';
    final currentBidRaw = (a is Map ? a['current_bid']?.toString() : null) ?? '0';
    final currentBid = double.tryParse(currentBidRaw)?.toStringAsFixed(0) ?? currentBidRaw;
    final bidsCount = (a is Map ? a['total_bids']?.toString() : null) ?? '0';
    final currency = widget.lang.dict['currency'] as String;
    // Route using the product's database ID (integer from backend)
    final productId = (a is Map ? a['product']?.toString() : null) ?? '';
    final timeLeft = _timeLeft();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (productId.isNotEmpty) context.push('/product/$productId');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 240.w, // Large Hero Width
          margin: EdgeInsets.only(right: 16.w, top: 4.h, bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.slate900.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Safely bounds the layout
            children: [
              // ── Top Half: Large Image ─────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                child: SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: image != null
                      ? CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFFFF7ED),
                            child: Icon(Icons.gavel_rounded, size: 48.w, color: AppColors.auctionOrange.withAlpha(80)),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFFFF7ED),
                          child: Icon(Icons.gavel_rounded, size: 48.w, color: AppColors.auctionOrange.withAlpha(80)),
                        ),
                ),
              ),
              
              // ── Bottom Half: Hero Info ──────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Urgency Tag
                    if (timeLeft.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.auctionOrange.withAlpha(20),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.auctionOrange.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_rounded, size: 14.w, color: AppColors.auctionOrange),
                            SizedBox(width: 6.w),
                            Text(
                              timeLeft,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.auctionOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 12.h),
                    
                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Bid Status
                    Row(
                      children: [
                        Text(
                          isAr ? 'أعلى مزايدة حالية:' : 'Highest Bid:',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '$currentBid $currency',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary600, // Primary Green
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    
                    // Bids count and Arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'عدد المزايدات: $bidsCount' : 'Bids: $bidsCount',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 12.w, color: AppColors.primary600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
