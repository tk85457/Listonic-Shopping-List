import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:smartgrocerylist/controllers/theme_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartgrocerylist/presentation/screens/splash_screen.dart';
import 'package:smartgrocerylist/presentation/screens/signin_screen.dart';
import 'package:smartgrocerylist/presentation/screens/otp_screen.dart';
import 'package:smartgrocerylist/presentation/screens/main_navigation_screen.dart';
import 'package:smartgrocerylist/presentation/screens/list_detail_screen.dart';
import 'package:smartgrocerylist/presentation/screens/add_item_screen.dart';
import 'package:smartgrocerylist/presentation/screens/faq_screen.dart';
import 'package:smartgrocerylist/presentation/screens/privacy_policy_screen.dart';
import 'package:smartgrocerylist/presentation/screens/trash_screen.dart';
import 'package:smartgrocerylist/presentation/screens/auth_check_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Controllers globally
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const SmartGroceryApp());
}

class SmartGroceryApp extends StatelessWidget {
  const SmartGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'Smart Grocery List',
      theme: themeController.getLightTheme(),
      darkTheme: themeController.getDarkTheme(),
      themeMode: themeController.currentThemeMode.value,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/auth-check', page: () => const AuthCheckScreen()),
        GetPage(name: '/signin', page: () => const SignInScreen()),
        GetPage(name: '/otp', page: () => const OtpScreen()),
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
    ));
  }
}

// state is not lost during the reload. To reset the state, use hot
