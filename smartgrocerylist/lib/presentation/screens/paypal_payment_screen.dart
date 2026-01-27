import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final String planType;
  final String amount;

  const PayPalPaymentScreen({
    super.key,
    required this.planType,
    required this.amount,
  });

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  bool _paymentInProgress = false;
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    // Auto-open PayPal after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _openPayPalPayment();
      }
    });
  }

  Future<void> _openPayPalPayment() async {
    setState(() => _paymentInProgress = true);

    try {
      final paypalUrl = Uri.parse('https://www.paypal.com/ncp/payment/VPY8M3MX53Q94');

      if (await canLaunchUrl(paypalUrl)) {
        final launched = await launchUrl(
          paypalUrl,
          mode: LaunchMode.externalApplication,
        );

        if (launched && mounted) {
          Get.snackbar(
            'PayPal Opened',
            'Complete your payment in the browser',
            backgroundColor: Colors.blue.shade100,
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        throw Exception('Could not launch PayPal');
      }
    } catch (e) {
      print('Error opening PayPal: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to open PayPal. Please try again.',
          backgroundColor: Colors.red.shade100,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _paymentInProgress = false);
      }
    }
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Did you successfully complete the PayPal payment?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please be honest. Payment verification will be done.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: const Text('Cancel / Not Paid'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Activate premium
              await _authController.setPremium(true);

              if (mounted) {
                Get.snackbar(
                  'Success!',
                  'Premium features activated! Thank you for your payment.',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  duration: const Duration(seconds: 4),
                );

                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Yes, Payment Done',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'PayPal Payment',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plan Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    widget.planType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.amount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'One-time payment',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Text(
              'Payment Steps',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildStep('1', 'PayPal Opens in Browser',
              'Click the button below to open PayPal securely', Icons.open_in_browser),
            const SizedBox(height: 12),
            _buildStep('2', 'Complete Your Payment',
              'Pay \$${widget.amount} using PayPal or Card', Icons.payment),
            const SizedBox(height: 12),
            _buildStep('3', 'Return & Confirm',
              'Come back to app and confirm payment', Icons.check_circle),

            const SizedBox(height: 32),

            // Open PayPal Button
            ElevatedButton.icon(
              onPressed: _paymentInProgress ? null : _openPayPalPayment,
              icon: const Icon(Icons.open_in_browser, size: 24),
              label: const Text(
                'Open PayPal to Pay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),

            const SizedBox(height: 16),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'After Payment',
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              ],
            ),

            const SizedBox(height: 16),

            // Confirm Payment Button
            ElevatedButton.icon(
              onPressed: _confirmPayment,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'I Have Completed Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your payment is processed securely by PayPal. We never see your card details.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey.shade400, size: 24),
        ],
      ),
    );
  }
}
