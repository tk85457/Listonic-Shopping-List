import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocerylist/controllers/theme_controller.dart';
import 'package:grocerylist/core/themes/app_theme.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';
import 'package:grocerylist/presentation/screens/trash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _aiSuggestions = true;
  late ThemeController _tc;

  // Helper: convert ThemeMode → display string
  String _modeLabel(ThemeMode m) => m == ThemeMode.light
      ? 'Light'
      : m == ThemeMode.dark
      ? 'Dark'
      : 'System';

  // Helper: display string → ThemeMode
  ThemeMode _modeFromLabel(String s) => s == 'Light'
      ? ThemeMode.light
      : s == 'Dark'
      ? ThemeMode.dark
      : ThemeMode.system;

  // Helper: double factor → display string
  String _sizeLabel(double f) => f <= 0.8
      ? 'Small'
      : f <= 1.0
      ? 'Medium'
      : f <= 1.2
      ? 'Large'
      : 'Extra Large';

  // Helper: display string → double factor
  double _factorFromLabel(String s) => s == 'Small'
      ? 0.8
      : s == 'Large'
      ? 1.2
      : s == 'Extra Large'
      ? 1.4
      : 1.0;

  @override
  void initState() {
    super.initState();
    _tc = Get.find<ThemeController>();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifications = p.getBool('notifications') ?? true;
        _aiSuggestions = p.getBool('ai_suggestions') ?? true;
      });
    }
  }

  Future<void> _savePref(String key, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    if (v is bool) await p.setBool(key, v);
    if (v is String) await p.setString(key, v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── APPEARANCE ─────────────────────────────────────────
            _Section(label: 'Appearance'),
            _SettingsCard(
              children: [
                // Theme Mode — driven entirely by ThemeController observable
                Obx(
                  () => _DropTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme Mode',
                    selected: _modeLabel(_tc.currentThemeMode.value),
                    items: const ['Light', 'Dark', 'System'],
                    onChanged: (v) {
                      if (v == null) return;
                      HapticFeedback.selectionClick();
                      _tc.changeThemeMode(_modeFromLabel(v));
                    },
                  ),
                ),

                _Divider(),

                // Font Family
                Obx(
                  () => _DropTile(
                    icon: Icons.font_download_outlined,
                    title: 'Font Family',
                    selected: _tc.currentFontFamily.value,
                    items: AppTheme.availableFonts,
                    onChanged: (v) {
                      if (v == null) return;
                      HapticFeedback.selectionClick();
                      _tc.updateFontFamily(v);
                    },
                  ),
                ),

                _Divider(),

                // Text Size
                Obx(
                  () => _DropTile(
                    icon: Icons.format_size_rounded,
                    title: 'Text Size',
                    selected: _sizeLabel(_tc.currentFontSizeFactor.value),
                    items: const ['Small', 'Medium', 'Large', 'Extra Large'],
                    onChanged: (v) {
                      if (v == null) return;
                      HapticFeedback.selectionClick();
                      _tc.updateFontSize(_factorFromLabel(v));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Color Picker
            _ColorPicker(tc: _tc),

            const SizedBox(height: 24),

            // ── FEATURES ───────────────────────────────────────────
            _Section(label: 'Features'),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Reminders & smart alerts',
                  value: _notifications,
                  onChanged: (v) async {
                    if (v) {
                      final status = await Permission.notification.request();
                      if (status.isDenied || status.isPermanentlyDenied) {
                        SnackbarService.showWarning(
                          'Permission Needed',
                          'Enable notifications in your device settings',
                        );
                        setState(() => _notifications = false);
                        _savePref('notifications', false);
                        return;
                      }
                    }
                    setState(() => _notifications = v);
                    _savePref('notifications', v);
                  },
                ),
                _Divider(),
                _SwitchTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Suggestions',
                  subtitle: 'Smart item recommendations',
                  value: _aiSuggestions,
                  onChanged: (v) {
                    setState(() => _aiSuggestions = v);
                    _savePref('ai_suggestions', v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── MORE ───────────────────────────────────────────────
            _Section(label: 'More'),
            _SettingsCard(
              children: [
                _NavTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Trash',
                  subtitle: 'Recover deleted items',
                  color: cs.secondary,
                  onTap: () => Get.to(() => const TrashScreen()),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQ',
                  subtitle: 'Tutorials and answers',
                  onTap: () => Get.toNamed('/faq'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => Get.toNamed('/privacy-policy'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ── FOOTER ─────────────────────────────────────────────
            Center(
              child: Text(
                'SmartCart - AI Shopping List',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 56,
    endIndent: 16,
    color: Theme.of(context).dividerColor,
  );
}

// ── Switch tile ───────────────────────────────────────────────────────────────
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: _IconBadge(icon: icon, color: cs.primary),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ── Dropdown tile ─────────────────────────────────────────────────────────────
class _DropTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String selected;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Guard: if selected not in items (e.g. after reactive update), fall back
    final safeSelected = items.contains(selected) ? selected : items.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          DropdownButton<String>(
            value: safeSelected,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(14),
            icon: Icon(Icons.expand_more_rounded, color: cs.primary, size: 18),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
            onChanged: onChanged,
            items: items
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Nav tile ──────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
      leading: _IconBadge(icon: icon, color: color ?? cs.primary),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}

// ── Icon badge ────────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ── Color picker ──────────────────────────────────────────────────────────────
class _ColorPicker extends StatelessWidget {
  final ThemeController tc;
  const _ColorPicker({required this.tc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: Icons.palette_outlined, color: cs.primary),
              const SizedBox(width: 14),
              Text(
                'Color Theme',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.themeColors.entries.map((e) {
                final isSelected = tc.currentThemeColor.value == e.key;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    tc.changeThemeColor(e.key);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: e.value,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: e.value.withValues(
                            alpha: isSelected ? 0.55 : 0.0,
                          ),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
