import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocerylist/core/themes/app_theme.dart';

class ThemeController extends GetxController {
  var currentThemeColor = 'Deep Purple'.obs;
  var currentThemeMode = ThemeMode.system.obs;
  var currentFontFamily = 'Outfit'.obs;
  var currentFontSizeFactor = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Batch-update so Obx rebuilds only once
    currentThemeColor.value = prefs.getString('theme_color') ?? 'Deep Purple';
    currentFontFamily.value = prefs.getString('font_family') ?? 'Outfit';
    currentFontSizeFactor.value = prefs.getDouble('font_size_factor') ?? 1.0;
    final themeModeStr = prefs.getString('theme_mode') ?? 'System';
    currentThemeMode.value = _modeFromString(themeModeStr);
  }

  ThemeMode _modeFromString(String mode) {
    switch (mode) {
      case 'Light': return ThemeMode.light;
      case 'Dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  // ── Public setters – each triggers Obx rebuild in main.dart ──────────────

  Future<void> changeThemeColor(String colorName) async {
    currentThemeColor.value = colorName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_color', colorName);
  }

  Future<void> updateFontFamily(String font) async {
    currentFontFamily.value = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_family', font);
  }

  Future<void> updateFontSize(double factor) async {
    currentFontSizeFactor.value = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size_factor', factor);
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    currentThemeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    final modeStr = mode == ThemeMode.light ? 'Light' : (mode == ThemeMode.dark ? 'Dark' : 'System');
    await prefs.setString('theme_mode', modeStr);
  }

  // ── Theme builders (called by main.dart Obx) ─────────────────────────────

  ThemeData getLightTheme() => AppTheme.getTheme(
    colorName: currentThemeColor.value,
    isDark: false,
    fontFamily: currentFontFamily.value,
    fontSizeFactor: currentFontSizeFactor.value,
  );

  ThemeData getDarkTheme() => AppTheme.getTheme(
    colorName: currentThemeColor.value,
    isDark: true,
    fontFamily: currentFontFamily.value,
    fontSizeFactor: currentFontSizeFactor.value,
  );
}

