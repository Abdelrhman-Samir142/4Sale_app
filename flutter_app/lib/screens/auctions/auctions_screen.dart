import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../providers/auctions_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/offline_banner.dart';
import 'dart:async';

class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});
  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAuctionsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final pState = ref.watch(paginatedAuctionsProvider);
    final dict = lang.dict;
    final isAr = lang.locale == 'ar';

    // Filter displayed list based on selected tab
    final allItems = pState.items;
    final endingSoon = allItems.where((a) {
      final endStr = a['end_time'] as String?;
      if (endStr == null) return false;
      try {
        final end = DateTime.parse(endStr);
        final remaining = end.difference(DateTime.now());
        return !remaining.isNegative && remaining.inHours < 6;
      } catch (_) {
        return false;
      }
    }).toList();

    final currentList = switch (_tabController.index) {
      1 => endingSoon,
      2 => allItems, // "My Bids" placeholder
      _ => allItems,
    };

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ──────────────────────────────────
                  _buildHeader(isAr, dict),
                  // ── Tab Bar ─────────────────────────────────
                  _buildTabBar(isAr),
                  // ── Content ─────────────────────────────────
                  Expanded(
                    child: pState.isLoading
                        ? _buildShimmerList()
                        : currentList.isEmpty
                            ? AppEmptyState(
                                title: isAr ? 'لا توجد مزادات' : 'No Auctions',
                                subtitle: isAr
                                    ? 'تابعنا لأحدث المزادات المباشرة'
                                    : 'Check back for live auctions',
                                icon: Icons.gavel_rounded,
                              )
                            : RefreshIndicator(
                                onRefresh: () => ref
                                    .read(paginatedAuctionsProvider.notifier)
                                    .refresh(),
                                color: AppColors.auctionOrange,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(
                                      16.w, 8.h, 16.w, 100.h),
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  // +1 for load-more footer
                                  itemCount: currentList.length +
                                      (pState.hasMore ? 1 : 0),
                                  itemBuilder: (_, i) {
                                    // Load-more footer
                                    if (i == currentList.length) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.h),
                                        child: Center(
                                          child: pState.isLoadingMore
                                              ? const CircularProgressIndicator(
                                                  color: AppColors.auctionOrange,
                                                  strokeWidth: 2)
                                              : const SizedBox.shrink(),
                                        ),
                                      );
                                    }
                                    return _PremiumAuctionCard(
                                      auction: currentList[i],
                                      dict: dict,
                                      isAr: isAr,
                                    )
                                        .animate()
                                        .fadeIn(
                                            delay: Duration(
                                                milliseconds: 80 * i.clamp(0, 5)),
                                            duration: 350.ms)
                                        .slideY(
                                            begin: 0.08,
                                            end: 0,
                                            delay: Duration(
                                                milliseconds:
                                                    80 * i.clamp(0, 5)));
                                  },
                                ),
                              ),
                  ),
                ],
              ),
              const OfflineBanner(),
            ],
          ),
        ),
        // ── Add Auction FAB ─────────────────────────
        floatingActionButton: _buildFab(isAr),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isAr, Map<String, dynamic> dict) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: AppColors.auctionGradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auctionOrange.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.gavel_rounded, size: 22.w, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dict['nav']['auctions'] as String,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isAr ? 'زايد واكسب الصفقة' : 'Bid & win the deal',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withAlpha(15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.errorRed.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.3, duration: 800.ms),
                SizedBox(width: 5.w),
                Text(
                  isAr ? 'مباشر' : 'LIVE',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorRed,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isAr) {
    final tabs = [
      isAr ? 'الكل' : 'All',
      isAr ? 'ينتهي قريباً' : 'Ending Soon',
      isAr ? 'مزايداتي' : 'My Bids',
    ];
    final icons = [
      Icons.grid_view_rounded,
      Icons.timer_rounded,
      Icons.person_rounded,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
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
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.slate500,
          labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          padding: EdgeInsets.all(3.w),
          tabs: List.generate(3, (i) {
            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[i], size: 15.w),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(tabs[i],
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AppShimmer(
          width: double.infinity,
          height: 160.h,
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildFab(bool isAr) {
    return Container(
      margin: EdgeInsets.only(bottom: 60.h),
      child: FloatingActionButton.extended(
        onPressed: () => context.push('/sell'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: AppColors.auctionGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.auctionOrange.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20.w),
              SizedBox(width: 6.w),
              Text(
                isAr ? 'مزاد جديد' : 'New Auction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── PREMIUM AUCTION CARD ────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _PremiumAuctionCard extends StatefulWidget {
  final dynamic auction;
  final Map<String, dynamic> dict;
  final bool isAr;
  const _PremiumAuctionCard({
    required this.auction,
    required this.dict,
    required this.isAr,
  });
  @override
  State<_PremiumAuctionCard> createState() => _PremiumAuctionCardState();
}

class _PremiumAuctionCardState extends State<_PremiumAuctionCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String _timeLeft = '';
  bool _isUrgent = false;
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pressAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
    _startTimer();
  }

  void _startTimer() {
    final endStr = widget.auction['end_time'] as String?;
    if (endStr == null) return;
    try {
      final endTime = DateTime.parse(endStr);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final diff = endTime.difference(DateTime.now());
        if (diff.isNegative) {
          setState(() {
            _timeLeft = widget.isAr ? 'انتهى' : 'Ended';
            _isUrgent = false;
          });
          _timer?.cancel();
        } else {
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          final s = diff.inSeconds % 60;
          setState(() {
            _timeLeft =
                '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
            _isUrgent = diff.inHours < 1;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final title = a['product_title'] as String? ?? a['title'] as String? ?? '';
    final currentBid = a['current_bid']?.toString() ?? '0';
    final totalBids = (a['total_bids'] as num?)?.toInt() ?? 0;
    final currency = widget.dict['currency'] as String;
    final image = a['product_image'] as String? ??
        a['product']?['primary_image'] as String?;
    final productId =
        a['product']?.toString() ?? a['product_id']?.toString() ?? '';

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
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: _isUrgent
                    ? AppColors.errorRed.withAlpha(15)
                    : Colors.black.withAlpha(8),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: _isUrgent
                  ? AppColors.errorRed.withAlpha(40)
                  : AppColors.auctionOrange.withAlpha(15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Image ────────────────────────────────
                SizedBox(
                  width: 120.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image != null)
                        CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFFFF7ED)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFFFF7ED),
                            child: Icon(Icons.gavel_rounded,
                                size: 30.w,
                                color: AppColors.auctionOrange.withAlpha(60)),
                          ),
                        )
                      else
                        Container(
                          color: const Color(0xFFFFF7ED),
                          child: Icon(Icons.gavel_rounded,
                              size: 36.w,
                              color: AppColors.auctionOrange.withAlpha(80)),
                        ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(100),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bid count badge
                      Positioned(
                        bottom: 6.w,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_rounded,
                                  size: 10.w, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(
                                '$totalBids',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700),
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Current bid
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppColors.auctionOrange.withAlpha(15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                widget.isAr ? 'أعلى مزايدة' : 'Top Bid',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.auctionOrange,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${double.tryParse(currentBid)?.toStringAsFixed(0) ?? currentBid} $currency',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.auctionOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Timer + Bid button
                        Row(
                          children: [
                            // Timer
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: _isUrgent
                                    ? AppColors.errorRed.withAlpha(12)
                                    : AppColors.slate50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: _isUrgent
                                      ? AppColors.errorRed.withAlpha(30)
                                      : const Color(0xFFE8ECF0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 13.w,
                                    color: _isUrgent
                                        ? AppColors.errorRed
                                        : AppColors.slate500,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _timeLeft.isEmpty ? '...' : _timeLeft,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
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
                            const Spacer(),
                            // Bid button
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 7.h),
                              decoration: BoxDecoration(
                                gradient: AppColors.auctionGradient,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.auctionOrange.withAlpha(30),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
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
                                    widget.isAr ? 'زايد' : 'Bid',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
