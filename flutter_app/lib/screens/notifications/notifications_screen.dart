import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/notifications_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      _notifications = await NotificationsService.list();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // Group notifications by relative date
  Map<String, List<dynamic>> _grouped(bool isAr) {
    final groups = <String, List<dynamic>>{};
    final now = DateTime.now();
    for (final n in _notifications) {
      final created = n['created_at'] as String?;
      String group = isAr ? 'أخرى' : 'Other';
      if (created != null) {
        try {
          final dt = DateTime.parse(created).toLocal();
          final diff = now.difference(dt);
          if (diff.inDays == 0) {
            group = isAr ? 'اليوم' : 'Today';
          } else if (diff.inDays == 1) {
            group = isAr ? 'أمس' : 'Yesterday';
          } else if (diff.inDays < 7) {
            group = isAr ? 'هذا الأسبوع' : 'This Week';
          } else {
            group = isAr ? 'سابقاً' : 'Earlier';
          }
        } catch (_) {}
      }
      groups.putIfAbsent(group, () => []).add(n);
    }
    return groups;
  }

  // Icon/color by notification type
  _NotifStyle _getStyle(dynamic n) {
    final title = (n['title'] as String? ?? '').toLowerCase();
    final msg = (n['message'] as String? ?? '').toLowerCase();
    final combined = '$title $msg';

    if (combined.contains('bid') ||
        combined.contains('outbid') ||
        combined.contains('مزايدة') ||
        combined.contains('auction') ||
        combined.contains('مزاد')) {
      return _NotifStyle(
        icon: Icons.gavel_rounded,
        color: AppColors.auctionOrange,
        bgColor: const Color(0xFFFFF7ED),
      );
    }
    if (combined.contains('message') ||
        combined.contains('رسالة') ||
        combined.contains('chat')) {
      return _NotifStyle(
        icon: Icons.chat_bubble_rounded,
        color: AppColors.primary600,
        bgColor: AppColors.primary50,
      );
    }
    if (combined.contains('agent') ||
        combined.contains('وكيل') ||
        combined.contains('ai') ||
        combined.contains('ذكي')) {
      return _NotifStyle(
        icon: Icons.smart_toy_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF3F0FF),
      );
    }
    if (combined.contains('price') ||
        combined.contains('سعر') ||
        combined.contains('discount')) {
      return _NotifStyle(
        icon: Icons.trending_down_rounded,
        color: AppColors.successGreen,
        bgColor: const Color(0xFFECFDF5),
      );
    }
    if (combined.contains('welcome') ||
        combined.contains('مرحباً') ||
        combined.contains('congrat')) {
      return _NotifStyle(
        icon: Icons.celebration_rounded,
        color: const Color(0xFFE11D48),
        bgColor: const Color(0xFFFFF1F2),
      );
    }
    return _NotifStyle(
      icon: Icons.notifications_rounded,
      color: AppColors.slate600,
      bgColor: const Color(0xFFF1F5F9),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['notifications'] as Map<String, dynamic>;
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
              // ── Content ─────────────────────────────────
              Expanded(
                child: _loading
                    ? _buildShimmerList()
                    : _notifications.isEmpty
                        ? _buildEmptyState(dict, isAr)
                        : RefreshIndicator(
                            onRefresh: _fetch,
                            child: _buildGroupedList(isAr, dict),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> dict, bool isAr) {
    final unreadCount =
        _notifications.where((n) => n['is_read'] != true).length;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 20.w, color: AppColors.slate700),
            ),
          ),
          SizedBox(width: 12.w),
          // Icon + Title
          Stack(
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
                child: Icon(Icons.notifications_rounded,
                    size: 20.w, color: Colors.white),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFAFBFC), width: 2),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dict['title'] as String,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    isAr
                        ? '$unreadCount غير مقروءة'
                        : '$unreadCount unread',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          // Mark all read
          if (_notifications.any((n) => n['is_read'] != true))
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await NotificationsService.markAllRead();
                _fetch();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: Text(
                  dict['markAllRead'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildGroupedList(bool isAr, Map<String, dynamic> dict) {
    final groups = _grouped(isAr);
    final keys = groups.keys.toList();
    int itemIndex = 0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      itemCount:
          keys.length + groups.values.fold<int>(0, (s, l) => s + l.length),
      itemBuilder: (_, index) {
        int runningIndex = 0;
        for (final key in keys) {
          if (index == runningIndex) {
            // Section header
            return Padding(
              padding: EdgeInsets.only(
                  top: runningIndex == 0 ? 4.h : 16.h, bottom: 8.h),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                  letterSpacing: 0.5,
                ),
              ),
            ).animate().fadeIn(duration: 200.ms);
          }
          runningIndex++;
          final items = groups[key]!;
          for (int j = 0; j < items.length; j++) {
            if (index == runningIndex) {
              final n = items[j];
              final style = _getStyle(n);
              final isRead = n['is_read'] == true;
              itemIndex++;
              return Dismissible(
                key: Key(n['id']?.toString() ?? '$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 22.w),
                ),
                onDismissed: (_) {
                  HapticFeedback.lightImpact();
                  setState(
                      () => _notifications.removeWhere((x) => x['id'] == n['id']));
                },
                child: _NotifCard(
                  notification: n,
                  style: style,
                  isRead: isRead,
                  isAr: isAr,
                ).animate()
                    .fadeIn(
                        delay: Duration(milliseconds: 40 * itemIndex),
                        duration: 300.ms)
                    .slideX(begin: 0.05, end: 0),
              );
            }
            runningIndex++;
          }
        }
        return const SizedBox.shrink();
      },
    );
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
                width: 44.w,
                height: 44.w,
                borderRadius: BorderRadius.circular(14.r)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(
                      width: 160.w,
                      height: 14.h,
                      borderRadius: BorderRadius.circular(4.r)),
                  SizedBox(height: 6.h),
                  AppShimmer(
                      width: 220.w,
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
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 48.w, color: AppColors.primary300),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          SizedBox(height: 16.h),
          Text(
            dict['empty'] as String,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 6.h),
          Text(
            isAr
                ? 'ستصلك إشعارات عند أي تحديث'
                : "You'll be notified of any updates",
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
class _NotifStyle {
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _NotifStyle(
      {required this.icon, required this.color, required this.bgColor});
}

// ═══════════════════════════════════════════════════════════════════════
// ── NOTIFICATION CARD ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _NotifCard extends StatelessWidget {
  final dynamic notification;
  final _NotifStyle style;
  final bool isRead;
  final bool isAr;

  const _NotifCard({
    required this.notification,
    required this.style,
    required this.isRead,
    required this.isAr,
  });

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return isAr ? 'الآن' : 'Now';
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} ${isAr ? 'دقيقة' : 'min'}';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours} ${isAr ? 'ساعة' : 'h'}';
      }
      if (diff.inDays < 7) {
        return '${diff.inDays} ${isAr ? 'يوم' : 'd'}';
      }
      final d = dt;
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : style.bgColor.withAlpha(180),
        borderRadius: BorderRadius.circular(16.r),
        border: !isRead
            ? Border.all(color: style.color.withAlpha(25))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isRead ? 4 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(style.icon, size: 18.w, color: style.color),
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
                        n['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                              isRead ? FontWeight.w600 : FontWeight.w800,
                          color: AppColors.slate800,
                        ),
                      ),
                    ),
                    // Time
                    Text(
                      _timeAgo(n['created_at'] as String?),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  n['message'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.slate500,
                    height: 1.4,
                  ),
                ),
                // Reasoning (AI)
                if ((n['reasoning'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: const Color(0xFF7C3AED).withAlpha(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 12.w, color: const Color(0xFF7C3AED)),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            n['reasoning'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF7C3AED),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Unread dot
          if (!isRead)
            Container(
              margin: EdgeInsets.only(top: 4.h, left: 6.w),
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
