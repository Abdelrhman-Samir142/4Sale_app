import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/chat_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});
  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  List<dynamic> _conversations = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchC = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      _conversations = await ChatService.getConversations();
      _filtered = List.from(_conversations);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_conversations);
      } else {
        _filtered = _conversations.where((c) {
          final other = c['other_participant'] as Map<String, dynamic>?;
          final name = (other?['username'] as String? ?? '').toLowerCase();
          final product = (c['product_title'] as String? ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) ||
              product.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['chat'] as Map<String, dynamic>;
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              _buildHeader(dict, isAr),
              // ── Search Bar ──────────────────────────────
              if (_showSearch) _buildSearchBar(isAr),
              // ── Content ─────────────────────────────────
              Expanded(
                child: _loading
                    ? _buildShimmerList()
                    : _filtered.isEmpty
                        ? _buildEmptyState(dict, isAr)
                        : RefreshIndicator(
                            onRefresh: _fetch,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  16.w, 4.h, 16.w, 100.h),
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) =>
                                  _ConversationTile(
                                    conversation: _filtered[i],
                                    dict: dict,
                                    isAr: isAr,
                                  ).animate()
                                      .fadeIn(
                                          delay: Duration(
                                              milliseconds: 60 * i),
                                          duration: 300.ms)
                                      .slideX(begin: 0.05, end: 0),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> dict, bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary600.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.chat_rounded, size: 22.w, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dict['title'] as String,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isAr ? 'تواصل مع البائعين' : 'Connect with sellers',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Search toggle
          GestureDetector(
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchC.clear();
                _onSearch('');
              }
            }),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _showSearch
                    ? AppColors.primary50
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
                border: _showSearch
                    ? Border.all(color: AppColors.primary200)
                    : null,
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                size: 20.w,
                color: _showSearch ? AppColors.primary600 : AppColors.slate600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar(bool isAr) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
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
        child: TextField(
          controller: _searchC,
          onChanged: _onSearch,
          autofocus: true,
          style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
          decoration: InputDecoration(
            hintText: isAr ? 'ابحث في المحادثات...' : 'Search conversations...',
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.slate400),
            prefixIcon: Icon(Icons.search_rounded,
                size: 20.w, color: AppColors.slate400),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          children: [
            AppShimmer(
                width: 52.w,
                height: 52.w,
                borderRadius: BorderRadius.circular(16.r)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(
                      width: 120.w,
                      height: 14.h,
                      borderRadius: BorderRadius.circular(4.r)),
                  SizedBox(height: 6.h),
                  AppShimmer(
                      width: 200.w,
                      height: 12.h,
                      borderRadius: BorderRadius.circular(4.r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, dynamic> dict, bool isAr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48.w, color: AppColors.primary300),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          SizedBox(height: 16.h),
          Text(
            dict['noConversations'] as String,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 6.h),
          Text(
            isAr
                ? 'ابدأ محادثة من صفحة أي منتج'
                : 'Start a chat from any product page',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.slate400,
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── CONVERSATION TILE ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _ConversationTile extends StatelessWidget {
  final dynamic conversation;
  final Map<String, dynamic> dict;
  final bool isAr;

  const _ConversationTile({
    required this.conversation,
    required this.dict,
    required this.isAr,
  });

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return isAr ? 'الآن' : 'Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}${isAr ? 'د' : 'm'}';
      if (diff.inHours < 24) return '${diff.inHours}${isAr ? 'س' : 'h'}';
      if (diff.inDays < 7) return '${diff.inDays}${isAr ? 'ي' : 'd'}';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final other = c['other_participant'] as Map<String, dynamic>?;
    final lastMsg = c['last_message'] as Map<String, dynamic>?;
    final unread = (c['unread_count'] as num?)?.toInt() ?? 0;
    final username = other?['username'] as String? ?? '?';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final product = c['product_title'] as String? ?? '';
    final lastTime = lastMsg?['created_at'] as String? ??
        c['updated_at'] as String? ??
        c['created_at'] as String?;

    // Generate a consistent color from username
    final hue = (username.codeUnits.fold<int>(0, (s, c) => s + c) * 37) % 360;
    final avatarColor = HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.6).toColor();
    final avatarBg = HSLColor.fromAHSL(1, hue.toDouble(), 0.4, 0.94).toColor();

    return GestureDetector(
      onTap: () => context.push('/chat/${c['id']}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: unread > 0 ? AppColors.primary50.withAlpha(120) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(unread > 0 ? 8 : 4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: unread > 0
              ? Border.all(color: AppColors.primary200.withAlpha(60))
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                // Online dot
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                unread > 0 ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.slate800,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(lastTime),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                              unread > 0 ? FontWeight.w700 : FontWeight.w500,
                          color: unread > 0
                              ? AppColors.primary600
                              : AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // Product tag
                  if (product.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 3.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg?['content'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            color: unread > 0
                                ? AppColors.slate700
                                : AppColors.slate400,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$unread',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
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
    );
  }
}
