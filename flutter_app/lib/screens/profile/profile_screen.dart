import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/products_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../core/auth/auth_guard.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _listings = [];
  bool _loadingListings = true;
  late AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _fetchListings();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchListings() async {
    try {
      _listings = await ProductsService.getMyListings();
    } catch (e) {
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        AppSnackbar.error(context, isAr ? 'فشل تحميل الإعلانات' : 'Failed to load listings');
      }
    }
    if (mounted) setState(() => _loadingListings = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['profile'] as Map<String, dynamic>;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final currency = lang.dict['currency'] as String;
    final isAr = lang.locale == 'ar';

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userInfo = user['user'] as Map<String, dynamic>? ?? {};
    final trustScore =
        ((user['trust_score'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final sellerRating = user['seller_rating']?.toString() ?? '0';
    final walletBalance = user['wallet_balance']?.toString() ?? '0';
    final totalSales = (user['total_sales'] as num?)?.toInt() ?? 0;
    final firstName = (userInfo['first_name'] as String?) ?? '';
    final lastName = (userInfo['last_name'] as String?) ?? '';
    final fullName = '$firstName $lastName'.trim();
    final username = (userInfo['username'] as String?) ?? '';
    final email = (userInfo['email'] as String?) ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    // Color from username
    final hue =
        (username.codeUnits.fold<int>(0, (s, c) => s + c) * 37) % 360;
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.55).toColor();

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero Header ────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeroHeader(
                  initial, fullName, username, email, avatarColor, isAr),
            ),
            // ── Stats Grid ─────────────────────────────
            SliverToBoxAdapter(
              child: _buildStatsGrid(
                  walletBalance, sellerRating, totalSales, trustScore,
                  dict, currency, isAr),
            ),
            // ── Quick Actions ──────────────────────────
            SliverToBoxAdapter(
              child: _buildQuickActions(dict, isAr, auth.isAdmin),
            ),
            // ── Trust Score ────────────────────────────
            SliverToBoxAdapter(
              child: _buildTrustScore(trustScore, dict, isAr),
            ),
            // ── My Listings ────────────────────────────
            SliverToBoxAdapter(
              child: _buildListingsHeader(dict, isAr),
            ),
            _buildListingsList(currency),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeader(String initial, String fullName, String username,
      String email, Color avatarColor, bool isAr) {
    return Stack(
      children: [
        // Background
        AnimatedBuilder(
          animation: _headerCtrl,
          builder: (_, _) {
            return Container(
              height: 280.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(AppColors.primary800, AppColors.primary700,
                        _headerCtrl.value)!,
                    Color.lerp(AppColors.primary600, AppColors.primary500,
                        _headerCtrl.value)!,
                    Color.lerp(const Color(0xFF34D399), AppColors.primary400,
                        _headerCtrl.value)!,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
            );
          },
        ),
        // Decorative circles
        Positioned(
          right: -40.w,
          top: -20.h,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(8),
            ),
          ),
        ),
        Positioned(
          left: -30.w,
          bottom: 40.h,
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(6),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            child: Column(
              children: [
                // Top actions
                Row(
                  children: [
                    Text(
                      isAr ? 'ملفي الشخصي' : 'My Profile',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    _headerIconBtn(Icons.settings_outlined,
                        () => context.push('/settings')),
                    SizedBox(width: 8.w),
                    _headerIconBtn(Icons.favorite_outline_rounded,
                        () => context.push('/wishlist')),
                    SizedBox(width: 8.w),
                    _headerIconBtn(Icons.notifications_none_rounded,
                        () => context.push('/notifications')),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                SizedBox(height: 20.h),
                // Avatar + Info
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withAlpha(150), width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 38.w,
                        backgroundColor: avatarColor.withAlpha(80),
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().scale(
                        duration: 500.ms, curve: Curves.easeOutBack),
                    SizedBox(width: 16.w),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isNotEmpty ? fullName : username,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '@$username',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.email_outlined,
                                    size: 12.w,
                                    color: Colors.white.withAlpha(120)),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white.withAlpha(120),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 8.h),
                          // Edit profile chip
                          GestureDetector(
                            onTap: () => context.push('/edit-profile'),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: Colors.white.withAlpha(40)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 12.w, color: Colors.white),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isAr ? 'تعديل' : 'Edit',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Icon(icon, size: 20.w, color: Colors.white),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS GRID
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsGrid(
      String walletBalance,
      String sellerRating,
      int totalSales,
      int trustScore,
      Map<String, dynamic> dict,
      String currency,
      bool isAr) {
    return Transform.translate(
      offset: Offset(0, -18.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _statTile(
                Icons.account_balance_wallet_rounded,
                walletBalance,
                '${dict['walletBalance']} ($currency)',
                AppColors.primary600,
              ),
              _statDivider(),
              _statTile(
                Icons.star_rounded,
                sellerRating,
                dict['sellerRating'] as String,
                AppColors.warningAmber,
              ),
              _statDivider(),
              _statTile(
                Icons.shopping_bag_rounded,
                totalSales.toString(),
                dict['totalSales'] as String,
                AppColors.auctionOrange,
              ),
              _statDivider(),
              _statTile(
                Icons.list_alt_rounded,
                _listings.length.toString(),
                dict['activeListings'] as String,
                AppColors.latestBlue,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: color.withAlpha(12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.w, color: color),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.slate800,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.slate400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: const Color(0xFFF1F5F9),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickActions(Map<String, dynamic> dict, bool isAr, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isAdmin) ...[
              _quickActionTile(
                icon: Icons.admin_panel_settings_rounded,
                label: isAr ? 'لوحة التحكم' : 'Admin Dashboard',
                subtitle: isAr ? 'إدارة المنصة والمنتجات' : 'Manage platform & products',
                color: AppColors.errorRed,
                onTap: () => context.push('/admin'),
              ),
              _quickActionDivider(),
            ],
            _quickActionTile(
              icon: Icons.smart_toy_rounded,
              label: isAr ? 'الوكيل الذكي' : 'AI Agent',
              subtitle: isAr ? 'إدارة وكلاء المزادات' : 'Manage auction agents',
              color: const Color(0xFF7C3AED),
              onTap: () => context.push('/agent'),
            ),
            _quickActionDivider(),
            _quickActionTile(
              icon: Icons.add_circle_rounded,
              label: isAr ? 'إضافة إعلان' : 'Add Listing',
              subtitle: isAr ? 'أنشر منتج جديد للبيع' : 'Post a new product for sale',
              color: AppColors.successGreen,
              onTap: () => context.push('/sell'),
            ),
            _quickActionDivider(),
            _quickActionTile(
              icon: Icons.language_rounded,
              label: dict['changeLanguage'] as String,
              subtitle: isAr ? 'English' : 'العربية',
              color: AppColors.latestBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(languageProvider.notifier).toggle();
              },
            ),
            _quickActionDivider(),
            _quickActionTile(
              icon: Icons.logout_rounded,
              label: dict['logout'] as String,
              subtitle: isAr ? 'تسجيل الخروج من حسابك' : 'Sign out of your account',
              color: AppColors.errorRed,
              onTap: () async {
                HapticFeedback.mediumImpact();
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  await AuthGuard.performStrictLogout(context);
                }
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withAlpha(10),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.w, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20.w, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }

  Widget _quickActionDivider() {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: const Color(0xFFF1F5F9),
      indent: 56.w,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TRUST SCORE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTrustScore(
      int trustScore, Map<String, dynamic> dict, bool isAr) {
    final color = trustScore > 70
        ? AppColors.successGreen
        : trustScore > 40
            ? AppColors.warningAmber
            : AppColors.errorRed;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withAlpha(12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.verified_user_rounded,
                      size: 18.w, color: color),
                ),
                SizedBox(width: 10.w),
                Text(
                  dict['trustScore'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withAlpha(10),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$trustScore%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                height: 8.h,
                child: Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9)),
                    FractionallySizedBox(
                      widthFactor: trustScore / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withAlpha(180)],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Message
            Text(
              trustScore > 70
                  ? (isAr
                      ? '🌟 مستوى ثقة ممتاز! ده بيزود مبيعاتك'
                      : '🌟 Excellent trust level! This boosts your sales')
                  : trustScore > 40
                      ? (isAr
                          ? '📈 مستوى ثقة جيد. أكمل ملفك لتحسينه'
                          : '📈 Good trust level. Complete your profile to improve')
                      : (isAr
                          ? '⚠️ مستوى ثقة منخفض. حسّن ملفك الشخصي'
                          : '⚠️ Low trust level. Improve your profile'),
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LISTINGS HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildListingsHeader(Map<String, dynamic> dict, bool isAr) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded,
              size: 18.w, color: AppColors.primary600),
          SizedBox(width: 6.w),
          Text(
            dict['myListings'] as String,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.slate800,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${_listings.length}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary600,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/sell'),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary600.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16.w, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    isAr ? 'أضف إعلان' : 'Add Listing',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // LISTINGS LIST
  // ═══════════════════════════════════════════════════════════════
  Widget _buildListingsList(String currency) {
    if (_loadingListings) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: List.generate(
                3,
                (i) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: AppShimmer(
                        width: double.infinity,
                        height: 70.h,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    )),
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFE8ECF0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined,
                      size: 36.w, color: AppColors.primary300),
                ),
                SizedBox(height: 12.h),
                Text(
                  ref.read(languageProvider).locale == 'ar'
                      ? 'لا يوجد إعلانات نشطة'
                      : 'No Active Listings',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ref.read(languageProvider).locale == 'ar'
                      ? 'أضف أول إعلان لك الآن!'
                      : 'Add your first listing now!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _listingTile(_listings[i], currency, i),
        childCount: _listings.length,
      ),
    );
  }

  Widget _listingTile(dynamic p, String currency, int index) {
    final price = p['price']?.toString() ?? '0';
    final isAuction = p['is_auction'] == true;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: GestureDetector(
        onTap: () => context.push('/product/${p['id']}'),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  gradient: isAuction
                      ? AppColors.auctionGradient
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  isAuction
                      ? Icons.gavel_rounded
                      : Icons.inventory_2_rounded,
                  size: 22.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          '${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isAuction
                                ? AppColors.auctionOrange
                                : AppColors.primary600,
                          ),
                        ),
                        if (isAuction) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.auctionOrange.withAlpha(12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              ref.read(languageProvider).locale == 'ar'
                                  ? 'مزاد'
                                  : 'Auction',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.auctionOrange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20.w, color: AppColors.slate300),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(
            delay: Duration(milliseconds: 650 + index * 60),
            duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
