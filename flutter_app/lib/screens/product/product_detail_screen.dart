import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/products_service.dart';
import '../../services/auctions_service.dart';
import '../../services/wishlist_service.dart';
import '../../services/chat_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import 'dart:async';
import 'dart:ui';

import '../../models/product.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  bool _isWishlisted = false;
  String? _errorMsg;
  final _bidC = TextEditingController();
  Timer? _auctionTimer;
  String _timeLeft = '';
  bool _isUrgent = false;
  int _currentImageIndex = 0;
  final _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _auctionTimer?.cancel();
    _bidC.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ProductsService.get(widget.productId);
      setState(() {
        _product = data;
        _loading = false;
      });
      try {
        final w = await WishlistService.check(data.id);
        setState(() => _isWishlisted = w);
      } catch (_) {} // Non-critical: wishlist check
      if (data.isAuction == true && data.auction != null) {
        _startAuctionTimer(data.auction!['end_time'] as String);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        final isAr = ref.read(languageProvider).locale == 'ar';
        _errorMsg = isAr ? 'فشل تحميل المنتج' : 'Failed to load product';
      });
    }
  }

  void _startAuctionTimer(String endTimeStr) {
    final endTime = DateTime.parse(endTimeStr);
    _auctionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = endTime.difference(DateTime.now());
      if (diff.isNegative) {
        setState(() {
          _timeLeft = ref.read(languageProvider).locale == 'ar'
              ? 'انتهى'
              : 'Ended';
          _isUrgent = false;
        });
        _auctionTimer?.cancel();
      } else {
        final d = diff.inDays;
        final h = diff.inHours % 24;
        final m = diff.inMinutes % 60;
        final s = diff.inSeconds % 60;
        final dayStr =
            ref.read(languageProvider).locale == 'ar' ? 'يوم' : 'd';
        setState(() {
          _timeLeft = d > 0
              ? '$d $dayStr ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
              : '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
          _isUrgent = diff.inHours < 1;
        });
      }
    });
  }

  Future<void> _placeBid() async {
    final amount = double.tryParse(_bidC.text);
    if (amount == null) return;
    HapticFeedback.mediumImpact();
    try {
      final auctionId = _product!.auction!['id'].toString();
      await AuctionsService.placeBid(auctionId, amount);
      _bidC.clear();
      await _load();
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        _showSuccessSnackbar(
            isAr ? 'تم تسجيل المزايدة بنجاح ✅' : 'Bid placed successfully ✅');
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar(e.toString());
    }
  }

  Future<void> _contactSeller() async {
    HapticFeedback.lightImpact();
    try {
      final conv = await ChatService.startConversation(_product!.id);
      if (mounted) context.push('/chat/${conv['id']}');
    } catch (e) {
      if (mounted) _showErrorSnackbar(e.toString());
    }
  }

  /// Share product via native share sheet (share_plus)
  Future<void> _shareProduct() async {
    if (_product == null) return;
    HapticFeedback.lightImpact();
    final isAr = ref.read(languageProvider).locale == 'ar';
    final currency = ref.read(languageProvider).dict['currency'] as String;
    final p = _product!;
    final title = p.title;
    final price = p.price;
    final id = p.id.toString();

    final msg = isAr
        ? '🛍️ $title\n💰 ${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency\n\nشاهد المنتج على 4Sale:\nhttps://foursale-app.onrender.com/api/products/$id/'
        : '🛍️ $title\n💰 ${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency\n\nView on 4Sale:\nhttps://foursale-app.onrender.com/api/products/$id/';

    // ignore: deprecated_member_use
    await Share.share(msg, subject: title);
  }

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.errorRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['product'] as Map<String, dynamic>;
    final auth = ref.watch(authProvider);
    final currency = lang.dict['currency'] as String;
    final isAr = lang.locale == 'ar';

    if (_loading) return _buildSkeleton();
    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 56, color: AppColors.errorRed.withAlpha(120)),
          const SizedBox(height: 16),
          Text(_errorMsg!, style: const TextStyle(fontSize: 16, color: AppColors.slate600, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () { setState(() { _loading = true; _errorMsg = null; }); _load(); },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary600, foregroundColor: Colors.white),
          ),
        ])),
      );
    }
    if (_product == null) return _buildNotFound(isAr);

    final p = _product!;
    final images = p.images;
    final isAuction = p.isAuction;
    final auction = p.auction;
    final owner = p.seller;
    final isOwner = auth.userId != null && owner?.id == auth.userId;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: Stack(
          children: [
            // ── Scrollable Content ─────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Image Gallery
                SliverToBoxAdapter(
                  child: _buildImageGallery(images, p, isAuction),
                ),
                // Product Info
                SliverToBoxAdapter(
                  child: _buildProductInfo(p, dict, currency, isAr),
                ),
                // Auction Section
                if (isAuction && auction != null)
                  SliverToBoxAdapter(
                    child: _buildAuctionSection(
                        auction, dict, currency, isAr, auth.isLoggedIn, isOwner),
                  ),
                // Description
                SliverToBoxAdapter(
                  child: _buildDescription(p, dict, isAr),
                ),
                // Info Chips
                SliverToBoxAdapter(
                  child: _buildInfoChips(p, dict, isAr),
                ),
                // Seller Info
                if (owner != null)
                  SliverToBoxAdapter(
                    child: _buildSellerCard(
                        owner, dict, isAr, currency),
                  ),
                // Bottom padding for FAB
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
            // ── Floating Top Bar ───────────────────────
            _buildFloatingAppBar(isOwner, auth.isLoggedIn, p),
          ],
        ),
        // ── Bottom Action Bar ──────────────────────
        bottomNavigationBar: auth.isLoggedIn && !isOwner
            ? _buildBottomBar(dict, isAr, isAuction)
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGE GALLERY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildImageGallery(
      List<ProductImage> images, Product p, bool isAuction) {
    return SizedBox(
      height: 340.h,
      child: Stack(
        children: [
          // Image PageView
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageCtrl,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) {
                return Hero(
                  tag: 'product-image-${p.id}',
                  child: CachedNetworkImage(
                    imageUrl: images[i].image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 340.h,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFFF1F5F9)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: Icon(Icons.broken_image_outlined,
                          size: 48.w, color: AppColors.slate300),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              height: 340.h,
              color: const Color(0xFFF1F5F9),
              child: Center(
                child: Icon(Icons.image_outlined,
                    size: 64.w, color: AppColors.slate300),
              ),
            ),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(80),
                  ],
                ),
              ),
            ),
          ),
          // Image dots indicator
          if (images.length > 1)
            Positioned(
              bottom: 14.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final isActive = i == _currentImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: isActive ? 20.w : 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(100),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ),
          // Image counter
          if (images.length > 1)
            Positioned(
              bottom: 14.h,
              right: 16.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Auction badge
          if (isAuction)
            Positioned(
              bottom: 14.h,
              left: 16.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: AppColors.auctionGradient,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.auctionOrange.withAlpha(40),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gavel_rounded,
                        size: 13.w, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      ref.read(languageProvider).locale == 'ar'
                          ? 'مزاد'
                          : 'Auction',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FLOATING APP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFloatingAppBar(
      bool isOwner, bool isLoggedIn, Product p) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 12.w,
      right: 12.w,
      child: Row(
        children: [
          // Back
          _glassButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          const Spacer(),
          // Share — uses share_plus native sheet
          _glassButton(
            icon: Icons.share_rounded,
            onTap: _shareProduct,
          ),
          SizedBox(width: 8.w),
          // Wishlist
          if (isLoggedIn && !isOwner)
            _glassButton(
              icon: _isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: _isWishlisted ? AppColors.errorRed : null,
              onTap: () async {
                HapticFeedback.lightImpact();
                await WishlistService.toggle(p.id);
                setState(() => _isWishlisted = !_isWishlisted);
              },
            ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
    );
  }

  Widget _glassButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Icon(icon,
                size: 20.w, color: iconColor ?? Colors.white),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRODUCT INFO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductInfo(Product p,
      Map<String, dynamic> dict, String currency, bool isAr) {
    final title = p.title;
    final price = p.price;
    final isAuction = p.isAuction;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.slate900,
              letterSpacing: -0.5,
              height: 1.3,
            ),
          ).animate().fadeIn(duration: 300.ms),
          SizedBox(height: 10.h),
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                double.tryParse(price)?.toStringAsFixed(0) ?? price,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: isAuction
                      ? AppColors.auctionOrange
                      : AppColors.primary600,
                  height: 1,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Text(
                  currency,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isAuction
                        ? AppColors.auctionOrange
                        : AppColors.primary600,
                  ),
                ),
              ),
              const Spacer(),
              // Views
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 14.w, color: AppColors.slate400),
                    SizedBox(width: 4.w),
                    Text(
                      '${p.viewsCount}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AUCTION SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAuctionSection(
      Map<String, dynamic> auction,
      Map<String, dynamic> dict,
      String currency,
      bool isAr,
      bool isLoggedIn,
      bool isOwner) {
    final bids = (auction['bids'] as List?) ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFFFF1E6),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.auctionOrange.withAlpha(25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.auctionOrange.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Current bid & timer row
            Row(
              children: [
                // Current bid
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dict['currentBid'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${auction['current_bid']} $currency',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.auctionOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _isUrgent
                        ? AppColors.errorRed.withAlpha(12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _isUrgent
                          ? AppColors.errorRed.withAlpha(40)
                          : const Color(0xFFE8ECF0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 16.w,
                        color: _isUrgent
                            ? AppColors.errorRed
                            : AppColors.slate500,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _timeLeft.isEmpty ? '...' : _timeLeft,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _isUrgent
                              ? AppColors.errorRed
                              : AppColors.slate700,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bid input
            if (isLoggedIn && !isOwner) ...[
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border:
                            Border.all(color: const Color(0xFFE8ECF0)),
                      ),
                      child: TextField(
                        controller: _bidC,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                        decoration: InputDecoration(
                          hintText: dict['bidAmount'] as String,
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.slate400,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12.h),
                          suffixText: currency,
                          suffixStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.auctionOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: _placeBid,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: AppColors.auctionGradient,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.auctionOrange.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        dict['placeBid'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Bid history
            if (bids.isNotEmpty) ...[
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dict['bidHistory'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...bids.take(5).map((bid) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: AppColors.auctionOrange.withAlpha(12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  (bid['bidder_name'] as String?)
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.auctionOrange,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                bid['bidder_name'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate700,
                                ),
                              ),
                            ),
                            Text(
                              '${bid['amount']} $currency',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.auctionOrange,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════
  // DESCRIPTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDescription(
      Product p, Map<String, dynamic> dict, bool isAr) {
    final desc = p.description;
    if (desc.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 18.w, color: AppColors.slate500),
              SizedBox(width: 6.w),
              Text(
                dict['description'] as String,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.slate600,
              height: 1.7,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // INFO CHIPS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoChips(
      Product p, Map<String, dynamic> dict, bool isAr) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          _premiumChip(Icons.category_rounded,
              p.category, AppColors.latestBlue),
          _premiumChip(Icons.star_rounded,
              p.condition, AppColors.warningAmber),
          if (p.location.isNotEmpty)
            _premiumChip(Icons.location_on_rounded,
                p.location, AppColors.errorRed),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _premiumChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.w, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SELLER CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSellerCard(
      ProductSeller? owner,
      Map<String, dynamic> dict,
      bool isAr,
      String currency) {
    final username = owner?.username ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final hue =
        (username.codeUnits.fold<int>(0, (s, c) => s + c) * 37) % 360;
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.55).toColor();
    final avatarBg =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.93).toColor();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_rounded,
                    size: 18.w, color: AppColors.slate500),
                SizedBox(width: 6.w),
                Text(
                  dict['sellerInfo'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM ACTION BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomBar(
      Map<String, dynamic> dict, bool isAr, bool isAuction) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: _contactSeller,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary600.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 20.w, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  dict['contactSeller'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SKELETON
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: Column(
        children: [
          AppShimmer(
            width: double.infinity,
            height: 340.h,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(
                    width: 250.w,
                    height: 24.h,
                    borderRadius: BorderRadius.circular(6.r)),
                SizedBox(height: 12.h),
                AppShimmer(
                    width: 120.w,
                    height: 30.h,
                    borderRadius: BorderRadius.circular(6.r)),
                SizedBox(height: 20.h),
                AppShimmer(
                    width: double.infinity,
                    height: 100.h,
                    borderRadius: BorderRadius.circular(16.r)),
                SizedBox(height: 16.h),
                AppShimmer(
                    width: double.infinity,
                    height: 60.h,
                    borderRadius: BorderRadius.circular(16.r)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound(bool isAr) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64.w, color: AppColors.slate300),
            SizedBox(height: 16.h),
            Text(
              isAr ? 'المنتج غير موجود' : 'Product not found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.slate600,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isAr ? 'رجوع' : 'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
