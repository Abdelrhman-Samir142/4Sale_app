import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/wishlist_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../shared/widgets/app_shimmer.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});
  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      _items = await WishlistService.list();
    } catch (e) {
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        AppSnackbar.error(context, isAr ? 'فشل تحميل المفضلة' : 'Failed to load wishlist');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(int id, int index) async {
    HapticFeedback.lightImpact();
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    try {
      await WishlistService.toggle(id);
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        AppSnackbar.undo(context, isAr ? 'تم الحذف من المفضلة' : 'Removed from wishlist', () {
          setState(() => _items.insert(index, removed));
          WishlistService.toggle(id);
        });
      }
    } catch (e) {
      setState(() => _items.insert(index, removed));
      if (mounted) AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['wishlist'] as Map<String, dynamic>;
    final currency = lang.dict['currency'] as String;
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              _buildHeader(dict, isAr),
              // ── Content ─────────────────────────────────
              Expanded(
                child: _loading
                    ? _buildShimmerGrid()
                    : _items.isEmpty
                        ? _buildEmptyState(dict, isAr)
                        : RefreshIndicator(
                            onRefresh: _fetch,
                            color: AppColors.errorRed,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                padding:
                                    EdgeInsets.only(top: 4.h, bottom: 100.h),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12.h,
                                  crossAxisSpacing: 12.w,
                                  childAspectRatio: 0.72,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (_, i) => _WishlistCard(
                                  product: _items[i],
                                  currency: currency,
                                  isAr: isAr,
                                  onRemove: () =>
                                      _remove(_items[i]['id'] as int, i),
                                  onTap: () => context
                                      .push('/product/${_items[i]['id']}'),
                                ).animate()
                                    .fadeIn(
                                        delay:
                                            Duration(milliseconds: 60 * i),
                                        duration: 350.ms)
                                    .scaleXY(
                                        begin: 0.92,
                                        end: 1,
                                        delay:
                                            Duration(milliseconds: 60 * i),
                                        duration: 350.ms,
                                        curve: Curves.easeOutBack),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> dict, bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 20.w, color: AppColors.slate700),
            ),
          ),
          SizedBox(width: 12.w),
          // Icon + title
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withAlpha(12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.favorite_rounded,
                size: 20.w, color: AppColors.errorRed),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dict['title'] as String,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_items.length} ${isAr ? 'عنصر' : 'items'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: GridView.builder(
        padding: EdgeInsets.only(top: 12.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => AppShimmer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, dynamic> dict, bool isAr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withAlpha(8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_outline_rounded,
                size: 56.w, color: AppColors.errorRed.withAlpha(80)),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          SizedBox(height: 20.h),
          Text(
            dict['empty'] as String,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 8.h),
          Text(
            isAr
                ? 'تصفح المنتجات وأضف المفضلة ❤️'
                : 'Browse products and add favorites ❤️',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.slate400,
            ),
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary600.withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isAr ? 'تصفح المنتجات' : 'Browse Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── WISHLIST CARD ───────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _WishlistCard extends StatefulWidget {
  final dynamic product;
  final String currency;
  final bool isAr;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WishlistCard({
    required this.product,
    required this.currency,
    required this.isAr,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final title = p['title'] as String? ?? '';
    final price = p['price']?.toString() ?? '0';
    final images = p['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty
        ? images[0]['image'] as String?
        : p['primary_image'] as String?;
    final isAuction = p['is_auction'] == true;
    final location = p['location'] as String? ?? '';

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF1F5F9)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: Icon(Icons.image_outlined,
                              size: 30.w, color: AppColors.slate300),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFF1F5F9),
                        child: Icon(Icons.image_outlined,
                            size: 36.w, color: AppColors.slate300),
                      ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(40),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Heart remove button
                    Positioned(
                      top: 6.w,
                      right: 6.w,
                      child: GestureDetector(
                        onTap: widget.onRemove,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(Icons.favorite_rounded,
                              size: 16.w, color: AppColors.errorRed),
                        ),
                      ),
                    ),
                    // Auction badge
                    if (isAuction)
                      Positioned(
                        top: 6.w,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.auctionGradient,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.gavel_rounded,
                                  size: 10.w, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(
                                widget.isAr ? 'مزاد' : 'Auction',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
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
              // ── Info ─────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        '${double.tryParse(price)?.toStringAsFixed(0) ?? price} ${widget.currency}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Location
                      if (location.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 11.w, color: AppColors.slate400),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
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
