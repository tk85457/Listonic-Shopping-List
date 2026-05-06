import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var userName = 'Guest User'.obs;
  var userEmail = ''.obs;
  var userPhoto = ''.obs;
  var loginMethod = 'guest'.obs;
  var isPremium = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredUserData();
  }

  Future<void> _loadStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('userName') ?? 'Guest User';
    userPhoto.value = prefs.getString('userPhoto') ?? '';
    isPremium.value = true;
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  Future<bool> isLoggedIn() async => true;

  Future<void> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      userName.value = name;
    } catch (e) {
      debugPrint('Error updating user name: $e');
    }
  }

  Future<void> updateUserPhoto(String photoPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPhoto', photoPath);
      userPhoto.value = photoPath;
      userPhoto.refresh();
    } catch (e) {
      debugPrint('Error updating user photo: $e');
    }
  }

  Future<void> signOut() async {
    userName.value = 'Guest User';
    userPhoto.value = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userPhoto');
    Get.offAllNamed('/home');
  }
}

