import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> _stats = {};
  List<dynamic> _products = [];
  List<dynamic> _auctions = [];
  List<dynamic> _conversations = [];
  bool _loading = true;
  int _selectedTab = 0;
  late AnimationController _glowCtrl;
  late AnimationController _chartCtrl;

  final _tabs = ['Overview', 'Products', 'Auctions', 'Users'];
  final _tabsAr = ['نظرة عامة', 'المنتجات', 'المزادات', 'المستخدمون'];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _chartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _fetchAll();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _chartCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    try {
      final results = await Future.wait([
        AdminService.getStats(),
        AdminService.getAllProducts(),
        AdminService.getAllAuctions(),
        AdminService.getAllConversations(),
      ]);
      if (mounted) {
        setState(() {
          _stats = (results[0] is Map<String, dynamic>)
              ? results[0] as Map<String, dynamic>
              : {};
          _products = (results[1] is List) ? results[1] as List : [];
          _auctions = (results[2] is List) ? results[2] as List : [];
          _conversations = (results[3] is List) ? results[3] as List : [];
          _loading = false;
        });
        _chartCtrl.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: _loading
            ? _buildLoadingState()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(isAr)),
                  SliverToBoxAdapter(child: _buildTabBar(isAr)),
                  if (_selectedTab == 0) ...[
                    SliverToBoxAdapter(child: _buildKpiCards(isAr)),
                    SliverToBoxAdapter(child: _buildActivityChart(isAr)),
                    SliverToBoxAdapter(child: _buildRecentActivity(isAr)),
                  ],
                  if (_selectedTab == 1)
                    SliverToBoxAdapter(child: _buildProductsPanel(isAr)),
                  if (_selectedTab == 2)
                    SliverToBoxAdapter(child: _buildAuctionsPanel(isAr)),
                  if (_selectedTab == 3)
                    SliverToBoxAdapter(child: _buildUsersPanel(isAr)),
                  SliverToBoxAdapter(child: SizedBox(height: 40.h)),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, MediaQuery.of(context).padding.top + 12.h, 20.w, 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withAlpha(8)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 20.w, color: Colors.white),
            ),
          ),
          SizedBox(width: 14.w),
          // Admin badge
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) {
              return Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFEF4444),
                          const Color(0xFFF97316), _glowCtrl.value)!,
                      Color.lerp(const Color(0xFFF97316),
                          const Color(0xFFEAB308), _glowCtrl.value)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316)
                          .withAlpha((20 + _glowCtrl.value * 20).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.admin_panel_settings_rounded,
                    size: 20.w, color: Colors.white),
              );
            },
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'لوحة التحكم' : 'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isAr ? 'مرحباً مدير النظام' : 'Welcome, Admin',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          // Refresh
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _loading = true);
              _fetchAll();
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.refresh_rounded,
                  size: 20.w, color: Colors.white.withAlpha(150)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isAr) {
    final labels = isAr ? _tabsAr : _tabs;
    final icons = [
      Icons.dashboard_rounded,
      Icons.inventory_2_rounded,
      Icons.gavel_rounded,
      Icons.people_rounded,
    ];
    return Container(
      height: 44.h,
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withAlpha(6)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withAlpha(10)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[i],
                      size: 14.w,
                      color: selected
                          ? Colors.white
                          : Colors.white.withAlpha(60),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : Colors.white.withAlpha(60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // KPI CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildKpiCards(bool isAr) {
    final kpis = [
      _KpiData(
        icon: Icons.inventory_2_rounded,
        value: '${_stats['total_products'] ?? _products.length}',
        label: isAr ? 'منتجات' : 'Products',
        color: AppColors.primary500,
        gradient: [const Color(0xFF059669), const Color(0xFF34D399)],
      ),
      _KpiData(
        icon: Icons.gavel_rounded,
        value: '${_stats['total_auctions'] ?? _auctions.length}',
        label: isAr ? 'مزادات' : 'Auctions',
        color: AppColors.auctionOrange,
        gradient: [const Color(0xFFF97316), const Color(0xFFFBBF24)],
      ),
      _KpiData(
        icon: Icons.people_rounded,
        value: '${_stats['total_users'] ?? 0}',
        label: isAr ? 'مستخدمون' : 'Users',
        color: const Color(0xFF7C3AED),
        gradient: [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
      ),
      _KpiData(
        icon: Icons.chat_bubble_rounded,
        value: '${_stats['total_conversations'] ?? _conversations.length}',
        label: isAr ? 'محادثات' : 'Chats',
        color: AppColors.latestBlue,
        gradient: [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.6,
        ),
        itemCount: kpis.length,
        itemBuilder: (_, i) {
          final kpi = kpis[i];
          return AnimatedBuilder(
            animation: _chartCtrl,
            builder: (_, __) {
              final progress = Curves.easeOutBack
                  .transform((_chartCtrl.value * (1 + i * 0.15)).clamp(0, 1));
              return _buildKpiCard(kpi, progress);
            },
          ).animate()
              .fadeIn(delay: Duration(milliseconds: 200 + i * 80))
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildKpiCard(_KpiData kpi, double progress) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF1E293B).withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: kpi.color.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: kpi.color.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: kpi.gradient),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(kpi.icon, size: 16.w, color: Colors.white),
              ),
              const Spacer(),
              // Mini sparkline indicator
              SizedBox(
                width: 40.w,
                height: 20.h,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    color: kpi.color,
                    progress: progress,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kpi.value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                kpi.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withAlpha(100),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIVITY CHART
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActivityChart(bool isAr) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withAlpha(6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 18.w, color: AppColors.primary400),
                SizedBox(width: 8.w),
                Text(
                  isAr ? 'نشاط المنصة' : 'Platform Activity',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 12.w, color: AppColors.successGreen),
                      SizedBox(width: 3.w),
                      Text(
                        '+12%',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Bar chart
            SizedBox(
              height: 140.h,
              child: AnimatedBuilder(
                animation: _chartCtrl,
                builder: (_, __) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildBarChartBars(),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            // X-axis labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isAr ? 'سبت' : 'Sat',
                isAr ? 'أحد' : 'Sun',
                isAr ? 'إثن' : 'Mon',
                isAr ? 'ثلا' : 'Tue',
                isAr ? 'أربع' : 'Wed',
                isAr ? 'خمس' : 'Thu',
                isAr ? 'جمع' : 'Fri',
              ]
                  .map((d) => Text(d,
                      style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white.withAlpha(60))))
                  .toList(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0);
  }

  List<Widget> _buildBarChartBars() {
    final values = [0.4, 0.65, 0.55, 0.85, 0.7, 0.95, 0.6];
    final colors = [
      AppColors.primary500,
      AppColors.primary400,
      const Color(0xFF7C3AED),
      AppColors.auctionOrange,
      AppColors.primary500,
      AppColors.successGreen,
      AppColors.latestBlue,
    ];

    return List.generate(7, (i) {
      final h = values[i] * 120.h * _chartCtrl.value;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors[i],
                      colors[i].withAlpha(100),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // RECENT ACTIVITY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentActivity(bool isAr) {
    // Combine all data into a timeline
    final activities = <_ActivityItem>[];

    for (final p in _products.take(3)) {
      activities.add(_ActivityItem(
        icon: Icons.inventory_2_rounded,
        color: AppColors.primary500,
        title: p['title'] ?? '',
        subtitle: isAr ? 'منتج جديد' : 'New product',
        time: p['created_at'] ?? '',
      ));
    }
    for (final a in _auctions.take(2)) {
      final productData = a['product'];
      final productTitle = (productData is Map<String, dynamic>)
          ? productData['title'] ?? 'Auction #${a['id']}'
          : 'Auction #${a['id']}';
      activities.add(_ActivityItem(
        icon: Icons.gavel_rounded,
        color: AppColors.auctionOrange,
        title: productTitle,
        subtitle: isAr ? 'مزاد نشط' : 'Active auction',
        time: a['created_at'] ?? '',
      ));
    }
    for (final c in _conversations.take(2)) {
      final otherUser = c['other_user'];
      final otherName = (otherUser is Map<String, dynamic>)
          ? otherUser['username'] ?? ''
          : '';
      activities.add(_ActivityItem(
        icon: Icons.chat_bubble_rounded,
        color: AppColors.latestBlue,
        title: otherName,
        subtitle: isAr ? 'محادثة جديدة' : 'New conversation',
        time: c['last_message_time'] ?? '',
      ));
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withAlpha(6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline_rounded,
                    size: 18.w, color: AppColors.warningAmber),
                SizedBox(width: 8.w),
                Text(
                  isAr ? 'آخر النشاطات' : 'Recent Activity',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            if (activities.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد نشاطات حديثة' : 'No recent activity',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.white.withAlpha(60)),
                  ),
                ),
              )
            else
              ...activities.asMap().entries.map((e) {
                final a = e.value;
                final isLast = e.key == activities.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot + line
                    Column(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: a.color.withAlpha(15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child:
                              Icon(a.icon, size: 16.w, color: a.color),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 24.h,
                            color: Colors.white.withAlpha(8),
                          ),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            Text(
                              a.subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withAlpha(80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                    delay: Duration(milliseconds: 600 + e.key * 100));
              }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // PRODUCTS PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductsPanel(bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Header
          _panelHeader(
            icon: Icons.inventory_2_rounded,
            title: isAr ? 'إدارة المنتجات' : 'Manage Products',
            count: _products.length,
            color: AppColors.primary500,
          ),
          SizedBox(height: 10.h),
          // List
          if (_products.isEmpty)
            _emptyPanel(
                isAr ? 'لا توجد منتجات' : 'No products', Icons.inventory_2_outlined)
          else
            ...(_products.asMap().entries.map((e) {
              final p = e.value;
              final isAuction = p['is_auction'] == true;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withAlpha(6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        gradient: isAuction
                            ? AppColors.auctionGradient
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        isAuction
                            ? Icons.gavel_rounded
                            : Icons.inventory_2_rounded,
                        size: 18.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${p['price'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary400,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: (p['condition'] == 'new'
                                          ? AppColors.successGreen
                                          : AppColors.warningAmber)
                                      .withAlpha(15),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '${p['condition'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: p['condition'] == 'new'
                                        ? AppColors.successGreen
                                        : AppColors.warningAmber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    GestureDetector(
                      onTap: () => context.push('/product/${p['id']}'),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.visibility_rounded,
                            size: 16.w, color: Colors.white.withAlpha(100)),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        await AdminService.deleteProduct(
                            p['id'].toString());
                        setState(
                            () => _products.removeAt(e.key));
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withAlpha(10),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 16.w, color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 + e.key * 50));
            })),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AUCTIONS PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAuctionsPanel(bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _panelHeader(
            icon: Icons.gavel_rounded,
            title: isAr ? 'إدارة المزادات' : 'Manage Auctions',
            count: _auctions.length,
            color: AppColors.auctionOrange,
          ),
          SizedBox(height: 10.h),
          if (_auctions.isEmpty)
            _emptyPanel(
                isAr ? 'لا توجد مزادات' : 'No auctions', Icons.gavel_outlined)
          else
            ...(_auctions.asMap().entries.map((e) {
              final a = e.value;
              final productData = a['product'];
              final productTitle = (productData is Map<String, dynamic>)
                  ? productData['title'] ?? 'Auction #${a['id']}'
                  : 'Auction #${a['id']}';
              final isActive = a['is_active'] == true;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isActive
                        ? AppColors.auctionOrange.withAlpha(20)
                        : Colors.white.withAlpha(6),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.auctionGradient,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.gavel_rounded,
                          size: 18.w, color: Colors.white),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${a['current_bid'] ?? a['starting_price'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.auctionOrange,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.successGreen
                                      : AppColors.slate400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                isActive
                                    ? (isAr ? 'نشط' : 'Active')
                                    : (isAr ? 'منتهي' : 'Ended'),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isActive
                                      ? AppColors.successGreen
                                      : AppColors.slate400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bid count
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.auctionOrange.withAlpha(10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_rounded,
                              size: 12.w, color: AppColors.auctionOrange),
                          SizedBox(width: 3.w),
                          Text(
                            '${(a['bids'] is List) ? (a['bids'] as List).length : 0}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.auctionOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 + e.key * 50));
            })),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // USERS PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUsersPanel(bool isAr) {
    // Extract unique users from conversations
    final users = <Map<String, dynamic>>[];
    final seenIds = <int>{};
    for (final c in _conversations) {
      final other = c['other_user'];
      if (other is Map<String, dynamic> && other['id'] != null) {
        final id = other['id'] as int;
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          users.add(other);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _panelHeader(
            icon: Icons.people_rounded,
            title: isAr ? 'المستخدمون' : 'Users',
            count: (_stats['total_users'] is int) ? _stats['total_users'] as int : users.length,
            color: const Color(0xFF7C3AED),
          ),
          SizedBox(height: 10.h),
          // User stats card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withAlpha(6)),
            ),
            child: Row(
              children: [
                _userStatChip(
                  Icons.people_alt_rounded,
                  '${_stats['total_users'] ?? users.length}',
                  isAr ? 'إجمالي' : 'Total',
                  const Color(0xFF7C3AED),
                ),
                SizedBox(width: 12.w),
                _userStatChip(
                  Icons.circle,
                  '${_stats['active_users'] ?? 0}',
                  isAr ? 'نشط' : 'Active',
                  AppColors.successGreen,
                ),
                SizedBox(width: 12.w),
                _userStatChip(
                  Icons.new_releases_rounded,
                  '${_stats['new_users_today'] ?? 0}',
                  isAr ? 'جديد اليوم' : 'New Today',
                  AppColors.warningAmber,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: 10.h),
          // User list
          if (users.isEmpty)
            _emptyPanel(isAr ? 'لا توجد بيانات' : 'No user data',
                Icons.people_outline)
          else
            ...(users.asMap().entries.map((e) {
              final u = e.value;
              final name = u['username'] as String? ?? '';
              final initial =
                  name.isNotEmpty ? name[0].toUpperCase() : '?';
              final hue =
                  (name.codeUnits.fold<int>(0, (s, c) => s + c) * 37) %
                      360;
              final color =
                  HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.55)
                      .toColor();

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withAlpha(6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          Text(
                            u['email'] ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white.withAlpha(60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: 200 + e.key * 50));
            })),
        ],
      ),
    );
  }

  Widget _userStatChip(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16.w, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white.withAlpha(80),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARED PANEL WIDGETS
  // ═══════════════════════════════════════════════════════════════
  Widget _panelHeader({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withAlpha(180)]),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 16.w, color: Colors.white),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _emptyPanel(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(icon, size: 48.w, color: Colors.white.withAlpha(30)),
          SizedBox(height: 10.h),
          Text(text,
              style: TextStyle(
                  fontSize: 13.sp, color: Colors.white.withAlpha(60))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOADING STATE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Header shimmer
            Row(
              children: [
                AppShimmer(
                    width: 40.w,
                    height: 40.w,
                    borderRadius: BorderRadius.circular(12.r)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer(
                          width: 150.w,
                          height: 18.h,
                          borderRadius: BorderRadius.circular(6.r)),
                      SizedBox(height: 6.h),
                      AppShimmer(
                          width: 100.w,
                          height: 12.h,
                          borderRadius: BorderRadius.circular(4.r)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // KPIs shimmer
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.6,
              children: List.generate(
                  4,
                  (_) => AppShimmer(
                      width: double.infinity,
                      height: 100.h,
                      borderRadius: BorderRadius.circular(18.r))),
            ),
            SizedBox(height: 16.h),
            AppShimmer(
                width: double.infinity,
                height: 200.h,
                borderRadius: BorderRadius.circular(20.r)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════════
class _KpiData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final List<Color> gradient;
  const _KpiData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.gradient,
  });
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

// ═══════════════════════════════════════════════════════════════════
// SPARKLINE PAINTER
// ═══════════════════════════════════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  final Color color;
  final double progress;
  _SparklinePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [0.3, 0.5, 0.2, 0.7, 0.4, 0.8, 0.6];
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width * progress;
      final y = size.height - (points[i] * size.height * progress);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX =
            ((i - 1) / (points.length - 1)) * size.width * progress;
        final prevY =
            size.height - (points[i - 1] * size.height * progress);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Glow dot at the end
    if (progress > 0.9) {
      final lastX = size.width * progress;
      final lastY =
          size.height - (points.last * size.height * progress);
      canvas.drawCircle(
        Offset(lastX, lastY),
        3,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        6,
        Paint()..color = color.withAlpha(30),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
