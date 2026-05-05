import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final String route;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}

class QuickActions extends StatelessWidget {
  final LanguageState lang;
  final Map<String, dynamic> homeDict;

  const QuickActions({super.key, required this.lang, required this.homeDict});

  List<_QuickAction> _buildActions() {
    final isAr = lang.locale == 'ar';
    return [
      _QuickAction(
        icon: Icons.store_rounded,
        label: homeDict['marketplace'] as String? ??
            (isAr ? 'المتجر' : 'Marketplace'),
        color: AppColors.primary600,
        bgColor: AppColors.primary50,
        route: '/store',
      ),
      _QuickAction(
        icon: Icons.gavel_rounded,
        label: lang.dict['nav']['auctions'] as String,
        color: AppColors.auctionOrange,
        bgColor: const Color(0xFFFFF7ED),
        route: '/auctions',
      ),
      _QuickAction(
        icon: Icons.smart_toy_rounded,
        label: homeDict['aiAgent'] as String? ??
            (isAr ? 'وكيل ذكي' : 'AI Agent'),
        color: AppColors.recommendedPurple,
        bgColor: const Color(0xFFFAF5FF),
        route: '/agent',
      ),
      _QuickAction(
        icon: Icons.favorite_rounded,
        label: lang.dict['nav']['wishlist'] as String,
        color: AppColors.errorRed,
        bgColor: const Color(0xFFFEF2F2),
        route: '/wishlist',
      ),
      _QuickAction(
        icon: Icons.search_rounded,
        label: homeDict['smartSearch'] as String? ??
            (isAr ? 'بحث ذكي' : 'Smart Search'),
        color: AppColors.latestBlue,
        bgColor: const Color(0xFFEFF6FF),
        route: '/search',
      ),
      _QuickAction(
        icon: Icons.add_circle_rounded,
        label: homeDict['addListing'] as String? ??
            (isAr ? 'أضف إعلان' : 'Add Listing'),
        color: AppColors.successGreen,
        bgColor: const Color(0xFFF0FDF4),
        route: '/sell',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.15,
        ),
        itemCount: actions.length,
        itemBuilder: (_, i) => _QuickActionCard(action: actions[i])
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 150 + (i * 50)), duration: 350.ms)
            .slideY(
                begin: 0.2,
                end: 0,
                delay: Duration(milliseconds: 150 + (i * 50))),
      ),
    );
  }
}

// ── Card with press animation ────────────────────────────────────────────
class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        context.push(widget.action.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: widget.action.color.withAlpha(12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.action.color.withAlpha(15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: widget.action.bgColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(widget.action.icon,
                    size: 22.w, color: widget.action.color),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.action.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
