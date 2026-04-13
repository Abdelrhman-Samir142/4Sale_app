import 'package:flutter/material.dart';

/// Design tokens matching the web app's Tailwind emerald + slate palette.
class AppColors {
  AppColors._();

  static const Color secondary = Color(0xFF1E2235);
  static const Color backgroundWarm = Color(0xFFFFF3E0);
  static const Color orange = Color(0xFFF5A623);

  // ── Primary (Emerald) ─────────────────────────────────────────
  static const Color primary50 = Color(0xFFECFDF5);
  static const Color primary100 = Color(0xFFD1FAE5);
  static const Color primary200 = Color(0xFFA7F3D0);
  static const Color primary300 = Color(0xFF6EE7B7);
  static const Color primary400 = Color(0xFF34D399);
  static const Color primary500 = Color(0xFF10B981);
  static const Color primary600 = Color(0xFF059669); // Main
  static const Color primary700 = Color(0xFF047857);
  static const Color primary800 = Color(0xFF065F46);
  static const Color primary900 = Color(0xFF064E3B);

  static const MaterialColor primarySwatch = MaterialColor(0xFF059669, {
    50: primary50,
    100: primary100,
    200: primary200,
    300: primary300,
    400: primary400,
    500: primary500,
    600: primary600,
    700: primary700,
    800: primary800,
    900: primary900,
  });

  // ── Slate (Neutrals) ─────────────────────────────────────────
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // ── Accent colours (sections) ─────────────────────────────────
  static const Color auctionOrange = Color(0xFFF97316);
  static const Color recommendedPurple = Color(0xFF9333EA);
  static const Color latestBlue = Color(0xFF2563EB);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary600, primary400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auctionGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary600, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
