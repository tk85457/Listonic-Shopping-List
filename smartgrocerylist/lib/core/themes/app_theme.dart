import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Color Options (7 schemes as requested)
  static const Map<String, Color> themeColors = {
    'Emerald': Color(0xFF2E7D32),
    'Royal Blue': Color(0xFF1565C0),
    'Deep Purple': Color(0xFF6A1B9A),
    'Sunset Orange': Color(0xFFEF6C00),
    'Midnight': Color(0xFF263238),
    'Rose': Color(0xFFC2185B),
    'Slate': Color(0xFF455A64),
  };

  static Color getThemeColor(String colorName) {
    return themeColors[colorName] ?? const Color(0xFF2E7D32);
  }

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Produce': Color(0xFF4CAF50),
    'Dairy & Eggs': Color(0xFF2196F3),
    'Meat & Seafood': Color(0xFFE91E63),
    'Bakery': Color(0xFFFF9800),
    'Pantry Staples': Color(0xFF795548),
    'Frozen Foods': Color(0xFF00BCD4),
    'Beverages': Color(0xFF9C27B0),
    'Snacks': Color(0xFFFFEB3B),
    'Personal Care': Color(0xFF607D8B),
    'Household Items': Color(0xFF3F51B5),
    'Other': Color(0xFF9E9E9E),
  };

  static const Color primaryGreen = Color(0xFF2E7D32);

  static const List<String> availableFonts = [
    'Inter',
    'Montserrat',
    'Roboto',
    'Poppins',
    'Playfair Display',
    'Outfit',
  ];

  static ThemeData getTheme({
    required String colorName,
    required bool isDark,
    required String fontFamily,
    required double fontSizeFactor,
  }) {
    final primaryColor = getThemeColor(colorName);
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final backgroundColor = isDark ? darkBackground : lightBackground;
    final surfaceColor = isDark ? darkSurface : lightSurface;

    final baseTextTheme = _getTextTheme(fontFamily, isDark, fontSizeFactor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: brightness,
        surface: surfaceColor,
        onSurface: isDark ? Colors.white : const Color(0xFF1E293B),
        surfaceContainerHighest: isDark ? Colors.white12 : Colors.grey.shade100,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: baseTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceColor : Colors.grey.shade100,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static TextTheme _getTextTheme(String fontFamily, bool isDark, double factor) {
    final color = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    TextStyle baseStyle(double size, FontWeight weight, [Color? c]) {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: size * factor,
        fontWeight: weight,
        color: c ?? color,
      );
    }

    return TextTheme(
      displayLarge: baseStyle(32, FontWeight.bold),
      displayMedium: baseStyle(28, FontWeight.bold),
      displaySmall: baseStyle(24, FontWeight.bold),
      headlineLarge: baseStyle(20, FontWeight.bold),
      headlineMedium: baseStyle(18, FontWeight.w600),
      titleLarge: baseStyle(18, FontWeight.w600),
      titleMedium: baseStyle(16, FontWeight.w600),
      bodyLarge: baseStyle(16, FontWeight.normal),
      bodyMedium: baseStyle(14, FontWeight.normal, secondaryColor),
      labelLarge: baseStyle(16, FontWeight.w600),
    );
  }

  // Backward compatibility
  static ThemeData getLightTheme([String colorName = 'Emerald']) =>
      getTheme(colorName: colorName, isDark: false, fontFamily: 'Inter', fontSizeFactor: 1.0);

  static ThemeData getDarkTheme([String colorName = 'Emerald']) =>
      getTheme(colorName: colorName, isDark: true, fontFamily: 'Inter', fontSizeFactor: 1.0);
}

