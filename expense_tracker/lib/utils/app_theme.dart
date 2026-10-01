import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core brand colours (#1877F2 main color requested by user) ─────
  static const Color primaryBlue    = Color(0xFF1877F2); // #1877F2 main brand color
  static const Color primaryBlueDark= Color(0xFF0C5EC7); // darker shade for gradients
  static const Color primaryBlueLight= Color(0xFFEBF3FF); // light mode accent tint

  // Compatibility aliases
  static const Color primaryPurple  = Color(0xFF1877F2);
  static const Color deepPurple     = Color(0xFF0C5EC7);
  static const Color accentViolet   = Color(0xFF1877F2);
  static const Color accentGreen    = Color(0xFF1877F2);
  static const Color primaryGreen   = Color(0xFF0C5EC7);

  // ── Dark theme tokens (Black + #1877F2 as requested) ──────────────
  static const Color darkBg         = Color(0xFF000000); // pure black
  static const Color darkCard       = Color(0xFF121212); // dark elevated surface
  static const Color darkElevated   = Color(0xFF1C1C1E);
  static const Color darkBorder     = Color(0xFF27272A);

  // ── Light theme tokens (White + #1877F2 as requested) ─────────────
  static const Color lightBg        = Color(0xFFFFFFFF); // pure white
  static const Color lightCard      = Color(0xFFFFFFFF);
  static const Color surfaceBg      = Color(0xFFF8FAFC);
  static const Color lightBorder    = Color(0xFFE2E8F0);

  // ── Semantic colours ──────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF64748B);
  static const Color textMuted      = Color(0xFF94A3B8);
  static const Color expenseRed     = Color(0xFFFF3B30);
  static const Color incomeGreen    = Color(0xFF34C759);
  static const Color limeGlow       = Color(0xFF1877F2);

  // ── Category icon colours ─────────────────────────────────────────
  static const Color catFood        = Color(0xFFFF9500);
  static const Color catTransport   = Color(0xFF1877F2);
  static const Color catShopping    = Color(0xFFAF52DE);
  static const Color catBills       = Color(0xFFFF2D55);
  static const Color catHealth      = Color(0xFFFF3B30);
  static const Color catEntertain   = Color(0xFF5856D6);
  static const Color catEducation   = Color(0xFF34C759);
  static const Color catTravel      = Color(0xFFFF643B);
  static const Color catIncome      = Color(0xFF34C759);
  static const Color catOther       = Color(0xFF8E8E93);

  // ── Gradient helpers ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1877F2), Color(0xFF0C5EC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1877F2), Color(0xFF0854B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark ThemeData (Black & #1877F2 + Poppins font) ───────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: expenseRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: expenseRed, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // ── Light ThemeData (White & #1877F2 + Poppins font) ──────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0F172A),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: expenseRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: expenseRed, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
