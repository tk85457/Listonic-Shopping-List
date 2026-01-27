import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/theme_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/presentation/screens/premium_screen.dart';
import 'package:smartgrocerylist/presentation/screens/trash_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _aiSuggestions = true;
  bool _isGuest = false;
  bool _isPremium = false;
  String _selectedTheme = 'System';
  String _selectedColor = 'Emerald';
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool('isGuest') ?? false;
      _isPremium = prefs.getBool('isPremium') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _aiSuggestions = prefs.getBool('ai_suggestions') ?? true;
      _selectedTheme = prefs.getString('theme_mode') ?? 'System';
      _selectedColor = _themeController.currentThemeColor.value;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _onAISuggestionsChanged(bool value) {
    setState(() {
      _aiSuggestions = value;
    });
    _saveSetting('ai_suggestions', value);
  }

  void _onThemeChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedTheme = value;
    });
    _saveSetting('theme_mode', value);

    ThemeMode themeMode;
    switch (value) {
      case 'Light':
        themeMode = ThemeMode.light;
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    _themeController.changeThemeMode(themeMode);
  }

  Future<void> _onColorChanged(String colorName) async {
    setState(() {
      _selectedColor = colorName;
    });
    await _themeController.changeThemeColor(colorName);
  }

  String _getFontSizeString(double factor) {
    if (factor <= 0.8) return 'Small';
    if (factor <= 1.0) return 'Medium';
    if (factor <= 1.2) return 'Large';
    return 'Extra Large';
  }

  double _getFontSizeFactor(String size) {
    switch (size) {
      case 'Small': return 0.8;
      case 'Medium': return 1.0;
      case 'Large': return 1.2;
      case 'Extra Large': return 1.4;
      default: return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildDropdownTile(
              icon: Icons.dark_mode_outlined,
              title: 'Theme Mode',
              subtitle: 'Current mode: $_selectedTheme',
              selectedItem: _selectedTheme,
              items: const ['Light', 'Dark', 'System'],
              onChanged: _onThemeChanged,
            ),
            Obx(() => _buildDropdownTile(
              icon: Icons.font_download_outlined,
              title: 'Font Family',
              subtitle: 'Current: ${_themeController.currentFontFamily.value}',
              selectedItem: _themeController.currentFontFamily.value,
              items: AppTheme.availableFonts,
              showPremiumLock: !_isPremium,
              onChanged: (value) {
                if (!_isPremium) {
                  _showPremiumFeatureSnackbar('Custom Fonts');
                  return;
                }
                if (value != null) {
                  _themeController.updateFontFamily(value);
                }
              },
            )),
            Obx(() => _buildDropdownTile(
              icon: Icons.format_size_rounded,
              title: 'Text Size',
              subtitle: 'Adjust readability',
              selectedItem: _getFontSizeString(_themeController.currentFontSizeFactor.value),
              items: const ['Small', 'Medium', 'Large', 'Extra Large'],
              showPremiumLock: !_isPremium,
              onChanged: (value) {
                if (!_isPremium) {
                  _showPremiumFeatureSnackbar('Adjustable Font Size');
                  return;
                }
                if (value != null) {
                  _themeController.updateFontSize(_getFontSizeFactor(value));
                }
              },
            )),
            Obx(() => _buildColorThemeTile(
              icon: Icons.palette_outlined,
              title: 'Color Theme',
              subtitle: 'Personalize your workspace',
              selectedColor: _themeController.currentThemeColor.value,
              onChanged: _onColorChanged,
            )),
            const SizedBox(height: 24),

            _buildSectionHeader('Features'),
            _buildToggleTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Reminders for shopping & items',
              value: _notifications,
              onChanged: (value) async {
                if (value) {
                  final status = await Permission.notification.request();
                  if (status.isDenied || status.isPermanentlyDenied) {
                    Get.snackbar(
                      'Permission Denied',
                      'Please enable notifications in system settings.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange.shade100,
                    );
                    setState(() => _notifications = false);
                    await _saveSetting('notifications', false);
                    return;
                  }
                }
                setState(() => _notifications = value);
                await _saveSetting('notifications', value);
              },
            ),
            _buildToggleTile(
              icon: Icons.auto_awesome_outlined,
              title: 'AI Suggestions',
              subtitle: 'Smart recommendations',
              value: _aiSuggestions,
              onChanged: _onAISuggestionsChanged,
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Account'),
            if (!_isPremium)
              _buildPremiumPromo()
            else
              _buildNavigationTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Premium Plan',
                subtitle: 'Manage your subscription',
                onTap: _navigateToPremium,
              ),

            _buildNavigationTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Trash',
              subtitle: 'Recover deleted lists and items',
              onTap: () => Get.to(() => const TrashScreen()),
            ),
            _buildNavigationTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              subtitle: 'FAQs and tutorials',
              onTap: () => Get.toNamed('/faq'),
            ),
            _buildNavigationTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our terms and policy',
              onTap: () => Get.toNamed('/privacy-policy'),
            ),

            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Text(
                    'Smart Grocery List',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.2.5 • Premium Edition',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.to(() => const PremiumScreen());
    } else {
      Get.toNamed('/signin');
      Get.snackbar(
        'Login Required',
        'Please sign in to view premium plans.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
      );
    }
  }

  void _showPremiumFeatureSnackbar(String feature) {
    Get.snackbar(
      'Premium Feature',
      '$feature is only available for Premium members.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber.shade100,
      mainButton: TextButton(
        onPressed: () => _navigateToPremium(),
        child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPremiumPromo() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToPremium,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Full Potential',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Get AI insights and unlimited lists',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .shimmer(delay: const Duration(seconds: 2), duration: const Duration(milliseconds: 1500), color: Colors.white24);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTileContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildTileContainer(
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String selectedItem,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool showPremiumLock = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildTileContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      if (showPremiumLock)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.lock_rounded, size: 14, color: Colors.amber),
                        ),
                    ],
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            DropdownButton<String>(
              value: selectedItem,
              icon: Icon(Icons.expand_more_rounded, color: colorScheme.primary),
              underline: const SizedBox(),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildTileContainer(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.secondary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildColorThemeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String selectedColor,
    required ValueChanged<String> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildTileContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.themeColors.entries.map((entry) {
                final colorName = entry.key;
                final color = entry.value;
                final isSelected = selectedColor == colorName;

                return GestureDetector(
                  onTap: () {
                    if (!_isPremium) {
                      _showPremiumFeatureSnackbar('Color Themes');
                      return;
                    }
                    onChanged(colorName);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]
                          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 24) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
