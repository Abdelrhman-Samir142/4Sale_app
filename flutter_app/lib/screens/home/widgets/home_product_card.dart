import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_shimmer.dart';

/// Premium product card for the home screen grid.
/// Self-contained with its own press animation controller.
class HomeProductCard extends StatefulWidget {
  final dynamic product;
  final bool isWishlisted;
  final bool isOwner;
  final bool isLoggedIn;
  final VoidCallback onWishlistToggle;
  final String currency;
  final String locale;

  const HomeProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.isOwner,
    required this.isLoggedIn,
    required this.onWishlistToggle,
    required this.currency,
    required this.locale,
  });

  @override
  State<HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends State<HomeProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imageUrl = p['primary_image'] as String?;
    final title = p['title'] as String? ?? '';
    final price = p['price']?.toString() ?? '0';
    final isAuction = p['is_auction'] == true;
    final id = p['id'].toString();
    final location = p['location'] as String?;
    final isAr = widget.locale == 'ar';

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); context.push('/product/$id'); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ───────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-image-${p['id']}',
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const AppShimmer(width: double.infinity, height: double.infinity),
                              errorWidget: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.slate100,
                                  image: DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=600&auto=format&fit=crop'),
                                    fit: BoxFit.cover,
                                    opacity: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.shopping_bag_outlined, size: 32.w, color: AppColors.slate400),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                color: AppColors.slate100,
                                image: DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=600&auto=format&fit=crop'),
                                  fit: BoxFit.cover,
                                  opacity: 0.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(Icons.shopping_bag_outlined, size: 32.w, color: AppColors.slate400),
                              ),
                            ),
                    ),
                    // Auction badge
                    if (isAuction)
                      Positioned(
                        top: 8.w, right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(gradient: AppColors.auctionGradient, borderRadius: BorderRadius.circular(20.r)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.timer_rounded, size: 11.w, color: Colors.white),
                            SizedBox(width: 3.w),
                            Text(isAr ? 'مزاد' : 'Auction',
                                style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    // Wishlist button
                    if (widget.isLoggedIn && !widget.isOwner)
                      Positioned(
                        top: 8.w, left: 8.w,
                        child: GestureDetector(
                          onTap: widget.onWishlistToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: widget.isWishlisted ? AppColors.errorRed : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Icon(
                              widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                              size: 16.w,
                              color: widget.isWishlisted ? Colors.white : AppColors.slate400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Info ────────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.slate800, height: 1.3)),
                      const Spacer(),
                      // Price
                      Text(
                        PriceFormatter.withCurrency(price, widget.currency),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: isAuction ? AppColors.auctionOrange : AppColors.primary600,
                        ),
                      ),
                      if (location != null && location.isNotEmpty)
                        Row(children: [
                          Icon(Icons.location_on_rounded, size: 11.w, color: AppColors.slate400),
                          SizedBox(width: 2.w),
                          Expanded(child: Text(location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.sp, color: AppColors.slate400, fontWeight: FontWeight.w500))),
                        ]),
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

/// Shimmer placeholder grid for loading state
class ProductsGridShimmer extends StatelessWidget {
  const ProductsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16.r)),
            child: const AppShimmer(width: double.infinity, height: double.infinity),
          ),
          childCount: 4,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.68,
        ),
      ),
    );
  }
}
