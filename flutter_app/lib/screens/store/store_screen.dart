import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/wishlist_service.dart';
import '../home/widgets/home_product_card.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});
  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> with TickerProviderStateMixin {
  final List<dynamic> _products = [];
  Set<int> _wishlistIds = {};
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'all';

  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _fetchProducts();
    _fetchWishlist();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await DioClient.instance.get(
        ApiConstants.products,
        queryParameters: _selectedCategory != 'all' ? {'category': _selectedCategory} : null,
      );
      if (!mounted) return;
      final data = res.data;
      setState(() {
        _products.clear();
        if (data is Map && data['results'] != null) {
          _products.addAll(data['results'] as List);
        } else if (data is List) {
          _products.addAll(data);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
          if (res['is_wishlisted'] == true) {
            _wishlistIds.add(id);
          } else {
            _wishlistIds.remove(id);
          }
        });
      }
    } catch (_) {}
  }

  void _onCategoryChanged(String cat) {
    setState(() => _selectedCategory = cat);
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';
    final auth = ref.watch(authProvider);
    final user = auth.user;

    final categories = [
      {'id': 'all', 'en': 'All', 'ar': 'الكل', 'icon': Icons.grid_view_rounded},
      {'id': 'electronics', 'en': 'Electronics', 'ar': 'إلكترونيات', 'icon': Icons.devices_rounded},
      {'id': 'furniture', 'en': 'Furniture', 'ar': 'أثاث', 'icon': Icons.chair_rounded},
      {'id': 'cars', 'en': 'Cars', 'ar': 'سيارات', 'icon': Icons.directions_car_rounded},
      {'id': 'scrap_metals', 'en': 'Scrap', 'ar': 'خردة', 'icon': Icons.recycling_rounded},
      {'id': 'real_estate', 'en': 'Real Estate', 'ar': 'عقارات', 'icon': Icons.home_work_rounded},
    ];

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC), // Light theme
        body: Stack(
          children: [
            _buildAnimatedBg(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(isAr),
                  _buildCategoryFilter(categories, isAr),
                  if (_loading)
                    const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary500))))
                  else if (_error != null)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(_error!, style: TextStyle(color: Colors.redAccent, fontSize: 16.sp)),
                        ),
                      ),
                    )
                  else if (_products.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 60.w, color: AppColors.slate400),
                              SizedBox(height: 16.h),
                              Text(isAr ? 'لا توجد منتجات' : 'No products found',
                                  style: TextStyle(color: AppColors.slate500, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.all(16.w),
                      sliver: SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          final id = p['id'] as int;
                          return HomeProductCard(
                            product: p,
                            isWishlisted: _wishlistIds.contains(id),
                            isOwner: auth.userId != null && p['owner_id'] == auth.userId,
                            isLoggedIn: user != null,
                            onWishlistToggle: () => _toggleWishlist(id),
                            currency: isAr ? 'ج.م' : 'EGP',
                            locale: lang.locale,
                          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
                        },
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBg() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, _) {
        return Stack(
          children: [
            Positioned(
              top: -100.h, left: -50.w,
              child: Container(
                width: 300.w, height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary500.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100.h, right: -100.w,
              child: Container(
                width: 400.w, height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.slate500.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isAr) {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFFFAFBFC),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: FlexibleSpaceBar(
            titlePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            centerTitle: false,
            title: Text(
              isAr ? 'المتجر' : 'Store',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.slate900,
                letterSpacing: 0.5,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary50,
                        const Color(0xFFFAFBFC),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: isAr ? null : 20.w,
                  left: isAr ? 20.w : null,
                  bottom: 50.h,
                  child: Icon(Icons.storefront_rounded, size: 80.w, color: AppColors.primary100),
                ).animate().scale(curve: Curves.easeOutBack, duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate900, size: 16),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildCategoryFilter(List<Map<String, dynamic>> categories, bool isAr) {
    return SliverToBoxAdapter(
      child: Container(
        height: 60.h,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = _selectedCategory == cat['id'];
            return GestureDetector(
              onTap: () => _onCategoryChanged(cat['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary500 : Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary400 : AppColors.slate200,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary500.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Icon(cat['icon'], size: 18.w, color: isSelected ? Colors.white : AppColors.slate500),
                    SizedBox(width: 8.w),
                    Text(
                      isAr ? cat['ar'] : cat['en'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.slate500,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
          },
        ),
      ),
    );
  }
}
