import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(String languageCode) {
    // Select base text theme logic based on language (Arabic vs English)
    final textTheme = TextTheme(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), // buttons
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), // captions
    );

    if (languageCode == 'ar') {
      return GoogleFonts.cairoTextTheme(textTheme);
    } else {
      return GoogleFonts.poppinsTextTheme(textTheme);
    }
  }
}
