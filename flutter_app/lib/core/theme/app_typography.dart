import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(String languageCode) {
    // Select base text theme logic based on language (Arabic vs English)
    const textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600), // buttons
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500), // captions
    );

    if (languageCode == 'ar') {
      return GoogleFonts.cairoTextTheme(textTheme);
    } else {
      return GoogleFonts.poppinsTextTheme(textTheme);
    }
  }
}
