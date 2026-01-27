import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(Icons.security_rounded, size: 40, color: colorScheme.primary),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Data is Safe', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('We respect your privacy and protect your information.'),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 32),
            _buildSection(context, '1. Information We Collect', 'We collect your email, phone number, and grocery list data to provide and sync our services across devices.'),
            _buildSection(context, '2. Usage', 'Data is used for authentication, list synchronization, and providing AI-powered shopping suggestions.'),
            _buildSection(context, '3. Sharing', 'We never sell your data. We only share it when required by law or to protect our legal rights.'),
            _buildSection(context, '4. Security', 'We use industry-standard encryption to keep your data secure during transmission and storage.'),
            _buildSection(context, '5. Your Rights', 'You can export or delete your data anytime from the Profile settings.'),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: February 20, 2026',
                style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.6, fontSize: 15)),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideY(begin: 0.1);
  }
}
