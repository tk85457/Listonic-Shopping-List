import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController authController = Get.find();
  final _emailController = TextEditingController();
  List<String> _emailSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadEmailHistory();
  }

  Future<void> _loadEmailHistory() async {
    final history = await authController.getEmailHistory();
    setState(() {
      _emailSuggestions = history;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }


  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return;
    }
    await authController.signInWithEmail(email);
  }

  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('isGuest', true);
    await prefs.setBool('isFirstTime', false);
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [primaryColor.withOpacity(0.1), Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Branding/Logo
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.shopping_basket_rounded, size: 50, color: primaryColor),
                      ),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),

                  const SizedBox(height: 32),

                  Text(
                    'Smart Grocery',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.2),

                  Text(
                    'AI-powered shopping sorted',
                    style: theme.textTheme.bodyMedium,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

                  const SizedBox(height: 60),

                  // Phone Input Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Enter your email to continue'),
                        const SizedBox(height: 24),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _emailSuggestions;
                            }
                            return _emailSuggestions.where((String option) {
                              return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            _emailController.text = selection;
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            // Sync our controller with autocomplete controller
                            _emailController.text = textEditingController.text;
                            textEditingController.addListener(() {
                              _emailController.text = textEditingController.text;
                            });

                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              onSubmitted: (String value) {
                                onFieldSubmitted();
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  width: MediaQuery.of(context).size.width - 48,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.history,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _signInWithEmail,
                          child: const Text('Send OTP'),
                        ),

                      ],
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Temporarily disabled Google Sign-In due to OAuth configuration
                  // Uncomment after properly configuring Google OAuth in Supabase Dashboard

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: () => authController.signInWithGoogle(),
                    icon: Image.asset(
                      'assets/icon/google_logo.png',
                      height: 24,
                    ),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 700)),

                  const SizedBox(height: 16),

                  const SizedBox(height: 32),


                  const SizedBox(height: 32),

                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Top Right Skip Button - Placed at the end of Stack to be on top
          Positioned(
            top: 20, // Relative to SafeArea start
            right: 16,
            child: SafeArea(
              child: TextButton.icon(
                onPressed: _continueAsGuest,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Skip', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
        ],
      ),
    );

  }
}
