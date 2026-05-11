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
import '../../shared/widgets/app_search_bar.dart';

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
  double? _minPrice;
  double? _maxPrice;
  String? _condition;

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
      final queryParams = <String, dynamic>{};
      if (_selectedCategory != 'all') queryParams['category'] = _selectedCategory;
      if (_minPrice != null) queryParams['min_price'] = _minPrice;
      if (_maxPrice != null) queryParams['max_price'] = _maxPrice;
      if (_condition != null) queryParams['condition'] = _condition;

      final res = await DioClient.instance.get(
        ApiConstants.products,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (!mounted) return;
      final data = res.data;
      setState(() {
        _products.clear();
        final rawProducts = data is Map && data['results'] != null 
            ? (data['results'] as List) 
            : (data is List ? data : []);
            
        final authState = ref.read(authProvider);
        final currentUserId = authState.userId;
        
        _products.addAll(rawProducts.where((p) {
          final isPending = p['status'] == 'pending';
          final isOwner = currentUserId != null && p['owner_id'] == currentUserId;
          return !isPending || isOwner;
        }));
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
      {'id': 'appliances', 'en': 'Appliances', 'ar': 'أجهزة منزلية', 'icon': Icons.blender_rounded},
      {'id': 'furniture', 'en': 'Furniture', 'ar': 'أثاث', 'icon': Icons.chair_rounded},
      {'id': 'cars', 'en': 'Cars', 'ar': 'سيارات', 'icon': Icons.directions_car_rounded},
      {'id': 'scrap_metals', 'en': 'Scrap', 'ar': 'خردة', 'icon': Icons.recycling_rounded},
      {'id': 'real_estate', 'en': 'Real Estate', 'ar': 'عقارات', 'icon': Icons.home_work_rounded},
      {'id': 'books', 'en': 'Books', 'ar': 'كتب', 'icon': Icons.menu_book_rounded},
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
                  const SliverToBoxAdapter(child: AppSearchBar()),
                  _buildCategoryFilter(categories, isAr),
                  if (_loading)
                    const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary500))))
                  else if (_error != null)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(_error!, style: TextStyle(color: Colors.redAccent, fontSize: 16.sp)),
                        ),
                      ),
                    )
                  else if (_products.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
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
      builder: (_, __) {
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
                      AppColors.primary500.withAlpha(13),
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
                      AppColors.slate500.withAlpha(13),
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary50,
                        Color(0xFFFAFBFC),
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
              BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate900, size: 16),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.slate900, size: 18),
          ),
          onPressed: _showFilterSheet,
        ),
        SizedBox(width: 8.w),
      ],
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
                      ? [BoxShadow(color: AppColors.primary500.withAlpha(102), blurRadius: 12, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
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

  void _showFilterSheet() {
    final lang = ref.read(languageProvider);
    final isAr = lang.locale == 'ar';
    
    // Local state for the bottom sheet
    double? tempMinPrice = _minPrice;
    double? tempMaxPrice = _maxPrice;
    String? tempCondition = _condition;

    // Price options (min, max)
    final priceOptions = [
      {'label': isAr ? 'الكل' : 'All', 'min': null, 'max': null},
      {'label': isAr ? 'أقل من 1,000' : 'Under 1,000', 'min': null, 'max': 1000.0},
      {'label': '1,000 - 5,000', 'min': 1000.0, 'max': 5000.0},
      {'label': '5,000 - 10,000', 'min': 5000.0, 'max': 10000.0},
      {'label': isAr ? 'أكثر من 10,000' : 'Above 10,000', 'min': 10000.0, 'max': null},
    ];

    // Condition options
    final conditionOptions = [
      {'label': isAr ? 'الكل' : 'All', 'value': null},
      {'label': isAr ? 'جديد' : 'New', 'value': 'new'},
      {'label': isAr ? 'شبه جديد' : 'Like New', 'value': 'like-new'},
      {'label': isAr ? 'جيد' : 'Good', 'value': 'good'},
      {'label': isAr ? 'مقبول' : 'Acceptable', 'value': 'fair'},
    ];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(top: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        isAr ? 'تصفية المنتجات' : 'Filter Products',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Scrollable Area
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price Section
                            Text(
                              isAr ? 'نطاق السعر (جنيه)' : 'Price Range (EGP)',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.slate800),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 10.h,
                              children: priceOptions.map((opt) {
                                final isSelected = tempMinPrice == opt['min'] && tempMaxPrice == opt['max'];
                                return ChoiceChip(
                                  label: Text(opt['label'] as String),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setStateSheet(() {
                                        tempMinPrice = opt['min'] as double?;
                                        tempMaxPrice = opt['max'] as double?;
                                      });
                                    }
                                  },
                                  selectedColor: AppColors.primary50,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.primary600 : AppColors.slate600,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    side: BorderSide(color: isSelected ? AppColors.primary400 : AppColors.slate200),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 24.h),

                            // Condition Section
                            Text(
                              isAr ? 'حالة المنتج' : 'Condition',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.slate800),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 10.h,
                              children: conditionOptions.map((opt) {
                                final isSelected = tempCondition == opt['value'];
                                return ChoiceChip(
                                  label: Text(opt['label'] as String),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setStateSheet(() {
                                        tempCondition = opt['value'] as String?;
                                      });
                                    }
                                  },
                                  selectedColor: AppColors.primary50,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.primary600 : AppColors.slate600,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    side: BorderSide(color: isSelected ? AppColors.primary400 : AppColors.slate200),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),

                    // Fixed Footer with Action Buttons
                    Container(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Reset Button
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                side: const BorderSide(color: AppColors.slate300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              ),
                              onPressed: () {
                                setStateSheet(() {
                                  tempMinPrice = null;
                                  tempMaxPrice = null;
                                  tempCondition = null;
                                });
                              },
                              child: Text(
                                isAr ? 'إعادة ضبط' : 'Reset',
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.slate700),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Apply Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary600,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              ),
                              onPressed: () {
                                // Update main state and fetch
                                setState(() {
                                  _minPrice = tempMinPrice;
                                  _maxPrice = tempMaxPrice;
                                  _condition = tempCondition;
                                });
                                Navigator.pop(ctx);
                                _fetchProducts();
                              },
                              child: Text(
                                isAr ? 'تطبيق' : 'Apply Filters',
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
}
