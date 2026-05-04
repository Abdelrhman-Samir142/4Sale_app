import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/language_provider.dart';

class AIFeaturesBanner extends StatefulWidget {
  final LanguageState lang;
  final Map<String, dynamic> homeDict;

  const AIFeaturesBanner({super.key, required this.lang, required this.homeDict});

  @override
  State<AIFeaturesBanner> createState() => _AIFeaturesBannerState();
}

class _AIFeaturesBannerState extends State<AIFeaturesBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang.locale == 'ar';
    final features = widget.lang.dict['features'] as Map<String, dynamic>;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: const Color(0xFF312E81).withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10, top: -10,
              child: AnimatedBuilder(
                animation: _wave,
                builder: (_, child) => Transform.rotate(angle: _wave.value * 2 * math.pi * 0.1, child: child),
                child: Icon(Icons.auto_awesome, size: 90.w, color: Colors.white.withAlpha(15)),
              ),
            ),
            Positioned(left: -15, bottom: -15,
              child: Icon(Icons.psychology_rounded, size: 70.w, color: Colors.white.withAlpha(10))),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(10.r)),
                        child: Icon(Icons.auto_awesome, size: 20.w, color: const Color(0xFFA78BFA)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(child: Text(features['title'] as String,
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: Colors.white))),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(features['subtitle'] as String,
                      style: TextStyle(fontSize: 12.sp, color: Colors.white.withAlpha(160), fontWeight: FontWeight.w500)),
                  SizedBox(height: 16.h),
                  Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                    _Chip(icon: Icons.gavel_rounded, label: (features['aiPricing'] as Map<String, dynamic>)['title'] as String, color: const Color(0xFFFBBF24)),
                    _Chip(icon: Icons.search_rounded, label: (features['smartSearch'] as Map<String, dynamic>)['title'] as String, color: const Color(0xFF60A5FA)),
                    _Chip(icon: Icons.shield_rounded, label: (features['secure'] as Map<String, dynamic>)['title'] as String, color: const Color(0xFF34D399)),
                  ]),
                  SizedBox(height: 16.h),
                  Row(children: [
                    Expanded(child: GestureDetector(
                      onTap: () => context.push('/agent'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(40), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.smart_toy_rounded, size: 16.w, color: Colors.white),
                          SizedBox(width: 6.w),
                          Text(widget.homeDict['tryAgent'] as String? ?? (isAr ? 'جرّب الوكيل' : 'Try Agent'),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    )),
                    SizedBox(width: 10.w),
                    Expanded(child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white.withAlpha(30)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.search_rounded, size: 16.w, color: Colors.white),
                          SizedBox(width: 6.w),
                          Text(widget.homeDict['smartSearch'] as String? ?? (isAr ? 'بحث ذكي' : 'Smart Search'),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    )),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14.w, color: color),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
