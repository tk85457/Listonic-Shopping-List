import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ────────────────────────────────────────────
  static const Color brandGreen = Color(0xFF00C853);
  static const Color brandGreenDark = Color(0xFF009624);
  static const Color brandGreenLight = Color(0xFF69F0AE);

  // Theme Color Palette (7 schemes)
  static const Map<String, Color> themeColors = {
    'Emerald': Color(0xFF00C853),
    'Royal Blue': Color(0xFF2979FF),
    'Deep Purple': Color(0xFF7C4DFF),
    'Sunset Orange': Color(0xFFFF6D00),
    'Midnight': Color(0xFF546E7A),
    'Rose': Color(0xFFE91E8C),
    'Slate': Color(0xFF455A64),
  };

  static Color getThemeColor(String name) =>
      themeColors[name] ?? const Color(0xFF7C4DFF);

  // ─── Light Palette ────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF7F8FC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0D1117);
  static const Color lightTextMuted = Color(0xFF6B7280);

  // ─── Dark Palette ─────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF141929);
  static const Color darkCard = Color(0xFF1C2338);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // ─── Category Colors ──────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Produce': Color(0xFF4CAF50),
    'Dairy & Eggs': Color(0xFF2196F3),
    'Meat & Seafood': Color(0xFFE91E63),
    'Bakery': Color(0xFFFF9800),
    'Pantry Staples': Color(0xFF795548),
    'Frozen Foods': Color(0xFF00BCD4),
    'Beverages': Color(0xFF9C27B0),
    'Snacks': Color(0xFFF4C430),
    'Personal Care': Color(0xFF607D8B),
    'Household Items': Color(0xFF3F51B5),
    'Other': Color(0xFF9E9E9E),
  };

  // ─── Font Families ────────────────────────────────────────────
  static const List<String> availableFonts = [
    'Outfit', 'Inter', 'Poppins', 'Montserrat', 'Roboto', 'Playfair Display',
  ];

  // ─── Primary convenience ──────────────────────────────────────
  static const Color primaryGreen = brandGreen;

  // ─── Theme Builder ────────────────────────────────────────────
  static ThemeData getTheme({
    required String colorName,
    required bool isDark,
    required String fontFamily,
    required double fontSizeFactor,
  }) {
    final primary = getThemeColor(colorName);
    final bg = isDark ? darkBg : lightBg;
    final surface = isDark ? darkSurface : lightSurface;
    final cardColor = isDark ? darkCard : lightSurface;
    final textColor = isDark ? darkText : lightText;
    final mutedColor = isDark ? darkTextMuted : lightTextMuted;
    final baseText = _buildTextTheme(fontFamily, textColor, mutedColor, fontSizeFactor);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: surface,
        onSurface: textColor,
        surfaceContainerHighest: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
      ),
      scaffoldBackgroundColor: bg,
      cardColor: cardColor,
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07),

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.getFont(
          fontFamily,
          fontSize: 22 * fontSizeFactor,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: mutedColor, size: 22),
      ),

      // ── Cards ───────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ── Text ────────────────────────────────────────────────
      textTheme: baseText,

      // ── Inputs ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(color: mutedColor, fontSize: 14 * fontSizeFactor),
        labelStyle: TextStyle(color: mutedColor, fontSize: 14 * fontSizeFactor),
      ),

      // ── Buttons ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.getFont(
            fontFamily,
            fontSize: 15 * fontSizeFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.getFont(
            fontFamily,
            fontSize: 14 * fontSizeFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Bottom NavBar ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : lightSurface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.getFont(
            fontFamily,
            fontSize: 12 * fontSizeFactor,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: mutedColor, size: 22);
        }),
      ),

      // ── Chips ────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        selectedColor: primary.withValues(alpha: 0.18),
        labelStyle: GoogleFonts.getFont(
          fontFamily,
          fontSize: 13 * fontSizeFactor,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : mutedColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),

      // ── Snackbars ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark ? const Color(0xFF1E2A3A) : const Color(0xFF1C1C1E),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    String font,
    Color text,
    Color muted,
    double factor,
  ) {
    t(double sz, FontWeight w, [Color? c]) =>
        GoogleFonts.getFont(font, fontSize: sz * factor, fontWeight: w, color: c ?? text);
    return TextTheme(
      displayLarge: t(34, FontWeight.w800),
      displayMedium: t(28, FontWeight.w700),
      displaySmall: t(24, FontWeight.w700),
      headlineLarge: t(22, FontWeight.w700),
      headlineMedium: t(20, FontWeight.w600),
      titleLarge: t(18, FontWeight.w600),
      titleMedium: t(16, FontWeight.w600),
      titleSmall: t(14, FontWeight.w500),
      bodyLarge: t(16, FontWeight.w400),
      bodyMedium: t(14, FontWeight.w400, muted),
      bodySmall: t(12, FontWeight.w400, muted),
      labelLarge: t(15, FontWeight.w600),
      labelMedium: t(13, FontWeight.w500),
      labelSmall: t(11, FontWeight.w500, muted),
    );
  }

  // ─── Backward-compat ──────────────────────────────────────────
  static ThemeData getLightTheme([String colorName = 'Deep Purple']) =>
      getTheme(colorName: colorName, isDark: false, fontFamily: 'Outfit', fontSizeFactor: 1.0);

  static ThemeData getDarkTheme([String colorName = 'Deep Purple']) =>
      getTheme(colorName: colorName, isDark: true, fontFamily: 'Outfit', fontSizeFactor: 1.0);
}

