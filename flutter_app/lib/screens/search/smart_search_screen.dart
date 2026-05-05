import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/rag_service.dart';
import '../../services/products_service.dart';
import '../../models/product.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import 'dart:math' as math;

class SmartSearchScreen extends ConsumerStatefulWidget {
  const SmartSearchScreen({super.key});
  @override
  ConsumerState<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends ConsumerState<SmartSearchScreen>
    with TickerProviderStateMixin {
  final _queryC = TextEditingController();
  final _focusNode = FocusNode();
  Map<String, dynamic>? _result;
  // Real product objects fetched after RAG returns IDs
  List<Product> _products = [];
  bool _loading = false;
  bool _loadingProducts = false;
  String? _error;
  late AnimationController _brainCtrl;
  late AnimationController _waveCtrl;

  static const _suggestionsAr = [
    'لابتوب رخيص أقل من 5000',
    'أثاث مستعمل حالة جيدة',
    'أجهزة إلكترونية في القاهرة',
    'سيارات مستعملة أقل من 100000',
    'موبايلات سامسونج جديدة',
    'كراسي مكتب مستعملة',
  ];

  static const _suggestionsEn = [
    'Cheap laptop under 5000',
    'Used furniture in good condition',
    'Electronics in Cairo',
    'Used cars under 100000',
    'New Samsung phones',
    'Used office chairs',
  ];

  @override
  void initState() {
    super.initState();
    _brainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _queryC.dispose();
    _focusNode.dispose();
    _brainCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  Future<void> _search([String? query]) async {
    final q = query ?? _queryC.text.trim();
    if (q.isEmpty) return;
    _queryC.text = q;
    _focusNode.unfocus();
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _products = [];
    });
    try {
      _result = await RagService.query(q);
      // Fetch full product details for each returned ID
      final ids = (_result?['answer']?['items'] as List?) ?? [];
      if (ids.isNotEmpty) {
        setState(() => _loadingProducts = true);
        final fetched = <Product>[];
        for (final id in ids) {
          try {
            final p = await ProductsService.get(id.toString());
            fetched.add(p);
          } catch (_) {}
        }
        if (mounted) {
          setState(() {
            _products = fetched;
            _loadingProducts = false;
          });
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['search'] as Map<String, dynamic>;
    final isAr = lang.locale == 'ar';
    final suggestions = isAr ? _suggestionsAr : _suggestionsEn;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ------------------------- Hero Header -------------------------
            SliverToBoxAdapter(child: _buildHero(dict, isAr)),
            // ------------------------- Search Bar -------------------------
            SliverToBoxAdapter(child: _buildSearchBar(dict, isAr)),
            // ------------------------- Content -------------------------
            if (!_loading && _result == null && _error == null)
              SliverToBoxAdapter(child: _buildSuggestions(suggestions, isAr)),
            if (_loading) SliverToBoxAdapter(child: _buildLoadingState(isAr)),
            if (_error != null)
              SliverToBoxAdapter(child: _buildErrorState(isAr)),
            if (_result != null && !_loading)
              SliverToBoxAdapter(child: _buildResults(isAr)),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // HERO
  // -----------------------------------------------------------------------
  Widget _buildHero(Map<String, dynamic> dict, bool isAr) {
    return Stack(
      children: [
        // Background
        Container(
          height: 230.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F4C3A)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
          ),
        ),
        // Animated particles
        ...List.generate(5, (i) {
          return AnimatedBuilder(
            animation: _brainCtrl,
            builder: (_, __) {
              final phase = _brainCtrl.value * 2 * math.pi + (i * 1.26);
              final r = (50 + i * 20).toDouble();
              final cx = MediaQuery.of(context).size.width / 2;
              final x = cx + math.cos(phase) * r.w - 4.w;
              final y = 100.h + math.sin(phase) * (r * 0.5).h;
              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: (4 + i * 2).w,
                  height: (4 + i * 2).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [
                      AppColors.primary400,
                      const Color(0xFF7C3AED),
                      AppColors.primary300,
                      const Color(0xFF4F46E5),
                      AppColors.successGreen,
                    ][i].withAlpha(60 + i * 15),
                  ),
                ),
              );
            },
          );
        }),
        // Content
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: Column(
              children: [
                // Back + Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      dict['title'] as String,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                SizedBox(height: 20.h),
                // AI Brain Icon + Tagline
                AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (_, __) {
                    return Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary400.withAlpha(
                              (40 + _waveCtrl.value * 30).toInt(),
                            ),
                            Colors.transparent,
                          ],
                          radius: 1.0 + _waveCtrl.value * 0.3,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 32.w,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                SizedBox(height: 10.h),
                Text(
                  isAr
                      ? 'اسأل الذكاء الاصطناعي عن أي شيء'
                      : 'Ask AI about anything',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                SizedBox(height: 3.h),
                Text(
                  isAr
                      ? 'بيبحث في كل المنتجات ويلاقيلك الأنسب'
                      : 'Searches all products to find the best match',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withAlpha(150),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // SEARCH BAR
  // -----------------------------------------------------------------------
  Widget _buildSearchBar(Map<String, dynamic> dict, bool isAr) {
    return Transform.translate(
      offset: Offset(0, -22.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary600.withAlpha(12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryC,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _search(),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
                  decoration: InputDecoration(
                    hintText: dict['placeholder'] as String,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.slate400,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Icon(
                        Icons.search_rounded,
                        size: 22.w,
                        color: AppColors.primary500,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 48.w,
                      minHeight: 48.h,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),
              // Search button
              GestureDetector(
                onTap: _loading ? null : _search,
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary600.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 20.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  // -----------------------------------------------------------------------
  // SUGGESTIONS
  // -----------------------------------------------------------------------
  Widget _buildSuggestions(List<String> suggestions, bool isAr) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18.w,
                color: AppColors.warningAmber,
              ),
              SizedBox(width: 6.w),
              Text(
                isAr ? 'جرّب تسأل عن:' : 'Try asking about:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: suggestions.asMap().entries.map((e) {
              return GestureDetector(
                    onTap: () => _search(e.value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE8ECF0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 14.w,
                            color: AppColors.primary500,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.slate600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 400 + e.key * 60),
                    duration: 300.ms,
                  )
                  .slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
          SizedBox(height: 24.h),
          // How it works
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary50.withAlpha(120),
                  const Color(0xFFF3F0FF).withAlpha(120),
                ],
              ),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.primary200.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'كيف يعمل البحث الذكي؟'
                      : 'How does Smart Search work?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
                SizedBox(height: 10.h),
                _howItWorksRow(
                  Icons.text_fields_rounded,
                  isAr
                      ? 'اكتب وصف بكلماتك العادية'
                      : 'Describe what you want naturally',
                  AppColors.primary600,
                ),
                SizedBox(height: 8.h),
                _howItWorksRow(
                  Icons.psychology_rounded,
                  isAr
                      ? 'الذكاء الاصطناعي يفهم احتياجك'
                      : 'AI understands your needs',
                  const Color(0xFF7C3AED),
                ),
                SizedBox(height: 8.h),
                _howItWorksRow(
                  Icons.shopping_bag_rounded,
                  isAr
                      ? 'يرشحلك أفضل المنتجات'
                      : 'Recommends best products',
                  AppColors.auctionOrange,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  Widget _howItWorksRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withAlpha(12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.w, color: color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // LOADING STATE
  // -----------------------------------------------------------------------
  Widget _buildLoadingState(bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Animated brain
          AnimatedBuilder(
                animation: _brainCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: math.sin(_brainCtrl.value * math.pi * 2) * 0.05,
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary50,
                      border: Border.all(
                        color: AppColors.primary200.withAlpha(60),
                      ),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 36.w,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.05, duration: 1200.ms),
          SizedBox(height: 16.h),
          Text(
                isAr
                    ? 'الذكاء الاصطناعي يبحث...'
                    : 'AI is searching...',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms),
          SizedBox(height: 6.h),
          Text(
            isAr
                ? 'بيدور في كل المنتجات عشان يلاقيلك الأنسب'
                : 'Scanning all products to find the best match',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.slate400),
          ),
          SizedBox(height: 24.h),
          // Progress shimmer cards
          ...List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: AppShimmer(
                width: double.infinity,
                height: 60.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // ERROR
  // -----------------------------------------------------------------------
  Widget _buildErrorState(bool isAr) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withAlpha(8),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.errorRed.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.errorRed,
              size: 22.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(fontSize: 12.sp, color: AppColors.errorRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // RESULTS
  // -----------------------------------------------------------------------

  Widget _buildResults(bool isAr) {
    final summary = _result?['answer']?['summary'] as String? ?? '';
    final meta = _result?['meta'] as Map<String, dynamic>?;
    final currency = ref.read(languageProvider).dict['currency'] as String;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(25),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16.w,
                          color: AppColors.primary400,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isAr ? 'ملخص الذكاء الاصطناعي' : 'AI Summary',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withAlpha(220),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          if (_loadingProducts) ...[
            SizedBox(height: 20.h),
            ...List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: AppShimmer(
                  width: double.infinity,
                  height: 90.h,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ] else if (_products.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  size: 18.w,
                  color: AppColors.primary600,
                ),
                SizedBox(width: 6.w),
                Text(
                  isAr
                      ? 'المنتجات المقترحة'
                      : 'Recommended Products',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${_products.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 10.h),
            ..._products.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              final image = p.primaryImage;
              final title = p.title;
              final price = p.price;
              final location = p.location;
              final isAuction = p.isAuction;
              final id = p.id.toString();

              return GestureDetector(
                    onTap: () => context.push('/product/$id'),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFEEF0F2)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              bottomLeft: Radius.circular(16.r),
                            ),
                            child: image != null
                                ? CachedNetworkImage(
                                    imageUrl: image,
                                    width: 90.w,
                                    height: 90.w,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 90.w,
                                      height: 90.w,
                                      color: const Color(0xFFF3F4F6),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 90.w,
                                      height: 90.w,
                                      color: const Color(0xFFF3F4F6),
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 28.w,
                                        color: AppColors.slate300,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 90.w,
                                    height: 90.w,
                                    color: const Color(0xFFF3F4F6),
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 28.w,
                                      color: AppColors.slate300,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '#${i + 1} ${isAr ? "أفضل تطابق" : "Best match"}',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.slate800,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                      color: isAuction
                                          ? AppColors.auctionOrange
                                          : AppColors.primary600,
                                    ),
                                  ),
                                  if (location.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 11.w,
                                          color: AppColors.slate400,
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Text(
                                            location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: AppColors.primary50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.w,
                                color: AppColors.primary600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 300 + i * 80),
                    duration: 350.ms,
                  )
                  .slideX(begin: 0.05, end: 0);
            }),
          ],

          if (meta != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 14.w,
                    color: AppColors.slate400,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${meta["latency_ms"]}ms - SQL: ${meta["sql_results"]} - Vector: ${meta["vector_results"]}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ],
      ),
    );
  }
}
