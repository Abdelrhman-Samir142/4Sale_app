import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_colors.dart';

/// ShellScreen — premium bottom navigation bar with center Sell FAB.
class ShellScreen extends ConsumerWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  static int _indexFromPath(String path) {
    if (path.startsWith('/store')) return 0;
    if (path.startsWith('/auctions')) return 1;
    // index 2 is the center FAB (sell) – not a real tab
    if (path.startsWith('/messages')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0; // home/store (dashboard)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict;
    final auth = ref.watch(authProvider);
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromPath(path);

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        body: child,
        extendBody: true,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: AppColors.primary600.withAlpha(4),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    label: dict['nav']['shop'] as String,
                    isSelected: currentIndex == 0,
                    accentColor: AppColors.primary600,
                    onTap: () {
                      debugPrint('Tapped Store icon from bottom nav! currentPath: $path');
                      HapticFeedback.selectionClick();
                      context.go('/store');
                    },
                  ),
                  _NavItem(
                    icon: Icons.gavel_outlined,
                    activeIcon: Icons.gavel_rounded,
                    label: dict['nav']['auctions'] as String,
                    isSelected: currentIndex == 1,
                    accentColor: AppColors.auctionOrange,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.go('/auctions');
                    },
                  ),
                  // ── Center Sell FAB ──────────────
                  _SellFab(
                    label: dict['nav']['sell'] as String,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (auth.isLoggedIn) {
                        context.push('/sell');
                      } else {
                        context.push('/login?redirect=/sell');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: dict['nav']['messages'] as String,
                    isSelected: currentIndex == 3,
                    accentColor: AppColors.primary600,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (auth.isLoggedIn) {
                        context.go('/messages');
                      } else {
                        context.go('/login?redirect=/messages');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: dict['nav']['profile'] as String,
                    isSelected: currentIndex == 4,
                    accentColor: AppColors.primary600,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (auth.isLoggedIn) {
                        context.go('/profile');
                      } else {
                        context.go('/login?redirect=/profile');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── NAV ITEM ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator line
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isSelected ? 24.w : 0,
              height: 3.h,
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withAlpha(80),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
            ),
            // Icon with background
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withAlpha(12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22.w,
                color: isSelected ? accentColor : const Color(0xFFB0B8C4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : const Color(0xFFB0B8C4),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── SELL FAB ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _SellFab extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SellFab({required this.label, required this.onTap});

  @override
  State<_SellFab> createState() => _SellFabState();
}

class _SellFabState extends State<_SellFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Invisible box to give the FAB area a footprint in the Row
          SizedBox(width: 54.w, height: 68.h),
          Positioned(
            top: -12.h,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary500, AppColors.primary700],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary600.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.primary400.withAlpha(30),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 28.w),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6.h,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
