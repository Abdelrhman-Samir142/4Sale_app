import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        vsync: this, duration: const Duration(milliseconds: 3000))
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
        AppSnackbar.error(
            context, isAr ? 'فشل تحميل الإعلانات' : 'Failed to load listings');
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
    final sellerRating = user['seller_rating']?.toString() ?? '0.0';
    final walletBalance = user['wallet_balance']?.toString() ?? '0.00';
    final totalSales = (user['total_sales'] as num?)?.toInt() ?? 0;
    final firstName = (userInfo['first_name'] as String?) ?? '';
    final lastName = (userInfo['last_name'] as String?) ?? '';
    final fullName = '$firstName $lastName'.trim();
    final username = (userInfo['username'] as String?) ?? '';
    final email = (userInfo['email'] as String?) ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    final hue = (username.codeUnits.fold<int>(0, (s, c) => s + c) * 37) % 360;
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.50, 0.50).toColor();

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9), // Soft premium background
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Premium Glass Header & Wallet Card ────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeaderAndWallet(
                initial, fullName, username, email, avatarColor, isAr, user, walletBalance, currency,
              ),
            ),
            
            // ── Bento Dashboard Stats ─────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildBentoDashboard(sellerRating, totalSales, trustScore, dict, isAr),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            
            // ── Actions Menu ──────────────────────────
            SliverToBoxAdapter(
              child: _buildActionMenu(dict, isAr, auth.isAdmin),
            ),
            
            // ── My Listings ────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionTitle(dict['myListings'] as String, isAr,
                  actionIcon: Icons.add_rounded,
                  actionOnTap: () => context.push('/sell')),
            ),
            _buildListingsList(currency),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM HEADER & WALLET (UNIFIED LAYOUT)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeaderAndWallet(
      String initial, String fullName, String username, String email,
      Color avatarColor, bool isAr, Map<String, dynamic> user, String walletBalance, String currency) {
    final mockAvatarPath = user['mock_avatar'] as String?;

    return Stack(
      children: [
        // Background Gradient & Animation (Fixed Height)
        AnimatedBuilder(
          animation: _headerCtrl,
          builder: (_, __) {
            return Container(
              height: 280.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF0F172A), const Color(0xFF1E293B), _headerCtrl.value)!,
                    Color.lerp(AppColors.primary800, AppColors.primary700, _headerCtrl.value)!,
                    Color.lerp(AppColors.primary600, const Color(0xFF3B82F6), _headerCtrl.value)!,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.r),
                  bottomRight: Radius.circular(40.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary600.withAlpha(50),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            );
          },
        ),
        
        // Abstract Shapes
        Positioned(
          right: -50.w,
          top: -30.h,
          child: Container(
            width: 150.w, height: 150.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(10)),
          ),
        ),
        Positioned(
          left: -40.w,
          bottom: 120.h,
          child: Container(
            width: 100.w, height: 100.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(5)),
          ),
        ),

        // Main Content Flow
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                child: Column(
                  children: [
                    // Top Bar (Settings / Notifications)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'لوحة التحكم' : 'Dashboard',
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                        ),
                        Row(
                          children: [
                            _glassIconButton(Icons.favorite_rounded, () => context.push('/wishlist')),
                            SizedBox(width: 12.w),
                            _glassIconButton(Icons.notifications_rounded, () => context.push('/notifications')),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                    
                    SizedBox(height: 30.h),

                    // Profile Info (Avatar + Details)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with glowing ring
                        Container(
                          width: 80.w, height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Colors.white, Colors.white70], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: Colors.white.withAlpha(40), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E293B)),
                              child: CircleAvatar(
                                backgroundColor: avatarColor.withAlpha(100),
                                backgroundImage: mockAvatarPath != null ? FileImage(File(mockAvatarPath)) : null,
                                child: mockAvatarPath == null
                                    ? Text(initial, style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: Colors.white))
                                    : null,
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        
                        SizedBox(width: 20.w),

                        // Name & Edit Button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isNotEmpty ? fullName : username,
                                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '@$username',
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.white70),
                              ),
                              SizedBox(height: 12.h),
                              GestureDetector(
                                onTap: () => _showEditProfileSheet(context, ref, user),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: Colors.white.withAlpha(40)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_rounded, size: 14.w, color: Colors.white),
                                      SizedBox(width: 6.w),
                                      Text(
                                        isAr ? 'تعديل الملف' : 'Edit Profile',
                                        style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Wallet Card seamlessly attached at the bottom
              _buildWalletCard(walletBalance, currency, isAr),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Icon(icon, size: 22.w, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WALLET CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWalletCard(String walletBalance, String currency, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary600, size: 20.w),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        isAr ? 'رصيد المحفظة' : 'Wallet Balance',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.slate500),
                      ),
                    ],
                  ),
                  Icon(Icons.more_horiz_rounded, color: AppColors.slate400),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                '${double.tryParse(walletBalance)?.toStringAsFixed(2) ?? walletBalance} $currency',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      onPressed: () => _showAddBalanceDialog(context, ref),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20.w),
                          SizedBox(width: 6.w),
                          Text(
                            isAr ? 'شحن المحفظة' : 'Add Funds',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary50,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      onPressed: () {
                        AppSnackbar.info(context, isAr ? 'السحب غير متاح حالياً' : 'Withdrawal coming soon');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded, color: AppColors.primary700, size: 18.w),
                          SizedBox(width: 4.w),
                          Text(
                            isAr ? 'سحب الرصيد' : 'Withdraw',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primary700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════
  // BENTO DASHBOARD STATS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBentoDashboard(
      String sellerRating, int totalSales, int trustScore, Map<String, dynamic> dict, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _bentoCard(
                    title: dict['trustScore'] as String,
                    value: '$trustScore%',
                    icon: Icons.verified_user_rounded,
                    color: _getTrustColor(trustScore),
                    subtitle: isAr ? 'مستوى الثقة' : 'Trust Level',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _bentoCard(
                    title: dict['sellerRating'] as String,
                    value: sellerRating,
                    icon: Icons.star_rounded,
                    color: AppColors.warningAmber,
                    subtitle: isAr ? 'تقييم البائع' : 'Seller Rating',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _bentoCard(
                    title: dict['totalSales'] as String,
                    value: totalSales.toString(),
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.auctionOrange,
                    subtitle: isAr ? 'المبيعات الناجحة' : 'Successful Sales',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _bentoCard(
                    title: dict['activeListings'] as String,
                    value: _listings.length.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF8B5CF6),
                    subtitle: isAr ? 'الإعلانات الحالية' : 'Current Ads',
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Color _getTrustColor(int score) {
    if (score > 70) return AppColors.successGreen;
    if (score > 40) return AppColors.warningAmber;
    return AppColors.errorRed;
  }

  Widget _bentoCard({required String title, required String value, required IconData icon, required Color color, required String subtitle}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: color.withAlpha(15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20.w),
              ),
              Icon(Icons.arrow_outward_rounded, size: 16.w, color: AppColors.slate300),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.slate800),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.slate600),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.sp, color: AppColors.slate400),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIONS MENU (iOS SETTINGS STYLE)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActionMenu(Map<String, dynamic> dict, bool isAr, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'الإعدادات العامة' : 'General Settings',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.slate800),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                if (isAdmin) ...[
                  _menuTile(
                    icon: Icons.admin_panel_settings_rounded,
                    title: isAr ? 'لوحة التحكم' : 'Admin Dashboard',
                    color: AppColors.errorRed,
                    onTap: () => context.push('/admin'),
                  ),
                  _divider(),
                ],
                _menuTile(
                  icon: Icons.smart_toy_rounded,
                  title: isAr ? 'الوكيل الذكي (AI)' : 'AI Agent',
                  color: const Color(0xFF6366F1),
                  onTap: () => context.push('/agent'),
                ),
                _divider(),
                _menuTile(
                  icon: Icons.settings_rounded,
                  title: isAr ? 'إعدادات الحساب' : 'Account Settings',
                  color: AppColors.slate600,
                  onTap: () => context.push('/settings'),
                ),
                _divider(),
                _menuTile(
                  icon: Icons.language_rounded,
                  title: dict['changeLanguage'] as String,
                  trailingText: isAr ? 'English' : 'العربية',
                  color: AppColors.latestBlue,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(languageProvider.notifier).toggle();
                  },
                ),
                _divider(),
                _menuTile(
                  icon: Icons.logout_rounded,
                  title: dict['logout'] as String,
                  color: AppColors.errorRed,
                  hideChevron: true,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(authProvider.notifier).logout();
                    if (mounted) AuthGuard.performStrictLogout(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _menuTile({required IconData icon, required String title, required Color color, required VoidCallback onTap, String? trailingText, bool hideChevron = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(icon, color: color, size: 20.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.slate800),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.slate400),
                ),
                SizedBox(width: 8.w),
              ],
              if (!hideChevron) Icon(Icons.chevron_right_rounded, size: 20.w, color: AppColors.slate300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9), indent: 60.w);

  // ═══════════════════════════════════════════════════════════════
  // SECTION TITLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionTitle(String title, bool isAr, {IconData? actionIcon, VoidCallback? actionOnTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.slate800),
          ),
          if (actionIcon != null)
            GestureDetector(
              onTap: actionOnTap,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(actionIcon, size: 20.w, color: AppColors.primary600),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EDIT PROFILE SHEET
  // ═══════════════════════════════════════════════════════════════
  void _showEditProfileSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> user) {
    final lang = ref.read(languageProvider);
    final isAr = lang.locale == 'ar';
    final userInfo = user['user'] as Map<String, dynamic>? ?? {};
    
    final firstNameC = TextEditingController(text: userInfo['first_name'] as String? ?? '');
    final lastNameC = TextEditingController(text: userInfo['last_name'] as String? ?? '');
    
    String? pickedImagePath = user['mock_avatar'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                left: 20.w, right: 20.w, top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40.w, height: 5.h, decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(10.r))),
                    SizedBox(height: 24.h),
                    Text(isAr ? 'تعديل الملف الشخصي' : 'Edit Profile', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    SizedBox(height: 24.h),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final xFile = await picker.pickImage(source: ImageSource.gallery);
                        if (xFile != null) setStateSheet(() => pickedImagePath = xFile.path);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary100, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 46.w,
                              backgroundColor: AppColors.primary50,
                              backgroundImage: pickedImagePath != null ? FileImage(File(pickedImagePath!)) : null,
                              child: pickedImagePath == null ? Icon(Icons.add_a_photo_rounded, size: 30.w, color: AppColors.primary500) : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(color: AppColors.primary600, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: Icon(Icons.camera_alt_rounded, size: 14.w, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    TextField(
                      controller: firstNameC,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الاسم الأول' : 'First Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: lastNameC,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الاسم الأخير' : 'Last Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity, height: 56.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary600, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                        onPressed: () {
                          ref.read(authProvider.notifier).updateUserMock(firstName: firstNameC.text.trim(), lastName: lastNameC.text.trim(), mockAvatarPath: pickedImagePath);
                          Navigator.pop(ctx);
                          AppSnackbar.success(context, isAr ? 'تم تعديل البيانات بنجاح' : 'Data updated successfully');
                        },
                        child: Text(isAr ? 'حفظ التعديلات' : 'Save Changes', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD BALANCE DIALOG
  // ═══════════════════════════════════════════════════════════════
  void _showAddBalanceDialog(BuildContext context, WidgetRef ref) {
    final lang = ref.read(languageProvider);
    final isAr = lang.locale == 'ar';
    final amountC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text(isAr ? 'شحن المحفظة' : 'Add Balance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp, color: AppColors.slate900)),
          content: TextField(
            controller: amountC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isAr ? 'المبلغ (ريال)' : 'Amount (SAR)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
              prefixIcon: const Icon(Icons.attach_money_rounded),
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              onPressed: () {
                final amountToAdd = double.tryParse(amountC.text.trim()) ?? 0.0;
                if (amountToAdd > 0) {
                  final currentUser = ref.read(authProvider).user;
                  if (currentUser != null) {
                    final currentBalance = double.tryParse(currentUser['wallet_balance']?.toString() ?? '0') ?? 0.0;
                    ref.read(authProvider.notifier).updateUserMock(walletBalance: (currentBalance + amountToAdd).toStringAsFixed(2));
                  }
                  Navigator.pop(ctx);
                  AppSnackbar.success(context, isAr ? 'تم إضافة الرصيد بنجاح' : 'Balance added successfully');
                }
              },
              child: Text(isAr ? 'تأكيد' : 'Confirm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LISTINGS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildListingsList(String currency) {
    if (_loadingListings) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: List.generate(3, (i) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: AppShimmer(width: double.infinity, height: 90.h, borderRadius: BorderRadius.circular(20.r)),
            )),
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFE8ECF0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: const BoxDecoration(color: AppColors.primary50, shape: BoxShape.circle),
                  child: Icon(Icons.inventory_2_outlined, size: 40.w, color: AppColors.primary400),
                ),
                SizedBox(height: 16.h),
                Text(
                  ref.read(languageProvider).locale == 'ar' ? 'لا يوجد إعلانات نشطة' : 'No Active Listings',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.slate800),
                ),
                SizedBox(height: 6.h),
                Text(
                  ref.read(languageProvider).locale == 'ar' ? 'أضف أول إعلان لك الآن وابدأ البيع!' : 'Add your first listing now and start selling!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.slate500),
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
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: GestureDetector(
        onTap: () => context.push('/product/${p['id']}'),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: isAuction ? AppColors.auctionGradient : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(isAuction ? Icons.gavel_rounded : Icons.inventory_2_rounded, size: 28.w, color: Colors.white),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.slate900),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: isAuction ? AppColors.auctionOrange : AppColors.primary600,
                          ),
                        ),
                        if (isAuction) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(color: AppColors.auctionOrange.withAlpha(15), borderRadius: BorderRadius.circular(6.r)),
                            child: Text(
                              ref.read(languageProvider).locale == 'ar' ? 'مزاد' : 'Auction',
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.auctionOrange),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: AppColors.slate50, shape: BoxShape.circle),
                child: Icon(Icons.chevron_right_rounded, size: 20.w, color: AppColors.slate400),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 600 + index * 100), duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
