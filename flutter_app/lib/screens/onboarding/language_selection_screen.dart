import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, WidgetRef ref, String langCode) async {
    await ref.read(languageProvider.notifier).setLanguage(langCode);
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_done') ?? false;

    if (context.mounted) {
      if (!hasSeenOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary700,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120.w,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.storefront_rounded, size: 80.w, color: Colors.white);
                    },
                  ),
                ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.8),
                SizedBox(height: 48.h),
                
                Text(
                  'Choose Language\nاختر اللغة',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                
                SizedBox(height: 48.h),
                
                // Arabic Option
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => _selectLanguage(context, ref, 'ar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Text('العربية', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                SizedBox(height: 16.h),
                
                // English Option
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: () => _selectLanguage(context, ref, 'en'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('English', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
