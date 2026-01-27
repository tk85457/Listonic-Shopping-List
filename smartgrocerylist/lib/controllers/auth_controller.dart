import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartgrocerylist/core/services/supabase_service.dart';
import 'package:smartgrocerylist/presentation/widgets/name_request_dialog.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var user = Rxn<User>();
  var userName = 'User Name'.obs;
  var userEmail = 'user@example.com'.obs;
  var userPhoto = ''.obs;
  var loginMethod = 'email'.obs;
  var isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      user.value = session?.user;

      if (session != null) {
        _loadStoredUserData(); // Sync local state with storage
        final prefs = await SharedPreferences.getInstance();
        final bool isGuest = prefs.getBool('isGuest') ?? false;

        // Prevent automatic navigation if we are in splash or auth-check
        // The splash screen handles navigation after its animation
        if (!isGuest &&
            Get.currentRoute != '/splash' &&
            Get.currentRoute != '/auth-check' &&
            Get.currentRoute != '/home') {
          await _saveUserData(session.user, 'email');
          Get.offAllNamed('/home');
        }
      } else {
        // User logged out - lock premium immediately
        isPremium.value = false;
        userName.value = 'User Name';
        userEmail.value = 'user@example.com';
      }
    });

    _loadStoredUserData();
  }

  Future<void> _loadStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    userName.value = prefs.getString('userName') ?? prefs.getString('user_name') ?? 'User Name';
    userEmail.value = prefs.getString('userEmail') ?? prefs.getString('user_email') ?? 'user@example.com';
    userPhoto.value = prefs.getString('userPhoto') ?? '';
    loginMethod.value = prefs.getString('loginMethod') ?? prefs.getString('login_method') ?? 'email';
    // Load premium status per user account
    isPremium.value = userId.isNotEmpty
        ? (prefs.getBool('isPremium_$userId') ?? false)
        : (prefs.getBool('isPremium') ?? false);
  }

  // Check if it's first time user
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  // Set first time as false
  Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  // Set premium status (per user account)
  Future<void> setPremium(bool value) async {
    print('💎 Setting premium to: $value');
    isPremium.value = value;
    isPremium.refresh(); // Force UI update
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isNotEmpty) {
      await prefs.setBool('isPremium_$userId', value);
    }
    await prefs.setBool('isPremium', value); // Fallback for compatibility
  }

  // Check login status
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // Email authentication (OTP)
  Future<void> signInWithEmail(String email) async {
    isLoading.value = true;
    try {
      if (!GetUtils.isEmail(email)) {
        isLoading.value = false;
        Get.snackbar(
          'Invalid Email',
          'Please enter a valid email address',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
        );
        return;
      }

      print('📧 Attempting to send OTP to: $email');

      // Zero Latency: Navigate immediately
      Get.toNamed('/otp', arguments: {
        'email': email,
        'type': 'email',
      });

      // Send OTP to email in background
      _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      ).then((_) {
        print('✅ OTP sent successfully to email');
        isLoading.value = false;
        Get.snackbar(
          'OTP Sent',
          'Please check your email for the verification code',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      }).catchError((e) {
        isLoading.value = false;
        Get.snackbar(
          'Auth Error',
          'Failed to send code. Please try again.',
          backgroundColor: Colors.red.shade100,
        );
      });

    } on AuthException catch (e) {
      isLoading.value = false;
      print('❌ Auth Error: ${e.message}');

      Get.snackbar(
        'Authentication Error',
        e.message.contains('network') || e.message.contains('connection')
          ? 'Please connect internet first.'
          : e.message,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      isLoading.value = false;
      print('❌ Unexpected Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Verify Email OTP
  Future<void> verifyEmailOTP(String email, String otp) async {
    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      print('🔐 Attempting to verify email OTP for: $email');

      final AuthResponse response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        print('✅ Email OTP verified successfully');
        await saveEmailToHistory(email); // Save email for autocomplete
        await _saveUserData(user, 'email');

        isLoading.value = false;

        // After success, navigate to home but check if name is needed
        Get.offAllNamed('/home');

        // Use a small delay to show dialog over home screen
        Future.delayed(const Duration(milliseconds: 500), () {
          _checkProfileComplete();
        });

        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        throw Exception('Verification failed - no session created');
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      print('❌ Verification Error: ${e.message}');

      String errorMessage;
      if (e.message.contains('expired')) {
        errorMessage = 'OTP has expired. Please request a new one.';
      } else if (e.message.contains('invalid')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
      } else {
        errorMessage = 'Verification failed: ${e.message}';
      }

      Get.snackbar(
        'Verification Failed',
        errorMessage.contains('network') || errorMessage.contains('connection')
          ? 'Please connect internet first.'
          : errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      isLoading.value = false;
      print('❌ Unexpected verification error: $e');
      Get.snackbar(
        'Verification Failed',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Verify Phone OTP (kept for backward compatibility)
  Future<void> verifyOTP(String phone, String otp) async {
    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      print('🔐 Attempting to verify OTP for: $phone');

      final AuthResponse response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phone,
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        print('✅ OTP verified successfully');
        await _saveUserData(user, 'phone');

        isLoading.value = false;
        Get.offAllNamed('/home');
        Get.snackbar(
          'Success',
          'Phone number verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        throw Exception('Verification failed - no session created');
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      print('❌ Verification Error: ${e.message}');

      String errorMessage;
      if (e.message.contains('expired')) {
        errorMessage = 'OTP has expired. Please request a new one.';
      } else if (e.message.contains('invalid')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
      } else {
        errorMessage = 'Verification failed: ${e.message}';
      }

      Get.snackbar(
        'Verification Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      isLoading.value = false;
      print('❌ Unexpected verification error: $e');
      Get.snackbar(
        'Verification Failed',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Google Sign-In (Smart: Native -> Fallback to Web)
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      print('🔐 Attempting Native Google Sign-In...');

      // 1. Try Native Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      // Sign out first to force account picker (show all accounts)
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the native dialog
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found. Web Client ID might be missing.';
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        print('✅ Google Sign-In successful (Native)');
        await _saveUserData(user, 'google');
      } else {
        throw 'Sign in failed - no session created';
      }

    } catch (e) {
      // 2. Catch Errors & Fallback
      print('⚠️ Native Auth Failed: $e');

      // Check for specific "Developer Error" (Code 10) or other platform exceptions
      bool shouldFallback = false;
      if (e is PlatformException && (e.message?.contains('10') ?? false)) {
        shouldFallback = true;
      } else if (e.toString().contains('10') && e.toString().contains('ApiException')) {
        shouldFallback = true;
      }

      if (shouldFallback) {
        print('🔄 Falling back to Browser OAuth due to configuration error...');
        Get.snackbar(
          'Switching Mode',
          'Native login config missing. Opening secure browser...',
          backgroundColor: Colors.orange.shade100,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
        await _signInWithWebOAuth();
      } else {
        // Real error (network etc)
        isLoading.value = false;
        Get.snackbar(
          'Sign In Error',
          'Failed to sign in: ${e.toString().split('\n').first}',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }
  }

  // Fallback Web OAuth Flow
  Future<void> _signInWithWebOAuth() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
          ? null
          : 'com.smartgrocery.smartgrocerylis://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Loading state will be handled by auth state change listener or next app start
      // But we can set loading false after a delay as the browser opens
      Future.delayed(const Duration(seconds: 2), () => isLoading.value = false);
    } catch (e) {
      isLoading.value = false;
      print('❌ Web OAuth Error: $e');
      Get.snackbar('Error', 'Browser login failed: $e', backgroundColor: Colors.red.shade100);
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user, String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isGuest', false);
    await prefs.setBool('isFirstTime', false);

    await prefs.setString('userId', user.id);
    await prefs.setString('userEmail', user.email ?? '');

    final metadata = user.userMetadata;
    String name = metadata?['full_name'] ?? metadata?['name'] ?? '';
    String photo = metadata?['avatar_url'] ?? metadata?['picture'] ?? '';

    await prefs.setString('userName', name);
    await prefs.setString('user_name', name); // Consistency backup
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('userPhoto', photo);
    await prefs.setString('loginMethod', provider);
    await prefs.setString('login_method', provider);

    // Update reactive variables
    userName.value = name;
    userEmail.value = user.email ?? '';
    userPhoto.value = photo;
    loginMethod.value = provider;

    // Load premium status specific to this user account
    final bool premium = prefs.getBool('isPremium_${user.id}') ?? false;
    await prefs.setBool('isPremium_${user.id}', premium);
    await prefs.setBool('isPremium', premium); // Fallback
    isPremium.value = premium;
  }

  // Update User Name in Prefs and Supabase
  Future<void> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setString('user_name', name);
      userName.value = name;

      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Update Supabase profile
        await _supabase.from('profiles').update({
          'full_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } catch (e) {
      print('Error updating user name: $e');
    }
  }

  // Update User Photo in Prefs
  Future<void> updateUserPhoto(String photoPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPhoto', photoPath);
      userPhoto.value = photoPath;
      userPhoto.refresh();
    } catch (e) {
      print('Error updating user photo: $e');
    }
  }

  // Check if profile is complete (has name)
  Future<void> _checkProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? '';

    if (name.isEmpty || name == 'User Name') {
      Get.dialog(
        const NameRequestDialog(),
        barrierDismissible: false,
      );
    }
  }

  // Save email to history for autocomplete
  Future<void> saveEmailToHistory(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> emailHistory = prefs.getStringList('email_history') ?? [];

      // Remove if already exists to avoid duplicates
      emailHistory.remove(email);

      // Add to beginning (most recent first)
      emailHistory.insert(0, email);

      // Keep only last 5 emails
      if (emailHistory.length > 5) {
        emailHistory = emailHistory.sublist(0, 5);
      }

      await prefs.setStringList('email_history', emailHistory);
    } catch (e) {
      print('Error saving email to history: $e');
    }
  }

  // Get email history for autocomplete
  Future<List<String>> getEmailHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('email_history') ?? [];
    } catch (e) {
      print('Error getting email history: $e');
      return [];
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Instant UI lock
    isPremium.value = false;
    user.value = null;
    userName.value = 'User Name';
    userEmail.value = 'user@example.com';

    await _supabase.auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('isGuest', false);
    await prefs.setBool('isPremium', false);

    // Clearing all user details
    await prefs.remove('userId');
    await prefs.remove('userPhone');
    await prefs.remove('user_phone');
    await prefs.remove('userEmail');
    await prefs.remove('user_email');
    await prefs.remove('userName');
    await prefs.remove('user_name');
    await prefs.remove('userPhoto');
    await prefs.remove('loginMethod');
    await prefs.remove('login_method');
    await prefs.remove('isPremium');

    Get.offAllNamed('/signin');
  }
}
