import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────
            _HeroCard(cs: cs, isDark: isDark),

            const SizedBox(height: 24),

            // ── Key Points (highlighted) ──────────────────────────────
            _SectionHeading(text: 'Key Highlights', cs: cs),
            const SizedBox(height: 12),
            _HighlightTile(
              icon: Icons.phone_android_rounded,
              color: const Color(0xFF4CAF50),
              title: 'Data stays on your device',
              body:
                  'All your data — grocery lists, items, settings — is stored only on your phone\'s local storage. It never gets sent to any external server or cloud.',
              delay: 0,
            ),
            _HighlightTile(
              icon: Icons.no_accounts_rounded,
              color: const Color(0xFF7C4DFF),
              title: 'No personal info collected',
              body:
                  'We do not collect any personal data. No email address, no phone number, no name, no location. You don\'t need any account to use this app.',
              delay: 80,
            ),
            _HighlightTile(
              icon: Icons.wifi_off_rounded,
              color: const Color(0xFF2196F3),
              title: 'Works completely offline',
              body:
                  'The app works fully without an internet connection. No data transfer happens, there is no analytics server, and there is no tracking of any kind.',
              delay: 160,
            ),
            _HighlightTile(
              icon: Icons.analytics_outlined,
              color: const Color(0xFFFF9800),
              title: 'No analytics or tracking',
              body:
                  'We do not use any usage analytics, crash reports, or behavioral tracking tools. Your app experience is completely private.',
              delay: 240,
            ),

            const SizedBox(height: 28),

            // ── Detailed Sections ──────────────────────────────────────
            _SectionHeading(text: 'Full Details', cs: cs),
            const SizedBox(height: 12),

            _PolicySection(
              index: '1',
              title: 'What We Collect',
              content:
                  'We collect nothing. All data inside the app — such as your lists, items, and preferences — is stored locally on your device and never reaches us.',
              cs: cs,
              isDark: isDark,
              delay: 0,
            ),
            _PolicySection(
              index: '2',
              title: 'Where Your Data Goes',
              content:
                  'Nowhere. There is no cloud sync, no remote server. Your data stays securely in your phone\'s local storage. Uninstall the app and the data is gone — simple.',
              cs: cs,
              isDark: isDark,
              delay: 60,
            ),
            _PolicySection(
              index: '3',
              title: 'How AI Works',
              content:
                  'The app\'s AI features (such as auto-categorization and suggestions) also run locally on your device. No data processing happens on our servers or any third-party servers. Everything is processed right on your phone.',
              cs: cs,
              isDark: isDark,
              delay: 120,
            ),
            _PolicySection(
              index: '4',
              title: 'Third-Party Services',
              content:
                  'We do not use any third-party analytics, advertising, or tracking services. There are no ads in the app. Your shopping habits are yours alone.',
              cs: cs,
              isDark: isDark,
              delay: 180,
            ),
            _PolicySection(
              index: '5',
              title: 'Why We Request Permissions',
              content:
                  'The app only asks for permissions that are strictly necessary:\n• Microphone — only for voice input, no recordings are saved\n• Storage — to save your data locally\n\nNo permission is used to collect data.',
              cs: cs,
              isDark: isDark,
              delay: 240,
            ),
            _PolicySection(
              index: '6',
              title: 'Your Rights',
              content:
                  'Since we collect nothing, "deleting your data" or "exporting your data" is automatically in your hands. Delete the app — everything is gone. Back up your phone — everything is safe.',
              cs: cs,
              isDark: isDark,
              delay: 300,
            ),

            const SizedBox(height: 32),

            // ── Contact ───────────────────────────────────────────────
            _PolicySection(
              index: '✉',
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, feel free to reach out:\n\ntk8545725@gmail.com',
              cs: cs,
              isDark: isDark,
              delay: 360,
            ),

            const SizedBox(height: 16),

            // ── Footer ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.verified_rounded, color: cs.primary, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    'This app is built on a privacy-first principle.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last Updated: April 2026',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  const _HeroCard({required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.18),
            cs.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: cs.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Your Privacy is Our Priority',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SmartCart - AI Shopping List does not collect or store any of your personal data. Your data stays only on your phone — always.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05, duration: 400.ms);
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  const _SectionHeading({required this.text, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: cs.primary,
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final int delay;

  const _HighlightTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.04);
  }
}

class _PolicySection extends StatelessWidget {
  final String index;
  final String title;
  final String content;
  final ColorScheme cs;
  final bool isDark;
  final int delay;

  const _PolicySection({
    required this.index,
    required this.title,
    required this.content,
    required this.cs,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.06);
  }
}

