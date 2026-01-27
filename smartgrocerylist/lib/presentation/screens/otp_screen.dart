import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}


class _OtpScreenState extends State<OtpScreen> {
  final AuthController authController = Get.find();
  final TextEditingController otpController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String identifier = ''; // Can be email or phone
  String type = 'email'; // 'email' or 'phone'
  int countdown = 60;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    type = args['type'] ?? 'email';
    identifier = type == 'email' ? (args['email'] ?? '') : (args['phone'] ?? '');
    _startCountdown();
  }

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown > 0 && mounted) {
        setState(() => countdown--);
        return true;
      } else {
        setState(() => canResend = true);
        return false;
      }
    });
  }

  void _verifyOtp(String otp) {
    if (otp.length == 6) {
      if (type == 'email') {
        authController.verifyEmailOTP(identifier, otp);
      } else {
        authController.verifyOTP(identifier, otp);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!canResend) return;

    setState(() {
      countdown = 60;
      canResend = false;
    });

    if (type == 'email') {
      await authController.signInWithEmail(identifier);
    } else {
      // Phone OTP resend - currently not implemented
      Get.snackbar(
        'Info',
        'Please use email authentication from the sign-in screen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
      );
    }

    _startCountdown();
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: colorScheme.primary, width: 2),
        color: colorScheme.surface,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_outlined, size: 60, color: colorScheme.primary),
            ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),

            const SizedBox(height: 32),
            Text(
              'Security Verification',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(color: colorScheme.onSurfaceVariant, fontSize: 16),
                children: [
                  const TextSpan(text: 'We\'ve sent a code to '),
                  TextSpan(
                    text: identifier,
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            if (type == 'email')
              Text(
                'If you receive a login link instead of a code,\nyou can simply click the link to login!',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.primary.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 48),
            Pinput(
              controller: otpController,
              focusNode: focusNode,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onCompleted: _verifyOtp,
              hapticFeedbackType: HapticFeedbackType.mediumImpact,
              cursor: Container(height: 24, width: 2, color: colorScheme.primary),
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)).slideY(begin: 0.2),

            const SizedBox(height: 40),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: authController.isLoading.value ? null : () => _verifyOtp(otpController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: authController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Verify Code', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Didn\'t receive it? ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                TextButton(
                  onPressed: canResend ? _resendOtp : null,
                  child: Text(
                    canResend ? 'Resend' : 'Try again in ${countdown}s',
                    style: TextStyle(
                      color: canResend ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
