import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Small delay for smooth transition

    if (mounted) {
      final authController = Get.find<AuthController>();

      final isFirstTime = await authController.isFirstTime();

      if (isFirstTime) {
        Get.offAllNamed('/signin');
      } else {
        final isLoggedIn = await authController.isLoggedIn();
        final prefs = await SharedPreferences.getInstance();
        final isGuest = prefs.getBool('isGuest') ?? false;

        if (isLoggedIn || isGuest) {
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/signin');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
