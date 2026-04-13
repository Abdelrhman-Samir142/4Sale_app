import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../services/products_service.dart';
import '../../services/wishlist_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<dynamic> _products = [];
  Set<int> _wishlistIds = {};
  bool _loading = true;
  String? _error;
  final _searchC = TextEditingController();
  final _focusNode = FocusNode();
  bool _searchHasFocus = false;
  bool _searchHasText = false;
  String _categoryFilter = '';

  static const _categoryIcons = <String, IconData>{
    '': Icons.grid_view_rounded,
    'electronics': Icons.devices_rounded,
    'furniture': Icons.chair_rounded,
    'scrap_metals': Icons.recycling_rounded,
    'other': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchWishlist();
    _focusNode.addListener(() {
      setState(() => _searchHasFocus = _focusNode.hasFocus);
    });
    _searchC.addListener(() {
      setState(() => _searchHasText = _searchC.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ProductsService.list(
        search: _searchC.text.isNotEmpty ? _searchC.text : null,
        category: _categoryFilter.isNotEmpty ? _categoryFilter : null,
      );
      setState(() { _products = (res['results'] as List?) ?? []; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _fetchWishlist() async {
    try {
      final ids = await WishlistService.getIds();
      setState(() => _wishlistIds = ids.toSet());
    } catch (_) {}
  }

  Future<void> _toggleWishlist(int id) async {
    try {
      final res = await WishlistService.toggle(id);
      setState(() {
        if (res['is_wishlisted'] == true) { _wishlistIds.add(id); }
        else { _wishlistIds.remove(id); }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['dashboard'] as Map<String, dynamic>;
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar Area ────────────────────────────────────
              _buildAppBar(dict, lang, colorScheme),
              // ── Search Bar ─────────────────────────────────────
              _buildSearchBar(dict).animate().fadeIn(delay: 100.ms, duration: 350.ms),
              // ── Category Chips ─────────────────────────────────
              _buildCategoryChips(lang).animate().fadeIn(delay: 200.ms, duration: 350.ms),
              SizedBox(height: 8.h),
              // ── Products Grid ──────────────────────────────────
              Expanded(
                child: _loading
                    ? _buildShimmerGrid()
                    : _error != null
                        ? AppErrorState(
                            error: _error!,
                            onRetry: _fetchProducts,
                            retryText: dict['retry'] as String,
                          )
                        : _products.isEmpty
                            ? AppEmptyState(
                                title: dict['noProducts'] as String,
                                subtitle: dict['filterHint'] as String,
                                icon: Icons.inventory_2_outlined,
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchProducts,
                                color: AppColors.primary600,
                                child: AnimationLimiter(
                                  child: GridView.builder(
                                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 14.h,
                                      crossAxisSpacing: 14.w,
                                      childAspectRatio: 0.68,
                                    ),
                                    itemCount: _products.length,
                                    itemBuilder: (ctx, i) {
                                      final p = _products[i];
                                      return AnimationConfiguration.staggeredGrid(
                                        position: i,
                                        duration: const Duration(milliseconds: 375),
                                        columnCount: 2,
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: _ProductCard(
                                              product: p,
                                              isWishlisted: _wishlistIds.contains(p['id'] as int),
                                              isOwner: auth.userId == p['owner_id'],
                                              isLoggedIn: auth.isLoggedIn,
                                              onWishlistToggle: () => _toggleWishlist(p['id'] as int),
                                              currency: lang.dict['currency'] as String,
                                              locale: lang.locale,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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

  // ═══════════════════════════════════════════════════════════════
  Widget _buildAppBar(Map<String, dynamic> dict, LanguageState lang, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
      child: Row(
        children: [
          // Logo + Title
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4Sale', style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.w800,
                color: AppColors.slate900, letterSpacing: -0.5,
              )),
              Text(dict['storeSubtitle'] as String, style: TextStyle(
                fontSize: 11.sp, color: AppColors.slate400, fontWeight: FontWeight.w500,
              )),
            ],
          ),
          const Spacer(),
          // Search icon
          _iconBtn(Icons.search_rounded, () => context.push('/search')),
          _iconBtn(Icons.notifications_none_rounded, () => context.push('/notifications')),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEEF0F2)),
        ),
        child: Icon(icon, size: 20.w, color: AppColors.slate600),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar(Map<String, dynamic> dict) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _searchHasFocus ? AppColors.primary500 : const Color(0xFFEEF0F2),
            width: _searchHasFocus ? 1.5 : 1.0,
          ),
          boxShadow: _searchHasFocus
              ? [BoxShadow(color: AppColors.primary500.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchC,
          focusNode: _focusNode,
          onSubmitted: (_) => _fetchProducts(),
          style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
          decoration: InputDecoration(
            hintText: dict['searchPlaceholder'] as String,
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.slate400),
            prefixIcon: Icon(Icons.search_rounded, size: 22.w,
                color: _searchHasFocus ? AppColors.primary600 : AppColors.slate400),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchHasText)
                  GestureDetector(
                    onTap: () { _searchC.clear(); _fetchProducts(); },
                    child: Icon(Icons.close_rounded, size: 18.w, color: AppColors.slate400),
                  ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.tune_rounded, size: 18.w, color: AppColors.primary600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildCategoryChips(LanguageState lang) {
    final dict = lang.dict['dashboard'] as Map<String, dynamic>;
    final cats = <String, String>{
      '': dict['allProducts'] as String,
      'electronics': lang.dict['categories']['electronics'] as String,
      'furniture': lang.dict['categories']['furniture'] as String,
      'scrap_metals': lang.dict['categories']['scrap'] as String,
      'other': lang.dict['addItem']['other'] as String,
    };

    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final key = cats.keys.elementAt(i);
          final label = cats.values.elementAt(i);
          final selected = _categoryFilter == key;
          final icon = _categoryIcons[key] ?? Icons.category_rounded;

          return GestureDetector(
            onTap: () { setState(() => _categoryFilter = key); _fetchProducts(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary600 : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? AppColors.primary600 : const Color(0xFFE2E8F0),
                ),
                boxShadow: selected
                    ? [BoxShadow(color: AppColors.primary600.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16.w, color: selected ? Colors.white : AppColors.slate500),
                  SizedBox(width: 6.w),
                  Text(label, style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.slate600,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 14.h, crossAxisSpacing: 14.w, childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: AppShimmer(width: double.infinity, height: double.infinity),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── PRODUCT CARD ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final dynamic product;
  final bool isWishlisted;
  final bool isOwner;
  final bool isLoggedIn;
  final VoidCallback onWishlistToggle;
  final String currency;
  final String locale;

  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.isOwner,
    required this.isLoggedIn,
    required this.onWishlistToggle,
    required this.currency,
    required this.locale,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['primary_image'] as String?;
    final title = widget.product['title'] as String? ?? '';
    final price = widget.product['price']?.toString() ?? '0';
    final isAuction = widget.product['is_auction'] == true;
    final id = widget.product['id'].toString();
    final location = widget.product['location'] as String?;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); context.push('/product/$id'); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-image-${widget.product['id']}',
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                              errorWidget: (_, __, ___) => Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF)),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF3F4F6),
                              child: Icon(Icons.image_outlined, size: 40.w, color: const Color(0xFF9CA3AF)),
                            ),
                    ),
                    // Auction badge
                    if (isAuction)
                      Positioned(
                        top: 8.w, right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.auctionGradient,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_rounded, size: 11.w, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(widget.locale == 'ar' ? 'مزاد' : 'Auction',
                                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    // Wishlist button
                    if (widget.isLoggedIn && !widget.isOwner)
                      Positioned(
                        top: 8.w, left: 8.w,
                        child: GestureDetector(
                          onTap: widget.onWishlistToggle,
                          child: Container(
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
              // ── Info ───────────────────────────────────
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
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.slate800, height: 1.3)),
                      const Spacer(),
                      Text(
                        '${double.tryParse(price)?.toStringAsFixed(0) ?? price} ${widget.currency}',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.primary700),
                      ),
                      if (location != null && location.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 12.w, color: AppColors.slate400),
                          SizedBox(width: 2.w),
                          Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.sp, color: AppColors.slate400))),
                        ]),
                      ],
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
