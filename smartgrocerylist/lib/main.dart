import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/controllers/theme_controller.dart';
import 'package:grocerylist/presentation/screens/splash_screen.dart';
import 'package:grocerylist/presentation/screens/main_navigation_screen.dart';
import 'package:grocerylist/presentation/screens/list_detail_screen.dart';
import 'package:grocerylist/presentation/screens/add_item_screen.dart';
import 'package:grocerylist/presentation/screens/faq_screen.dart';
import 'package:grocerylist/presentation/screens/privacy_policy_screen.dart';
import 'package:grocerylist/presentation/screens/trash_screen.dart';

import 'package:grocerylist/core/network/ai_service.dart';
import 'package:grocerylist/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AI model to load user learned items
  await AIService.initializeMLModel();

  Get.put(ThemeController(), permanent: true);

  // Initialize ads in background — don't block app startup
  MobileAds.instance.initialize().then((_) {
    try {
      AdService().loadInterstitialAd();
    } catch (e) {
      debugPrint('📢 AdService initialization exception: $e');
    }
  }).catchError((e) {
    debugPrint('📢 MobileAds initialization exception: $e');
  });

  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    // Obx tracks ALL reactive fields: color, font, size, mode
    return Obx(() {
      // Read all reactive values so Obx re-triggers on any change
      final _ = tc.currentThemeColor.value;
      final _ = tc.currentFontFamily.value;
      final _ = tc.currentFontSizeFactor.value;
      final themeMode = tc.currentThemeMode.value;

      return GetMaterialApp(
        title: 'SmartCart - AI Shopping List',
        theme: tc.getLightTheme(),
        darkTheme: tc.getDarkTheme(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(name: '/home', page: () => const MainNavigationScreen()),
          GetPage(name: '/faq', page: () => const FAQScreen()),
          GetPage(
            name: '/privacy-policy',
            page: () => const PrivacyPolicyScreen(),
          ),
          GetPage(
            name: '/list/:listId',
            page: () {
              final listId = Get.parameters['listId'] ?? '';
              final args = Get.arguments;
              return ListDetailScreen(
                listId: listId,
                list: args is ShoppingList ? args : null,
              );
            },
          ),
          GetPage(
            name: '/add-item/:listId',
            page: () {
              final listId = Get.parameters['listId'] ?? '';
              final args = Get.arguments;
              return AddItemScreen(
                listId: listId,
                item: args is GroceryItem ? args : null,
              );
            },
          ),
          GetPage(name: '/trash', page: () => const TrashScreen()),
        ],
      );
    });
  }
}
