import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocerylist/controllers/navigation_controller.dart';
import 'package:grocerylist/core/services/share_service.dart';
import 'package:grocerylist/presentation/screens/home_screen.dart';
import 'package:grocerylist/presentation/screens/settings_screen.dart';
import 'package:grocerylist/presentation/widgets/ad_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final NavigationController _nav = Get.put(NavigationController());

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.shopping_basket_outlined, activeIcon: Icons.shopping_basket_rounded, label: 'Lists'),
    _TabItem(icon: Icons.tune_outlined, activeIcon: Icons.tune_rounded, label: 'Settings'),
  ];

  static const _titles = ['My Lists', 'Settings'];

  Future<void> _handleMenu(String value) async {
    switch (value) {
      case 'refresh':
        _nav.triggerDataRefresh();
        break;
      case 'trash':
        Get.toNamed('/trash');
        break;
      case 'help':
        Get.toNamed('/faq');
        break;
      case 'contact':
        final uri = Uri(
          scheme: 'mailto',
          path: 'tk8545725@gmail.com',
          queryParameters: {
            'subject': 'SmartCart - AI Shopping List Support',
            'body': 'Describe your issue:\n\n',
          },
        );
        if (await canLaunchUrl(uri)) launchUrl(uri);
        break;
      case 'share':
        ShareService.shareApp();
        break;
      case 'privacy':
        Get.toNamed('/privacy-policy');
        break;
      case 'about':
        _showAbout();
        break;
    }
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'SmartCart - AI Shopping List',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.2.0', style: GoogleFonts.outfit()),
            const SizedBox(height: 4),
            Text(
              'Your AI-powered shopping companion.',
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text('© 2024 SmartCart - AI Shopping List Team', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final idx = _nav.selectedTabIndex.value;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (idx == 0) {
            final exit = await _showExitDialog();
            if (exit) SystemNavigator.pop();
          } else {
            _nav.setSelectedTab(0);
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              _titles[idx],
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              _AppBarBtn(
                icon: Icons.delete_outline_rounded,
                onTap: () => Get.toNamed('/trash'),
                tooltip: 'Trash',
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenu,
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? const Color(0xFF1C2338) : Colors.white,
                elevation: 8,
                icon: Icon(Icons.more_vert_rounded, color: cs.onSurface.withValues(alpha: 0.6)),
                itemBuilder: (_) => [
                  _menuItem('refresh', Icons.refresh_rounded, 'Refresh', cs),
                  _menuItem('trash', Icons.delete_outline_rounded, 'Trash', cs),
                  const PopupMenuDivider(height: 1),
                  _menuItem('help', Icons.help_outline_rounded, 'Help & FAQ', cs),
                  _menuItem('contact', Icons.email_outlined, 'Contact Support', cs),
                  _menuItem('share', Icons.share_rounded, 'Share App', cs),
                  const PopupMenuDivider(height: 1),
                  _menuItem('privacy', Icons.shield_outlined, 'Privacy Policy', cs),
                  _menuItem('about', Icons.info_outline_rounded, 'About', cs),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: idx,
                  children: const [
                    HomeScreen(),
                    SettingsScreen(),
                  ],
                ),
              ),
              const AdBanner(),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            items: _tabs,
            selected: idx,
            primary: cs.primary,
            onTap: _nav.setSelectedTab,
          ),
        ),
      );
    });
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    ColorScheme cs,
  ) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14)),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Exit?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to quit?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Stay', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Exit', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ──────────────────────────────────────────────────────────────────────────────

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _AppBarBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<_TabItem> items;
  final int selected;
  final Color primary;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.items,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141929) : Colors.white;
    final muted = isDark ? const Color(0xFF64748B) : const Color(0xFF000000);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? primary : muted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? primary : muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

