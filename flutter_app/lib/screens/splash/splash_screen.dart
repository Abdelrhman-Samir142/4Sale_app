import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

/// Splash screen — branded entry point with auth + onboarding checks.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Check if user has seen onboarding or selected language
    final prefs = await SharedPreferences.getInstance();
    final languageSelected = prefs.getBool('language_selected') ?? false;
    final hasSeenOnboarding = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (!languageSelected) {
      context.go('/language');
    } else if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (authState.isLoggedIn) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary700,
      body: Center(
        child: Hero(
          tag: 'app-logo',
          child: Image.asset(
            'assets/images/logo.png',
            width: 150.w,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.storefront_rounded,
                size: 80.w,
                color: Colors.white,
              );
            },
          ),
        ).animate()
         .fadeIn(duration: 500.ms, curve: Curves.easeOut)
         .scaleXY(begin: 0.5, end: 1.0, duration: 800.ms, curve: Curves.elasticOut),
      ),
    );
  }
}
