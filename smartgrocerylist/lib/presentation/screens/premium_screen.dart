import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:smartgrocerylist/controllers/navigation_controller.dart';
import 'package:smartgrocerylist/presentation/screens/paypal_payment_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() {
    _authController.isLoggedIn().then((isLoggedIn) {
      if (!isLoggedIn) {
        Get.offNamed('/signin');
        Get.snackbar(
          'Login Required',
          'Please sign in to view premium plans.',
          backgroundColor: Colors.blue.shade100,
          snackPosition: SnackPosition.BOTTOM
        );
      }
    });
  }

  Future<void> _purchasePlan(String planType) async {
    // Determine the amount based on plan type
    String amount = planType.contains('Yearly') ? '\$10' : '\$3';

    // Navigate to PayPal payment screen
    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PayPalPaymentScreen(
          planType: planType,
          amount: amount,
        ),
      ),
    );

    // If payment was successful (automatically detected by WebView)
    if (paymentSuccess == true) {
      // Show success loading
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Activating Premium...',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(seconds: 1));

      // Activate premium
      await _authController.setPremium(true);

      // Trigger UI refresh across all screens
      Get.find<NavigationController>().triggerDataRefresh();

      if (!mounted) return;
      Get.back(); // Close loading dialog

      // Show success message
      Get.snackbar(
        'You\'re in!',
        'Premium activated successfully.',
        backgroundColor: Colors.amber,
        colorText: Colors.black,
        icon: const Icon(Icons.stars_rounded),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isPremium = _authController.isPremium.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            isPremium ? 'Premium Member' : 'Go Premium',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(isPremium),
              const SizedBox(height: 48),
              _buildFeaturesList(),
              const SizedBox(height: 48),
              if (!isPremium) _buildPricing() else _buildManagePlan(),
              const SizedBox(height: 40),
              Text(
                'Recurring billing. Cancel anytime in your device settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isPremium) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10)
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
          ).animate().scale(duration: const Duration(milliseconds: 800), curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            isPremium ? 'Welcome, VIP!' : 'Elevate Your Shopping',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPremium
              ? 'All premium features are active.'
              : 'Unlock AI suggestions, cloud sync, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(Icons.psychology_rounded, 'AI Smart Categorization', 'Instantly groups items as you add them.'),
        _buildFeatureItem(Icons.sync_rounded, 'Cloud Sync & Share', 'Access lists from any device in real-time.'),
        _buildFeatureItem(Icons.palette_rounded, 'Exclusive Themes', 'Unlock premium obsidian and pastel themes.'),
        _buildFeatureItem(Icons.mic_rounded, 'Voice-to-List', 'Add multiple items naturally with your voice.'),
        _buildFeatureItem(Icons.ads_click_rounded, 'No Intrusive Ads', 'Clean, focused, and ultra-fast experience.'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16)
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideX(begin: 0.1);
  }

  Widget _buildPricing() {
    return Column(
      children: [
        _buildPlanCard('Yearly Saver', '\$10', 'Only \$0.83/month', true),
        const SizedBox(height: 16),
        _buildPlanCard('Monthly', '\$3', 'Cancel anytime', false),
      ],
    );
  }

  Widget _buildPlanCard(String title, String price, String sub, bool popular) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: popular ? colorScheme.primaryContainer.withValues(alpha: 0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: popular ? colorScheme.primary : colorScheme.outlineVariant,
          width: popular ? 2 : 1
        ),
      ),
      child: Column(
        children: [
          if (popular) Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(20)),
            child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(sub, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ],
              ),
              Text(price, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _purchasePlan(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: popular ? colorScheme.primary : colorScheme.onSurface,
                foregroundColor: popular ? colorScheme.onPrimary : colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagePlan() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text('Subscription Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Next billing date: Feb 20, 2026'),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => _showCancelSubscriptionDialog(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Cancel Subscription')
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Cancel Subscription?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to cancel your premium subscription?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You will lose access to all premium features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Premium'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    // Show loading
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('Cancelling subscription...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 1));

    // Remove premium status
    await _authController.setPremium(false);

    // Trigger UI refresh
    Get.find<NavigationController>().triggerDataRefresh();

    if (!mounted) return;
    Get.back(); // Close loading dialog

    Get.snackbar(
      'Subscription Cancelled',
      'Your premium subscription has been cancelled.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}
