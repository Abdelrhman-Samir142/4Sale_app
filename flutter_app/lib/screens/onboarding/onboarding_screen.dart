import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/language_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['onboarding'] as Map<String, dynamic>;
    final isAr = lang.locale == 'ar';

    final pages = [
      _OnboardingPageData(
        icon: Icons.storefront_rounded,
        title: dict['page1Title'] as String,
        subtitle: dict['page1Desc'] as String,
      ),
      _OnboardingPageData(
        icon: Icons.gavel_rounded,
        title: dict['page2Title'] as String,
        subtitle: dict['page2Desc'] as String,
      ),
      _OnboardingPageData(
        icon: Icons.verified_user_rounded,
        title: dict['page3Title'] as String,
        subtitle: dict['page3Desc'] as String,
      ),
    ];

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: isAr ? Alignment.topLeft : Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[500],
                      textStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(dict['skip'] as String),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final data = pages[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(40.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              data.icon,
                              size: 100.w,
                              color: AppColors.primary600,
                            ),
                          ).animate(key: ValueKey('icon-$index')).scaleXY(duration: 600.ms, begin: 0.8, curve: Curves.easeOutBack).fadeIn(),
                          SizedBox(height: 60.h),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey[900],
                              height: 1.3,
                            ),
                          ).animate(key: ValueKey('title-$index')).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                          SizedBox(height: 16.h),
                          Text(
                            data.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[500],
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate(key: ValueKey('sub-$index'), delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section
              Padding(
                padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 40.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicator
                    Row(
                      children: List.generate(pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: isActive ? 24.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary600 : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        );
                      }),
                    ),
                    
                    // FAB Next Button
                    FloatingActionButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      backgroundColor: AppColors.primary600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ).animate(key: ValueKey('fab-$_currentPage')).scale(duration: 300.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
