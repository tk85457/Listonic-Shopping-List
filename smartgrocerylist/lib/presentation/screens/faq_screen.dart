import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Getting Started', 'Lists & Items', 'AI Features', 'Privacy & Data'];

  static const _allFaqs = [
    _FAQ(
      category: 'Getting Started',
      icon: Icons.rocket_launch_rounded,
      question: 'How do I create my first list?',
      answer:
          'Tap the "+" button on the Home screen. Give your list a name (e.g., "Weekly Groceries") and tap Create. The list is ready instantly — then add items to it.',
    ),
    _FAQ(
      category: 'Getting Started',
      icon: Icons.add_shopping_cart_rounded,
      question: 'How do I add an item?',
      answer:
          'Open any list and tap the "+" button at the bottom. Type the item name, then select the category, quantity, and unit. You can also add items by voice — tap the mic icon and speak.',
    ),
    _FAQ(
      category: 'Getting Started',
      icon: Icons.check_circle_outline_rounded,
      question: 'How do I check off an item?',
      answer:
          'Tap the circle on the left side of the item in your list. The item will be marked as checked. Once all items are checked, the list is complete.',
    ),
    _FAQ(
      category: 'Lists & Items',
      icon: Icons.edit_rounded,
      question: 'How do I edit an item?',
      answer:
          'Tap on an item in the list — the edit screen will open. From there you can change the name, quantity, category, unit, and aisle.',
    ),
    _FAQ(
      category: 'Lists & Items',
      icon: Icons.delete_outline_rounded,
      question: 'Can I recover a deleted item?',
      answer:
          'Yes! Any deleted item goes to the Trash. You can restore it from Settings → Trash. Items remain in the trash for 30 days.',
    ),
    _FAQ(
      category: 'Lists & Items',
      icon: Icons.share_rounded,
      question: 'Can I share a list with someone?',
      answer:
          'Open the list and tap the share icon in the top right. A text or link will be generated that you can send to family or friends. Simple and quick.',
    ),
    _FAQ(
      category: 'Lists & Items',
      icon: Icons.shopping_bag_outlined,
      question: 'What is Shopping Mode?',
      answer:
          'Shopping Mode is a focused view designed for use in the store. Items are displayed clearly and checking them off is easy. You\'ll find the Shopping Mode option at the top of the list screen.',
    ),
    _FAQ(
      category: 'Lists & Items',
      icon: Icons.sort_rounded,
      question: 'Can I sort or filter items?',
      answer:
          'Yes! In the list screen, use the filter icon to filter items by category, aisle, or status. Items are also automatically grouped by category.',
    ),
    _FAQ(
      category: 'AI Features',
      icon: Icons.auto_awesome_rounded,
      question: 'How do AI Suggestions work?',
      answer:
          'The app learns your shopping habits and predicts what you might need next. Everything happens locally on your phone — no data is sent anywhere.',
    ),
    _FAQ(
      category: 'AI Features',
      icon: Icons.mic_rounded,
      question: 'Can I add items by voice?',
      answer:
          'Absolutely! Tap the mic icon on the Add Item screen and say the item name. The app will automatically fill in the item name. It works in both Hindi and English.',
    ),
    _FAQ(
      category: 'AI Features',
      icon: Icons.category_outlined,
      question: 'How does AI auto-categorize items?',
      answer:
          'As you type an item name, the AI automatically guesses its category. Type "Milk" and it becomes Dairy & Eggs, type "Apple" and it becomes Produce — all instantly, without internet.',
    ),
    _FAQ(
      category: 'Privacy & Data',
      icon: Icons.phone_android_rounded,
      question: 'Where is my data stored?',
      answer:
          'All your data is stored only on your phone. No information is ever sent to any server or cloud. The app works completely offline.',
    ),
    _FAQ(
      category: 'Privacy & Data',
      icon: Icons.no_accounts_rounded,
      question: 'Does the app take my email or contacts?',
      answer:
          'Absolutely not. We do not collect any personal information — no email, no phone number, no name. You don\'t need to create any account to use the app.',
    ),
    _FAQ(
      category: 'Privacy & Data',
      icon: Icons.wifi_off_rounded,
      question: 'Does the app work offline?',
      answer:
          'Yes, completely offline. No internet connection is needed. All data is saved locally and is instantly available at all times.',
    ),
    _FAQ(
      category: 'Privacy & Data',
      icon: Icons.delete_forever_rounded,
      question: 'How do I delete my data?',
      answer:
          'Uninstalling the app deletes all your data — because everything was only on your phone. There is no cloud account to delete.',
    ),
  ];

  List<_FAQ> get _filtered {
    final q = _query.toLowerCase().trim();
    return _allFaqs.where((faq) {
      final matchCat = _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchQ = q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'tk8545725@gmail.com',
      queryParameters: {
        'subject': 'Listonic - Shopping List Support',
        'body': 'Describe your issue:\n\n',
      },
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ── Hero Header ─────────────────────────────────────────────
          _buildHeader(cs, isDark),

          // ── Search ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search questions...',
                hintStyle: GoogleFonts.outfit(color: cs.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          ),

          // ── Category Chips ───────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              separatorBuilder: (context2, index2) => const SizedBox(width: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── FAQ List ─────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty(cs)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length + 1, // +1 for contact support card
                    itemBuilder: (_, i) {
                      if (i < filtered.length) {
                        return _FAQTile(faq: filtered[i], index: i, cs: cs, isDark: isDark);
                      }
                      // Contact Support card at the bottom
                      return _ContactCard(cs: cs, isDark: isDark, onTap: _contactSupport);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.15),
            cs.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.help_center_rounded, color: cs.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a question?',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_allFaqs.length} answers available',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05, duration: 400.ms);
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try different keywords',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Contact Support Card
// ──────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactCard({required this.cs, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.15),
            cs.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.support_agent_rounded, color: cs.primary, size: 36),
          const SizedBox(height: 10),
          Text(
            'Still need help?',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Can\'t find your answer? Contact our support team directly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.email_outlined, size: 18),
              label: Text(
                'Contact Support',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FAQ Model
// ──────────────────────────────────────────────────────────────────────────────

class _FAQ {
  final String category;
  final IconData icon;
  final String question;
  final String answer;

  const _FAQ({
    required this.category,
    required this.icon,
    required this.question,
    required this.answer,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
// FAQ Tile Widget
// ──────────────────────────────────────────────────────────────────────────────

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  final int index;
  final ColorScheme cs;
  final bool isDark;

  const _FAQTile({required this.faq, required this.index, required this.cs, required this.isDark});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _rotCtrl;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _rotCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _rotCtrl.forward();
    } else {
      _rotCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _expanded
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: _expanded ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.faq.icon, color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: cs.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 70,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.faq.answer,
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            color: cs.onSurfaceVariant,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.index * 60)).slideY(begin: 0.08);
  }
}

