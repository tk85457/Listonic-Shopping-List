import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';

class ThemeController extends GetxController {
  var currentThemeColor = 'Emerald'.obs;
  var currentThemeMode = ThemeMode.system.obs;
  var currentFontFamily = 'Inter'.obs;
  var currentFontSizeFactor = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    currentThemeColor.value = prefs.getString('theme_color') ?? 'Emerald';
    currentFontFamily.value = prefs.getString('font_family') ?? 'Inter';
    currentFontSizeFactor.value = prefs.getDouble('font_size_factor') ?? 1.0;

    final themeModeStr = prefs.getString('theme_mode') ?? 'System';
    currentThemeMode.value = _getThemeModeFromString(themeModeStr);
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> changeThemeColor(String colorName) async {
    currentThemeColor.value = colorName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_color', colorName);
    Get.forceAppUpdate();
  }

  Future<void> updateFontFamily(String font) async {
    currentFontFamily.value = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_family', font);
    Get.forceAppUpdate();
  }

  Future<void> updateFontSize(double factor) async {
    currentFontSizeFactor.value = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size_factor', factor);
    Get.forceAppUpdate();
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    currentThemeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    String modeStr = mode == ThemeMode.light ? 'Light' : (mode == ThemeMode.dark ? 'Dark' : 'System');
    await prefs.setString('theme_mode', modeStr);
    Get.changeThemeMode(mode);
  }

  ThemeData getLightTheme() {
    return AppTheme.getTheme(
      colorName: currentThemeColor.value,
      isDark: false,
      fontFamily: currentFontFamily.value,
      fontSizeFactor: currentFontSizeFactor.value,
    );
  }

  ThemeData getDarkTheme() {
    return AppTheme.getTheme(
      colorName: currentThemeColor.value,
      isDark: true,
      fontFamily: currentFontFamily.value,
      fontSizeFactor: currentFontSizeFactor.value,
    );
  }
}

