import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/navigation_controller.dart';
import 'package:smartgrocerylist/core/services/share_service.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/presentation/screens/home_screen.dart';
import 'package:smartgrocerylist/presentation/screens/settings_screen.dart';
import 'package:smartgrocerylist/presentation/screens/profile_screen.dart';
import 'package:smartgrocerylist/presentation/screens/premium_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartgrocerylist/data/repositories/grocery_repository.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final NavigationController _navController = Get.put(NavigationController());
  final GroceryRepository _repository = GroceryRepository();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    _navController.setSelectedTab(index);
  }

  void _handlePremiumTap() {
    Get.to(() => const PremiumScreen());
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'refresh':
        // Trigger real data refresh from repository
        Get.find<NavigationController>().triggerDataRefresh();
        Get.snackbar(
          'Refresh',
          'Data refreshed from storage',
          backgroundColor: AppTheme.primaryGreen,
          colorText: Colors.white,
        );
        break;
      case 'sync_all':
        final auth = Get.find<AuthController>();

        // 1. Check Premium
        if (!auth.isPremium.value) {
          Get.snackbar('Premium Feature', 'First purchase premium then work this option',
            backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.BOTTOM);
          return;
        }

        // 2. Check Logged In
        auth.isLoggedIn().then((isLoggedIn) async {
          if (!isLoggedIn) {
            Get.snackbar('Login Required', 'Please sign in to sync your data to the cloud.',
              backgroundColor: Colors.blue.shade100, snackPosition: SnackPosition.BOTTOM);
            return;
          }

          // 3. Check Internet
          try {
            final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              Get.snackbar('Syncing', 'Syncing all lists to cloud...', showProgressIndicator: true);
              _repository.syncAllData();
            } else {
              throw Exception();
            }
          } catch (_) {
            Get.snackbar('Network Error', 'Please connect internet first.',
              backgroundColor: Colors.red.shade100, snackPosition: SnackPosition.BOTTOM);
          }
        });
        break;
      case 'help':
        Get.toNamed('/faq');
        break;
      case 'contact':
        _openContactSupport();
        break;
      case 'share':
        ShareService.shareApp();
        break;
      case 'rate':
        // TODO: Open Play Store
        Get.snackbar(
          'Rate App',
          'Play Store link coming soon!',
          backgroundColor: AppTheme.primaryGreen,
          colorText: Colors.white,
        );
        break;
      case 'privacy':
        Get.toNamed('/privacy-policy');
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _openContactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@smartgrocery.com',
      queryParameters: {
        'subject': 'Smart Grocery List Support Request',
        'body': 'Please describe your issue or question:\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not open email app',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About Smart Grocery List'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Your AI-powered shopping assistant'),
            SizedBox(height: 8),
            Text('© 2024 Smart Grocery Team'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = _navController.selectedTabIndex.value;
      final colorScheme = Theme.of(context).colorScheme;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (selectedIndex == 0) {
            final shouldExit = await _showExitDialog(context);
            if (shouldExit) {
              SystemNavigator.pop();
            }
          } else {
            _navController.setSelectedTab(0);
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              _navController.currentTitle.value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            actions: [
              // Premium Badge
              GestureDetector(
                onTap: _handlePremiumTap,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _authController.isPremium.value
                              ? [colorScheme.secondary, colorScheme.tertiary]
                              : [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _authController.isPremium.value
                            ? Icons.workspace_premium
                            : Icons.bolt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _authController.isPremium.value ? 'Premium' : 'Upgrade',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Trash button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => Get.toNamed('/trash'),
                tooltip: 'Trash',
              ),
              // More menu
              PopupMenuButton<String>(
                onSelected: _handleMenuSelection,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                itemBuilder:
                    (context) => [
                      _buildPopupItem('refresh', Icons.refresh, 'Refresh'),
                      _buildPopupItem('sync_all', Icons.cloud_sync_rounded, 'Sync All Lists'),
                      const PopupMenuDivider(),
                      _buildPopupItem('help', Icons.help_outline, 'Help'),
                      _buildPopupItem('contact', Icons.email_outlined, 'Support'),
                      _buildPopupItem('share', Icons.share_rounded, 'Share App'),
                      _buildPopupItem('privacy', Icons.security_rounded, 'Privacy'),
                      _buildPopupItem('about', Icons.info_outline, 'About'),
                    ],
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                HomeScreen(),
                SettingsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              indicatorColor: colorScheme.primaryContainer,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              height: 70,
              destinations: [
                _buildNavItem(0, Icons.shopping_basket_outlined, Icons.shopping_basket, 'Lists'),
                _buildNavItem(1, Icons.settings_outlined, Icons.settings, 'Settings'),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      );
    });
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  NavigationDestination _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.grey.shade600),
      selectedIcon: Icon(activeIcon, color: Theme.of(context).colorScheme.primary),
      label: label,
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Exit App', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Stay', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
