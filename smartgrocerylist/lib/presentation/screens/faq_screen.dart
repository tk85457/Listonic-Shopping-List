import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add items?',
      'answer': 'Tap the floatnig action button (+) or use the "Add" button in any list. You can type, speak, or identify grocery items with AI camera.',
    },
    {
      'question': 'Can I share lists?',
      'answer': 'Yes, use the "Share" icon in any list to send a join link to family or friends.',
    },
    {
      'question': 'How does AI work?',
      'answer': 'Our AI learns your habits to suggest items before you run out and categorizes them automatically.',
    },
    {
      'question': 'Is it available offline?',
      'answer': 'Absolutely. All changes save locally and sync when you\'re back online.',
    },
    {
      'question': 'What is Shopping Mode?',
      'answer': 'A focused, full-screen mode that shows items one-by-one to make in-store navigating easy.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSearchHeader(),
            const SizedBox(height: 32),
            ..._faqs.asMap().entries.map((e) => _buildFaqTile(e.value, e.key)),
            const SizedBox(height: 48),
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('How can we help?', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for articles...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: const Duration(milliseconds: 500));
  }

  Widget _buildFaqTile(Map<String, String> faq, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(faq['question']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(faq['answer']!, style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.1);
  }

  Widget _buildSupportSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_mic_rounded, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Still stuck?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text('Contact our support team anytime.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Email Us'),
          ),
        ],
      ),
    );
  }
}
