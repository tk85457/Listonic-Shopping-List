import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static Future<void> checkAndShowPermissions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedPermissions = prefs.getBool('permissions_requested') ?? false;

    if (!kIsWeb && !hasRequestedPermissions) {
      // Direct permission request without custom dialog
      await Permission.microphone.request();
      
      await prefs.setBool('permissions_requested', true);
    }
  }
}

