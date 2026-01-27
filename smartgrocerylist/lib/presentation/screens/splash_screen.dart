import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:smartgrocerylist/core/network/ai_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale animation - icon grows
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Slide animation - icon moves up to center
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Start slightly below center
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize AI Model
    await AIService.initializeMLModel();

    // Start the animation
    _animationController.forward();

    // Show splash for 3 seconds
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      _animationController.stop();
      // Navigate to Auth Check which handles the logic
      Get.offAllNamed('/auth-check');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background decorative circle
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ).animate()
                .scale(duration: const Duration(seconds: 2), curve: Curves.easeInOut)
                .fadeIn(),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated App Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 60,
                                  color: colorScheme.primary,
                                ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App Title with fade-in
                Text(
                  'SmartGrocery',
                  style: GoogleFonts.outfit(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 800))
                  .slideY(begin: 0.3, curve: Curves.easeOut),

                // Subtitle
                Text(
                  'AI - POWERED LISTS',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 4,
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 800))
                  .slideY(begin: 0.5, curve: Curves.easeOut),

                const SizedBox(height: 80),

                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 1500)),
              ],
            ),

            // Version number
            Positioned(
              bottom: 40,
              child: Text(
                'v1.2.0',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: const Duration(seconds: 2)),
            ),
          ],
        ),
      ),
    );
  }
}
