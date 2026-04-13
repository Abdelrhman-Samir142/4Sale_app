import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/animated_press_wrapper.dart';
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

    final pages = [
      _OnboardingPageData(
        icon: Icons.local_offer_outlined, // shopping tag
        title: dict['page1Title'] as String,
        subtitle: dict['page1Desc'] as String,
      ),
      _OnboardingPageData(
        icon: Icons.gavel_rounded, // auction hammer
        title: dict['page2Title'] as String,
        subtitle: dict['page2Desc'] as String,
      ),
      _OnboardingPageData(
        icon: Icons.storefront_rounded, // will be overridden with logo for page 3
        title: dict['page3Title'] as String,
        subtitle: dict['page3Desc'] as String,
        useLogo: true,
      ),
    ];

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    dict['skip'] as String,
                    style: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = pages[index];
                  return Column(
                    children: [
                      // Illustration area: top 55% of content
                      Expanded(
                        flex: 55,
                        child: Center(
                          child: Container(
                            width: 250.w, 
                            height: 250.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary50,
                              shape: BoxShape.circle,
                            ),
                            child: data.useLogo
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24.r),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 140.w,
                                      height: 140.w,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(
                                    data.icon,
                                    size: 150.w, 
                                    color: AppColors.primary600,
                                  ),
                          ).animate(key: ValueKey('icon-$index')).scaleXY(duration: 500.ms, begin: 0.5, curve: Curves.elasticOut).fadeIn(),
                        ),
                      ),
                      
                      // Text Area: bottom 45% of content
                      Expanded(
                        flex: 45,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 32.h),
                              Text(
                                data.title,
                                textAlign: TextAlign.center,
                                style: AppTypography.getTextTheme('en').headlineMedium?.copyWith(
                                  color: AppColors.slate900,
                                ),
                              ).animate(key: ValueKey('title-$index')).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                              SizedBox(height: 16.h),
                              Text(
                                data.subtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.getTextTheme('en').bodyLarge?.copyWith(
                                  color: AppColors.slate500,
                                  height: 1.5,
                                ),
                              ).animate(key: ValueKey('sub-$index'), delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Area (Dots + Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: isActive ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary600 : AppColors.slate200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: AnimatedPressWrapper(
                      child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == pages.length - 1
                            ? dict['getStarted'] as String
                            : dict['next'] as String,
                        style: AppTypography.getTextTheme(lang.locale).labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool useLogo;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.useLogo = false,
  });
}
