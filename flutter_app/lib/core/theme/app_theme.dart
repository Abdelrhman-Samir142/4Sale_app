import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_radius.dart';

/// Semantic accent colors not covered by Material's [ColorScheme].
/// Access via `Theme.of(context).extension<AppColorsExtension>()!`.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color auction;
  final Color onAuction;
  final Color auctionContainer;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color subtleText;
  final Color mutedText;

  const AppColorsExtension({
    required this.auction,
    required this.onAuction,
    required this.auctionContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.subtleText,
    required this.mutedText,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? auction,
    Color? onAuction,
    Color? auctionContainer,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? subtleText,
    Color? mutedText,
  }) {
    return AppColorsExtension(
      auction: auction ?? this.auction,
      onAuction: onAuction ?? this.onAuction,
      auctionContainer: auctionContainer ?? this.auctionContainer,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      subtleText: subtleText ?? this.subtleText,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      auction: Color.lerp(auction, other.auction, t)!,
      onAuction: Color.lerp(onAuction, other.onAuction, t)!,
      auctionContainer: Color.lerp(auctionContainer, other.auctionContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }
}

// ── Light‑mode accent extension ───────────────────────────────────
const _lightExtension = AppColorsExtension(
  auction: AppColors.auctionOrange,
  onAuction: Colors.white,
  auctionContainer: Color(0xFFFFF7ED),
  success: AppColors.successGreen,
  onSuccess: Colors.white,
  successContainer: Color(0xFFF0FDF4),
  warning: AppColors.warningAmber,
  onWarning: Colors.white,
  warningContainer: Color(0xFFFFFBEB),
  info: AppColors.latestBlue,
  onInfo: Colors.white,
  infoContainer: Color(0xFFEFF6FF),
  accent: AppColors.recommendedPurple,
  onAccent: Colors.white,
  accentContainer: Color(0xFFFAF5FF),
  subtleText: AppColors.slate500,
  mutedText: AppColors.slate400,
);

// ── Dark‑mode accent extension ────────────────────────────────────
const _darkExtension = AppColorsExtension(
  auction: Color(0xFFFB923C),
  onAuction: Colors.white,
  auctionContainer: Color(0xFF431407),
  success: Color(0xFF4ADE80),
  onSuccess: Colors.white,
  successContainer: Color(0xFF052E16),
  warning: Color(0xFFFBBF24),
  onWarning: Colors.white,
  warningContainer: Color(0xFF422006),
  info: Color(0xFF60A5FA),
  onInfo: Colors.white,
  infoContainer: Color(0xFF172554),
  accent: Color(0xFFA855F7),
  onAccent: Colors.white,
  accentContainer: Color(0xFF3B0764),
  subtleText: AppColors.slate400,
  mutedText: AppColors.slate500,
);

/// Light and dark [ThemeData] matching the web app's design system.
class AppTheme {
  AppTheme._();

  // ── Shared text‑theme builder ─────────────────────────────────
  static TextTheme _textTheme(Color bodyColor) {
    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: bodyColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: bodyColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
    );
  }

  // ── LIGHT THEME ───────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        primarySwatch: AppColors.primarySwatch,
        primaryColor: AppColors.primary600,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary600,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primary100,
          onPrimaryContainer: AppColors.primary700,
          secondary: AppColors.primary400,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.primary50,
          onSecondaryContainer: AppColors.primary800,
          tertiary: AppColors.auctionOrange,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFFFF7ED),
          onTertiaryContainer: Color(0xFF7C2D12),
          surface: Colors.white,
          onSurface: AppColors.slate900,
          onSurfaceVariant: AppColors.slate500,
          error: AppColors.errorRed,
          onError: Colors.white,
          errorContainer: Color(0xFFFEF2F2),
          onErrorContainer: Color(0xFF991B1B),
          outline: AppColors.slate200,
          outlineVariant: AppColors.slate100,
          surfaceContainerHighest: AppColors.slate100,
          surfaceContainerHigh: AppColors.slate50,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.slate200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: const BorderSide(color: AppColors.slate200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          hintStyle: GoogleFonts.cairo(color: AppColors.slate400, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.slate700,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.slate300, width: 2),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary600,
            textStyle:
                GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary600,
          unselectedItemColor: AppColors.slate400,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.slate900,
          contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.slate200),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.slate100,
          selectedColor: AppColors.primary100,
          labelStyle: GoogleFonts.cairo(fontSize: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide.none,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary600;
            }
            return AppColors.slate300;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary200;
            }
            return AppColors.slate200;
          }),
        ),
        textTheme: _textTheme(AppColors.slate900),
        extensions: const [_lightExtension],
      );

  // ── DARK THEME ────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: AppColors.primarySwatch,
        primaryColor: AppColors.primary600,
        scaffoldBackgroundColor: AppColors.slate950,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary600,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primary900,
          onPrimaryContainer: AppColors.primary200,
          secondary: AppColors.primary400,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.primary800,
          onSecondaryContainer: AppColors.primary100,
          tertiary: Color(0xFFFB923C),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFF431407),
          onTertiaryContainer: Color(0xFFFED7AA),
          surface: AppColors.slate800,
          onSurface: AppColors.slate50,
          onSurfaceVariant: AppColors.slate400,
          error: Color(0xFFF87171),
          onError: Colors.white,
          errorContainer: Color(0xFF450A0A),
          onErrorContainer: Color(0xFFFECACA),
          outline: AppColors.slate700,
          outlineVariant: AppColors.slate800,
          surfaceContainerHighest: AppColors.slate700,
          surfaceContainerHigh: AppColors.slate800,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.slate950,
          foregroundColor: AppColors.slate50,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.slate50,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.slate800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.slate700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.slate800,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          hintStyle: GoogleFonts.cairo(color: AppColors.slate500, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.slate300,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.slate700, width: 2),
            textStyle:
                GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary400,
            textStyle:
                GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.slate900,
          selectedItemColor: AppColors.primary400,
          unselectedItemColor: AppColors.slate500,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.slate700,
          contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: AppColors.slate800,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.slate800,
        ),
        dividerTheme: const DividerThemeData(color: AppColors.slate700),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.slate800,
          selectedColor: AppColors.primary900,
          labelStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.slate200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide.none,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary400;
            }
            return AppColors.slate500;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary800;
            }
            return AppColors.slate700;
          }),
        ),
        textTheme: _textTheme(AppColors.slate50),
        extensions: const [_darkExtension],
      );
}
