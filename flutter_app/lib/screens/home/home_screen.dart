import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auctions_service.dart';
import '../../services/stats_service.dart';
import '../../services/wishlist_service.dart';

// ── Decoupled UI widgets ────────────────────────────────────────────
import 'widgets/home_app_bar.dart';
import 'widgets/hero_banner.dart';
import 'widgets/quick_actions.dart';
import 'widgets/home_section_header.dart';
import 'widgets/auctions_carousel.dart';
import 'widgets/categories_row.dart';
import 'widgets/ai_features_banner.dart';
import 'widgets/stats_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ── State ──────────────────────────────────────────────────────────
  List<dynamic> _auctions = [];
  Map<String, dynamic> _stats = {};
  bool _loadingAuctions = true;
  bool _loadingStats = true;

  final _scrollController = ScrollController();

  // ── Lifecycle ─────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Data fetching ─────────────────────────────────────────────────
  Future<void> _fetchAll() async {
    _fetchAuctions();
    _fetchStats();
    _prefetchWishlist();
  }

  Future<void> _fetchAuctions() async {
    setState(() => _loadingAuctions = true);
    try {
      final res = await AuctionsService.list(activeOnly: true);
      if (mounted) {
        setState(() {
          _auctions = res.take(5).toList();
          _loadingAuctions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAuctions = false);
    }
  }

  Future<void> _fetchStats() async {
    setState(() => _loadingStats = true);
    try {
      final res = await StatsService.getGeneralStats();
      if (mounted) {
        setState(() {
          _stats = res;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _prefetchWishlist() async {
    try {
      await WishlistService.getIds();
    } catch (_) {}
  }

  // ── Fallback i18n ─────────────────────────────────────────────────
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

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict;
    final homeDict =
        dict['home'] as Map<String, dynamic>? ?? _fallbackHomeDict(lang.locale);

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _fetchAll,
              color: AppColors.primary600,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // ── App Bar ──────────────────────────────
                  const HomeAppBar(),

                  // ── Hero Banner ──────────────────────────
                  SliverToBoxAdapter(
                    child: HeroBanner(lang: lang, homeDict: homeDict),
                  ),

                  // ── Quick Actions ────────────────────────
                  SliverToBoxAdapter(
                    child: QuickActions(lang: lang, homeDict: homeDict),
                  ),

                  // ── Live Auctions Header ─────────────────
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: homeDict['liveAuctions'] as String? ??
                          'Live Auctions',
                      actionText:
                          homeDict['viewAll'] as String? ?? 'View All',
                      icon: Icons.gavel_rounded,
                      accentColor: AppColors.auctionOrange,
                      onAction: () => context.go('/auctions'),
                    ),
                  ),

                  // ── Auctions Carousel ────────────────────
                  SliverToBoxAdapter(
                    child: AuctionsCarousel(
                      auctions: _auctions,
                      loading: _loadingAuctions,
                      lang: lang,
                    ),
                  ),

                  // ── Categories Header ────────────────────
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: (dict['categories']
                              as Map<String, dynamic>?)?['title'] as String? ??
                          'Categories',
                      actionText:
                          homeDict['viewAll'] as String? ?? 'View All',
                      icon: Icons.category_rounded,
                      accentColor: AppColors.recommendedPurple,
                      onAction: () {},
                    ),
                  ),

                  // ── Categories Row ───────────────────────
                  SliverToBoxAdapter(
                    child: CategoriesRow(lang: lang),
                  ),

                  // ── AI Features Banner ───────────────────
                  SliverToBoxAdapter(
                    child: AIFeaturesBanner(
                      homeDict: homeDict,
                      lang: lang,
                    ),
                  ),

                  // ── Stats Section ────────────────────────
                  SliverToBoxAdapter(
                    child: StatsSection(
                      stats: _stats,
                      loading: _loadingStats,
                      dict: dict,
                    ),
                  ),

                  // ── Bottom nav bar clearance ─────────────
                  SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
