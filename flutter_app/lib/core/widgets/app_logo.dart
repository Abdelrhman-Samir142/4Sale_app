import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLogo extends StatelessWidget {
  final double scale;
  final bool withAnimation;

  const AppLogo({
    super.key,
    this.scale = 1.0,
    this.withAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0F766E);
    const Color textDark = Color(0xFF1E212B);
    const Color textGrey = Color(0xFF9FA6B2);

    Widget logo = Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50.w * scale,
            height: 50.w * scale,
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(16.r * scale),
              boxShadow: [
                BoxShadow(
                  color: primaryTeal.withAlpha(50),
                  blurRadius: 16 * scale,
                  offset: Offset(0, 8 * scale),
                )
              ],
            ),
            child: Center(
              child: Text(
                '4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp * scale,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sale',
                style: TextStyle(
                  color: textDark,
                  fontSize: 28.sp * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              Text(
                'MARKETPLACE',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10.sp * scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (withAnimation) {
      return logo.animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
    }
    return logo;
  }
}
