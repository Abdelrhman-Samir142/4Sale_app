import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../services/products_service.dart';
import '../../services/auctions_service.dart';
import '../../services/stats_service.dart';
import '../../services/wishlist_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // Data
  List<dynamic> _featuredProducts = [];
  List<dynamic> _latestProducts = [];
  List<dynamic> _auctions = [];
  Set<int> _wishlistIds = {};
  Map<String, dynamic> _stats = {};
  bool _loadingProducts = true;
  bool _loadingAuctions = true;
  bool _loadingStats = true;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final _scrollController = ScrollController();
  final PageController _bannerPageController = PageController(viewportFraction: 0.92);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _fetchAll();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerPageController.hasClients) {
        final next = (_currentBannerPage + 1) % 3;
        _bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _fetchAll() async {
    _fetchProducts();
    _fetchAuctions();
    _fetchStats();
    _fetchWishlist();
  }

  Future<void> _fetchProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final res = await ProductsService.list();
      final products = (res['results'] as List?) ?? [];
      if (mounted) {
        setState(() {
          _featuredProducts = products.take(6).toList();
          _latestProducts = products.skip(6).take(10).toList();
          if (_latestProducts.isEmpty) _latestProducts = products;
          _loadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _fetchAuctions() async {
    setState(() => _loadingAuctions = true);
    try {
      final res = await AuctionsService.list(activeOnly: true);
      if (mounted) setState(() { _auctions = res.take(5).toList(); _loadingAuctions = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAuctions = false);
    }
  }

  Future<void> _fetchStats() async {
    setState(() => _loadingStats = true);
    try {
      final res = await StatsService.getGeneralStats();
      if (mounted) setState(() { _stats = res; _loadingStats = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _fetchWishlist() async {
    try {
      final ids = await WishlistService.getIds();
      if (mounted) setState(() => _wishlistIds = ids.toSet());
    } catch (_) {}
  }

  Future<void> _toggleWishlist(int id) async {
    try {
      final res = await WishlistService.toggle(id);
      if (mounted) {
        setState(() {
          if (res['is_wishlisted'] == true) _wishlistIds.add(id);
          else _wishlistIds.remove(id);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict;
    final auth = ref.watch(authProvider);
    final homeDict = dict['home'] as Map<String, dynamic>? ?? _fallbackHomeDict(lang.locale);

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _fetchAll,
            color: AppColors.primary600,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // ── App Bar ──────────────────────────────
                _buildSliverAppBar(dict, lang, auth),
                // ── Hero Banner ──────────────────────────
                SliverToBoxAdapter(child: _buildHeroBanner(homeDict, lang)),
                // ── Quick Actions ────────────────────────
                SliverToBoxAdapter(child: _buildQuickActions(homeDict, lang)),
                // ── Live Auctions Section ────────────────
                SliverToBoxAdapter(child: _buildSectionHeader(
                  homeDict['liveAuctions'] as String? ?? 'Live Auctions',
                  homeDict['viewAll'] as String? ?? 'View All',
                  Icons.gavel_rounded,
                  AppColors.auctionOrange,
                  () => context.go('/auctions'),
                )),
                SliverToBoxAdapter(child: _buildAuctionsCarousel(lang)),
                // ── Categories Section ───────────────────
                SliverToBoxAdapter(child: _buildSectionHeader(
                  dict['categories']['title'] as String,
                  homeDict['viewAll'] as String? ?? 'View All',
                  Icons.category_rounded,
                  AppColors.recommendedPurple,
                  () {},
                )),
                SliverToBoxAdapter(child: _buildCategoriesGrid(dict, lang)),
                // ── Featured Products ────────────────────
                SliverToBoxAdapter(child: _buildSectionHeader(
                  homeDict['featuredProducts'] as String? ?? 'Featured Products',
                  homeDict['viewAll'] as String? ?? 'View All',
                  Icons.star_rounded,
                  AppColors.warningAmber,
                  () {},
                )),
                _buildProductsGrid(auth, lang),
                // ── AI Features Banner ───────────────────
                SliverToBoxAdapter(child: _buildAIFeaturesBanner(homeDict, dict, lang)),
                // ── Stats Section ────────────────────────
                SliverToBoxAdapter(child: _buildStatsSection(dict)),
                // Bottom padding for nav bar
                SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── SLIVER APP BAR ────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(Map<String, dynamic> dict, LanguageState lang, AuthState auth) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary600.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang.locale == 'ar' ? 'أهلاً' : 'Welcome',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text('👋', style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  Text(
                    auth.username ?? '4Sale',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildIconButton(Icons.search_rounded, () => context.push('/search')),
            _buildIconButton(Icons.notifications_none_rounded, () => context.push('/notifications'),
                badge: true),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0, duration: 300.ms),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEF0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 20.w, color: AppColors.slate600),
            if (badge)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── HERO BANNER ───────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeroBanner(Map<String, dynamic> homeDict, LanguageState lang) {
    final banners = [
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.shopping_bag_rounded,
        title: homeDict['bannerTitle1'] as String? ??
            (lang.locale == 'ar' ? 'اكتشف أحدث المنتجات' : 'Discover Latest Products'),
        subtitle: homeDict['bannerSub1'] as String? ??
            (lang.locale == 'ar' ? 'آلاف المنتجات بأسعار تنافسية' : 'Thousands of products at competitive prices'),
      ),
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.gavel_rounded,
        title: homeDict['bannerTitle2'] as String? ??
            (lang.locale == 'ar' ? 'مزادات مباشرة الآن' : 'Live Auctions Now'),
        subtitle: homeDict['bannerSub2'] as String? ??
            (lang.locale == 'ar' ? 'زايد واكسب الصفقة!' : 'Bid and win the deal!'),
      ),
      _BannerData(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.smart_toy_rounded,
        title: homeDict['bannerTitle3'] as String? ??
            (lang.locale == 'ar' ? 'وكيل ذكي للمزايدة' : 'AI Bidding Agent'),
        subtitle: homeDict['bannerSub3'] as String? ??
            (lang.locale == 'ar' ? 'خلّي الذكاء الاصطناعي يزايد بدلك' : 'Let AI bid for you automatically'),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          SizedBox(
            height: 165.h,
            child: PageView.builder(
              controller: _bannerPageController,
              onPageChanged: (i) => setState(() => _currentBannerPage = i),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return AnimatedBuilder(
                  animation: _bannerPageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_bannerPageController.position.haveDimensions) {
                      value = (_bannerPageController.page! - index).abs().clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: 1.0 - (value * 0.05),
                      child: Opacity(
                        opacity: 1.0 - (value * 0.3),
                        child: child,
                      ),
                    );
                  },
                  child: _buildBannerCard(banner),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final isActive = i == _currentBannerPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isActive ? 24.w : 8.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary600 : AppColors.slate200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBannerCard(_BannerData banner) {
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
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Opacity(
                  opacity: 0.15 + (_pulseController.value * 0.05),
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                          color: Colors.white,
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
                    color: Colors.white,
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

  // ═══════════════════════════════════════════════════════════════════
  // ── QUICK ACTIONS ─────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildQuickActions(Map<String, dynamic> homeDict, LanguageState lang) {
    final actions = [
      _QuickAction(
        icon: Icons.store_rounded,
        label: homeDict['marketplace'] as String? ??
            (lang.locale == 'ar' ? 'المتجر' : 'Marketplace'),
        color: AppColors.primary600,
        bgColor: AppColors.primary50,
        route: '/',
      ),
      _QuickAction(
        icon: Icons.gavel_rounded,
        label: lang.dict['nav']['auctions'] as String,
        color: AppColors.auctionOrange,
        bgColor: const Color(0xFFFFF7ED),
        route: '/auctions',
      ),
      _QuickAction(
        icon: Icons.smart_toy_rounded,
        label: homeDict['aiAgent'] as String? ??
            (lang.locale == 'ar' ? 'وكيل ذكي' : 'AI Agent'),
        color: AppColors.recommendedPurple,
        bgColor: const Color(0xFFFAF5FF),
        route: '/agent',
      ),
      _QuickAction(
        icon: Icons.favorite_rounded,
        label: lang.dict['nav']['wishlist'] as String,
        color: AppColors.errorRed,
        bgColor: const Color(0xFFFEF2F2),
        route: '/wishlist',
      ),
      _QuickAction(
        icon: Icons.search_rounded,
        label: homeDict['smartSearch'] as String? ??
            (lang.locale == 'ar' ? 'بحث ذكي' : 'Smart Search'),
        color: AppColors.latestBlue,
        bgColor: const Color(0xFFEFF6FF),
        route: '/search',
      ),
      _QuickAction(
        icon: Icons.add_circle_rounded,
        label: homeDict['addListing'] as String? ??
            (lang.locale == 'ar' ? 'أضف إعلان' : 'Add Listing'),
        color: AppColors.successGreen,
        bgColor: const Color(0xFFF0FDF4),
        route: '/sell',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.15,
        ),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final action = actions[i];
          return _QuickActionCard(action: action)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 150 + (i * 50)), duration: 350.ms)
              .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 150 + (i * 50)));
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── SECTION HEADER ────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(
    String title,
    String actionText,
    IconData icon,
    Color accentColor,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.w, color: accentColor),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10.w, color: accentColor),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── AUCTIONS CAROUSEL ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAuctionsCarousel(LanguageState lang) {
    if (_loadingAuctions) {
      return SizedBox(
        height: 180.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 260.w,
            margin: EdgeInsets.only(right: 12.w),
            child: AppShimmer(width: 260.w, height: 180.h,
                borderRadius: BorderRadius.circular(16.r)),
          ),
        ),
      );
    }

    if (_auctions.isEmpty) {
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
              Icon(Icons.gavel_rounded, size: 32.w, color: AppColors.auctionOrange.withAlpha(100)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  lang.locale == 'ar' ? 'لا توجد مزادات نشطة حالياً' : 'No active auctions right now',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.slate500, fontWeight: FontWeight.w500),
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
        itemCount: _auctions.length,
        itemBuilder: (_, i) {
          final auction = _auctions[i];
          return _AuctionCard(auction: auction, lang: lang)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 + (i * 80)), duration: 350.ms)
              .slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: 100 + (i * 80)));
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── CATEGORIES GRID ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCategoriesGrid(Map<String, dynamic> dict, LanguageState lang) {
    final categories = [
      _CategoryItem(
        icon: Icons.devices_rounded,
        label: dict['categories']['electronics'] as String,
        color: AppColors.latestBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _CategoryItem(
        icon: Icons.chair_rounded,
        label: dict['categories']['furniture'] as String,
        color: AppColors.warningAmber,
        bgColor: const Color(0xFFFFFBEB),
      ),
      _CategoryItem(
        icon: Icons.recycling_rounded,
        label: dict['categories']['scrap'] as String,
        color: AppColors.successGreen,
        bgColor: const Color(0xFFF0FDF4),
      ),
      _CategoryItem(
        icon: Icons.checkroom_rounded,
        label: dict['categories']['fashion'] as String,
        color: AppColors.recommendedPurple,
        bgColor: const Color(0xFFFAF5FF),
      ),
      _CategoryItem(
        icon: Icons.directions_car_rounded,
        label: dict['categories']['vehicles'] as String,
        color: AppColors.auctionOrange,
        bgColor: const Color(0xFFFFF7ED),
      ),
      _CategoryItem(
        icon: Icons.menu_book_rounded,
        label: dict['categories']['books'] as String,
        color: AppColors.primary600,
        bgColor: AppColors.primary50,
      ),
    ];

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
            onTap: () {}, // TODO: Navigate to category filter
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
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 60)), duration: 300.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                delay: Duration(milliseconds: 100 + (i * 60)),
              );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── PRODUCTS GRID ─────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildProductsGrid(AuthState auth, LanguageState lang) {
    if (_loadingProducts) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: AppShimmer(width: double.infinity, height: double.infinity),
            ),
            childCount: 4,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.72,
          ),
        ),
      );
    }

    final products = _featuredProducts.isNotEmpty ? _featuredProducts : _latestProducts;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final p = products[i];
            return _HomeProductCard(
              product: p,
              isWishlisted: _wishlistIds.contains(p['id'] as int),
              isOwner: auth.userId == p['owner_id'],
              isLoggedIn: auth.isLoggedIn,
              onWishlistToggle: () => _toggleWishlist(p['id'] as int),
              currency: lang.dict['currency'] as String,
              locale: lang.locale,
            ).animate().fadeIn(
                delay: Duration(milliseconds: 100 + (i * 80)),
                duration: 350.ms,
              ).slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 100 + (i * 80)));
          },
          childCount: products.length.clamp(0, 6),
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

  // ═══════════════════════════════════════════════════════════════════
  // ── AI FEATURES BANNER ────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAIFeaturesBanner(Map<String, dynamic> homeDict, Map<String, dynamic> dict, LanguageState lang) {
    final features = dict['features'] as Map<String, dynamic>;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF312E81).withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern overlay
            Positioned(
              right: -10,
              top: -10,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, child) => Transform.rotate(
                  angle: _waveController.value * 2 * math.pi * 0.1,
                  child: child,
                ),
                child: Icon(Icons.auto_awesome, size: 90.w, color: Colors.white.withAlpha(15)),
              ),
            ),
            Positioned(
              left: -15,
              bottom: -15,
              child: Icon(Icons.psychology_rounded, size: 70.w, color: Colors.white.withAlpha(10)),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.auto_awesome, size: 20.w, color: const Color(0xFFA78BFA)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          features['title'] as String,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    features['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withAlpha(160),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Feature chips
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildFeatureChip(
                        Icons.gavel_rounded,
                        (features['aiPricing'] as Map<String, dynamic>)['title'] as String,
                        const Color(0xFFFBBF24),
                      ),
                      _buildFeatureChip(
                        Icons.search_rounded,
                        (features['smartSearch'] as Map<String, dynamic>)['title'] as String,
                        const Color(0xFF60A5FA),
                      ),
                      _buildFeatureChip(
                        Icons.shield_rounded,
                        (features['secure'] as Map<String, dynamic>)['title'] as String,
                        const Color(0xFF34D399),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/agent'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withAlpha(40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.smart_toy_rounded, size: 16.w, color: Colors.white),
                                SizedBox(width: 6.w),
                                Text(
                                  homeDict['tryAgent'] as String? ??
                                      (lang.locale == 'ar' ? 'جرّب الوكيل' : 'Try Agent'),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.white.withAlpha(30)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_rounded, size: 16.w, color: Colors.white),
                                SizedBox(width: 6.w),
                                Text(
                                  homeDict['smartSearch'] as String? ??
                                      (lang.locale == 'ar' ? 'بحث ذكي' : 'Smart Search'),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeatureChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── STATS SECTION ─────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatsSection(Map<String, dynamic> dict) {
    final statItems = [
      _StatItem(
        icon: Icons.people_rounded,
        value: _stats['total_users']?.toString() ?? '0',
        label: dict['stats']['activeUsers'] as String,
        color: AppColors.primary600,
      ),
      _StatItem(
        icon: Icons.shopping_bag_rounded,
        value: _stats['total_products']?.toString() ?? '0',
        label: dict['stats']['productsSold'] as String,
        color: AppColors.latestBlue,
      ),
      _StatItem(
        icon: Icons.gavel_rounded,
        value: _stats['active_auctions']?.toString() ?? '0',
        label: dict['stats']['scrapTons'] as String,
        color: AppColors.auctionOrange,
      ),
      _StatItem(
        icon: Icons.location_on_rounded,
        value: '27',
        label: dict['stats']['governorates'] as String,
        color: AppColors.recommendedPurple,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: stat.color.withAlpha(15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(stat.icon, size: 20.w, color: stat.color),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _loadingStats ? '...' : stat.value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    stat.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + (i * 80)), duration: 400.ms),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── FALLBACK DICT (if 'home' key is missing from i18n)  ────────
  // ═══════════════════════════════════════════════════════════════════
  Map<String, dynamic> _fallbackHomeDict(String locale) {
    if (locale == 'ar') {
      return {
        'bannerTitle1': 'اكتشف أحدث المنتجات',
        'bannerSub1': 'آلاف المنتجات بأسعار تنافسية',
        'bannerTitle2': 'مزادات مباشرة الآن',
        'bannerSub2': 'زايد واكسب الصفقة!',
        'bannerTitle3': 'وكيل ذكي للمزايدة',
        'bannerSub3': 'خلّي الذكاء الاصطناعي يزايد بدلك',
        'liveAuctions': 'المزادات النشطة',
        'viewAll': 'عرض الكل',
        'featuredProducts': 'منتجات مميزة',
        'marketplace': 'المتجر',
        'aiAgent': 'وكيل ذكي',
        'smartSearch': 'بحث ذكي',
        'addListing': 'أضف إعلان',
        'tryAgent': 'جرّب الوكيل',
        'currentBid': 'المزايدة الحالية',
        'timeLeft': 'الوقت المتبقي',
        'bidNow': 'زايد الآن',
      };
    }
    return {
      'bannerTitle1': 'Discover Latest Products',
      'bannerSub1': 'Thousands of products at competitive prices',
      'bannerTitle2': 'Live Auctions Now',
      'bannerSub2': 'Bid and win the deal!',
      'bannerTitle3': 'AI Bidding Agent',
      'bannerSub3': 'Let AI bid for you automatically',
      'liveAuctions': 'Live Auctions',
      'viewAll': 'View All',
      'featuredProducts': 'Featured Products',
      'marketplace': 'Marketplace',
      'aiAgent': 'AI Agent',
      'smartSearch': 'Smart Search',
      'addListing': 'Add Listing',
      'tryAgent': 'Try Agent',
      'currentBid': 'Current Bid',
      'timeLeft': 'Time Left',
      'bidNow': 'Bid Now',
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── DATA CLASSES ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
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

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}

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

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// ── QUICK ACTION CARD ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        context.push(widget.action.route);
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: widget.action.color.withAlpha(12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.action.color.withAlpha(15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: widget.action.bgColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(widget.action.icon, size: 22.w, color: widget.action.color),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.action.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── AUCTION CARD ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _AuctionCard extends StatefulWidget {
  final dynamic auction;
  final LanguageState lang;
  const _AuctionCard({required this.auction, required this.lang});
  @override
  State<_AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<_AuctionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final image = a['product']?['primary_image'] as String? ??
        a['primary_image'] as String?;
    final title = a['product']?['title'] as String? ??
        a['title'] as String? ?? '';
    final currentBid = a['current_bid']?.toString() ??
        a['price']?.toString() ?? '0';
    final currency = widget.lang.dict['currency'] as String;
    final isAr = widget.lang.locale == 'ar';
    final productId = a['product']?['id']?.toString() ?? a['id']?.toString() ?? '';

    // Calculate time remaining
    String timeLeft = '';
    final endTimeStr = a['auction_end_time'] as String? ?? a['end_time'] as String?;
    if (endTimeStr != null) {
      try {
        final endTime = DateTime.parse(endTimeStr);
        final remaining = endTime.difference(DateTime.now());
        if (remaining.isNegative) {
          timeLeft = isAr ? 'انتهى' : 'Ended';
        } else if (remaining.inDays > 0) {
          timeLeft = '${remaining.inDays}${isAr ? ' يوم' : 'd'}';
        } else if (remaining.inHours > 0) {
          timeLeft = '${remaining.inHours}${isAr ? ' ساعة' : 'h'}';
        } else {
          timeLeft = '${remaining.inMinutes}${isAr ? ' دقيقة' : 'm'}';
        }
      } catch (_) {}
    }

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        context.push('/product/$productId');
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressAnim,
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
              // Image with overlay
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (image != null)
                      CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFF3F4F6),
                          child: Icon(Icons.gavel_rounded, size: 30.w, color: AppColors.auctionOrange.withAlpha(60)),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFFFF7ED),
                        child: Icon(Icons.gavel_rounded, size: 36.w, color: AppColors.auctionOrange.withAlpha(80)),
                      ),
                    // Live badge
                    Positioned(
                      top: 8.w,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                    // Time left badge
                    if (timeLeft.isNotEmpty)
                      Positioned(
                        top: 8.w,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_rounded, size: 11.w, color: Colors.white),
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
              // Info
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
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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

// ═══════════════════════════════════════════════════════════════════════
// ── HOME PRODUCT CARD ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _HomeProductCard extends StatefulWidget {
  final dynamic product;
  final bool isWishlisted;
  final bool isOwner;
  final bool isLoggedIn;
  final VoidCallback onWishlistToggle;
  final String currency;
  final String locale;

  const _HomeProductCard({
    required this.product,
    required this.isWishlisted,
    required this.isOwner,
    required this.isLoggedIn,
    required this.onWishlistToggle,
    required this.currency,
    required this.locale,
  });

  @override
  State<_HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends State<_HomeProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      onTapUp: (_) {
        _controller.reverse();
        context.push('/product/$id');
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
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
                              placeholder: (_, __) =>
                                  Container(color: const Color(0xFFF3F4F6)),
                              errorWidget: (_, __, ___) => Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFF9CA3AF)),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF3F4F6),
                              child: Icon(Icons.image_outlined,
                                  size: 40.w,
                                  color: const Color(0xFF9CA3AF)),
                            ),
                    ),
                    // Auction badge
                    if (isAuction)
                      Positioned(
                        top: 8.w,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.auctionGradient,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_rounded,
                                  size: 11.w, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(
                                widget.locale == 'ar' ? 'مزاد' : 'Auction',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Wishlist button
                    if (widget.isLoggedIn && !widget.isOwner)
                      Positioned(
                        top: 8.w,
                        left: 8.w,
                        child: GestureDetector(
                          onTap: widget.onWishlistToggle,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: widget.isWishlisted
                                  ? AppColors.errorRed
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Icon(
                              widget.isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16.w,
                              color: widget.isWishlisted
                                  ? Colors.white
                                  : AppColors.slate400,
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
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800,
                              height: 1.3)),
                      const Spacer(),
                      Text(
                        '${double.tryParse(price)?.toStringAsFixed(0) ?? price} ${widget.currency}',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary700),
                      ),
                      if (location != null && location.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.w, color: AppColors.slate400),
                          SizedBox(width: 2.w),
                          Expanded(
                              child: Text(location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.slate400))),
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
