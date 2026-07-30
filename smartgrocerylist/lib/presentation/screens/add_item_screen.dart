import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grocerylist/data/repositories/grocery_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/core/services/voice_service.dart';
import 'package:grocerylist/controllers/navigation_controller.dart';
import 'package:grocerylist/core/network/ai_service.dart';
import 'package:grocerylist/core/constants/app_categories.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';

class AddItemScreen extends StatefulWidget {
  final String listId;
  final GroceryItem? item;

  const AddItemScreen({super.key, required this.listId, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final GroceryRepository _repository = GroceryRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late final TextEditingController _quantityController;
  String? _imageUrl;
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;

  String? _selectedCategory;
  int _quantity = 1;
  String? _selectedUnit;
  String? _selectedStoreAisle;
  List<String> _mlSuggestions = [];
  bool _isLoadingSuggestions = false;


  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _notesController.text = widget.item!.notes;
      _quantity = widget.item!.quantity.toInt();
      _selectedCategory = widget.item!.category;
      _selectedUnit = widget.item!.unit;
      _selectedStoreAisle = widget.item!.storeAisle;
      _imageUrl = widget.item!.imageUrl;
    } else {
      _selectedCategory = AppCategories.produce;
      _selectedUnit = 'item';
      _selectedStoreAisle = AppCategories.produce;
    }
    _quantityController = TextEditingController(text: _quantity.toString());
    AIService.initializeMLModel().then((_) {
      if (mounted) setState(() {});
    });
  }

  final List<String> _categories = [
    'Produce', 'Dairy & Eggs', 'Meat & Seafood', 'Bakery', 'Pantry Staples',
    'Frozen Foods', 'Beverages', 'Snacks', 'Personal Care', 'Household Items', 'Other',
  ];

  final List<String> _units = [
    'item', 'lbs', 'oz', 'kg', 'g', 'ml', 'liter', 'box', 'bag', 'pack', 'dozen', 'can', 'bottle',
  ];

  final List<String> _aisles = [
    'Produce', 'Meat & Seafood', 'Dairy & Eggs', 'Bakery', 'Pantry', 'Frozen',
    'Beverages', 'Snacks', 'Personal Care', 'Household',
  ];


  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _loadMLSuggestions(String input) async {
    if (input.isEmpty) {
      if (mounted) setState(() => _mlSuggestions = []);
      return;
    }

    if (mounted) setState(() => _isLoadingSuggestions = true);

    try {
      final suggestions = await AIService.getSuggestions(input);
      final category = await AIService.categorizeItem(input);

      if (mounted) {
        setState(() {
          _mlSuggestions = suggestions;
          _isLoadingSuggestions = false;
          if (category != null && category != AppCategories.other) {
            _selectedCategory = category;
            _selectedStoreAisle = _getAisleForCategory(category);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  void _startVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      return;
    }

    // Show a small hint that we're listening
    SnackbarService.showInfo('Listening...', 'Speak the item name');

    if (!(await _voiceService.initialize())) {
      HapticFeedback.vibrate();
      SnackbarService.showError('Error', 'Voice recognition not available');
      return;
    }

    HapticFeedback.mediumImpact();
    await _voiceService.startListening(
      onResult: (text) async {
        if (text.isNotEmpty) {
          _nameController.text = text;
          // Auto-categorize as they speak (if they pause)
          if (!_isListening) {
             setState(() {
              _selectedStoreAisle = _getAisleForCategory(_selectedCategory!);
            });
          }
        }
      },
      onListeningChanged: (listening) {
        if (mounted) {
          setState(() => _isListening = listening);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item != null ? 'Edit Item' : 'Add New Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _addItem();
              },
              icon: const Icon(Icons.check_rounded),
              color: colorScheme.primary,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernTextField(
                controller: _nameController,
                label: 'What do you need?',
                hint: 'e.g. Greek Yogurt, Whole Milk',
                icon: Icons.shopping_bag_outlined,
                onChanged: _loadMLSuggestions,
                suffix: _buildMediaActions(),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(begin: 0.1),
              if (_imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageUrl!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildSmartSuggestions(),
              if (_mlSuggestions.isEmpty) ...[
                const SizedBox(height: 16),
                _buildQuickAddSection(),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildModernTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: '1',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildModernDropdown(
                      label: 'Unit',
                      value: _selectedUnit,
                      items: _units,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedUnit = v);
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideX(begin: 0.1),
              const SizedBox(height: 20),
              _buildModernDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = v;
                    _selectedStoreAisle = _getAisleForCategory(v!);
                  });
                },
                prefixIcon: Icons.category_outlined,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideX(begin: 0.1),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Brand, special instructions...',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.item != null ? 'Update Item' : 'Add to List',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate()
                .scale(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack)
                .shimmer(delay: const Duration(milliseconds: 1200), duration: const Duration(seconds: 2)),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    Widget? suffix,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            suffixIcon: suffix,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? prefixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          icon: const Icon(Icons.expand_more_rounded),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }
  Widget _buildMediaActions() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Voice Input',
          icon: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
          color: _isListening ? Colors.red : colorScheme.primary,
          onPressed: _isListening ? _voiceService.stopListening : _startVoiceInput,
        ),
      ],
    );
  }
  Widget _buildSmartSuggestions() {
    if (_mlSuggestions.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Suggestions',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
            if (_isLoadingSuggestions)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mlSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _mlSuggestions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(suggestion, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    _nameController.text = suggestion;
                    _nameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: suggestion.length));

                    final category = await AIService.categorizeItem(suggestion);
                    setState(() {
                      if (category != null) {
                        _selectedCategory = category;
                        _selectedStoreAisle = _getAisleForCategory(category);
                      }
                      _mlSuggestions = [];
                    });

                    AIService.trackTypingPattern(suggestion, suggestion);
                  },
                  backgroundColor: isDark
                      ? cs.primaryContainer.withValues(alpha: 0.25)
                      : cs.primary.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: cs.primary.withValues(alpha: isDark ? 0.4 : 0.25),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildQuickAddSection() {
    final learned = AIService.getRecentLearnedItems().where((e) => e.trim().isNotEmpty).toList();
    final staticItems = ['Milk', 'Eggs', 'Bread', 'Butter', 'Cheese', 'Apples', 'Banana'];
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Combine items, remove duplicates from static if they are in learned
    final combinedItems = [...learned, ...staticItems.where((e) => !learned.contains(e))].take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(learned.isNotEmpty ? 'Recently Added & Popular' : 'Quick Add',
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: combinedItems
              .map((e) => ActionChip(
                    label: Text(e, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                    avatar: learned.contains(e) ? Icon(Icons.history_rounded, size: 14, color: cs.onSurface) : null,
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      _nameController.text = e;
                      final category = await AIService.categorizeItem(e);
                      setState(() {
                         if (category != null) {
                           _selectedCategory = category;
                           _selectedStoreAisle = _getAisleForCategory(category);
                         }
                      });
                    },
                    backgroundColor: learned.contains(e)
                      ? (isDark ? cs.primaryContainer.withValues(alpha: 0.25) : cs.primary.withValues(alpha: 0.12))
                      : (isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.06)),
                    side: BorderSide(
                      color: learned.contains(e)
                          ? cs.primary.withValues(alpha: isDark ? 0.4 : 0.25)
                          : cs.onSurface.withValues(alpha: isDark ? 0.1 : 0.08),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _getAisleForCategory(String category) {
    return _aisles.contains(category) ? category : 'Pantry';
  }

  void _addItem() async {
    if (_nameController.text.isEmpty) return;

    final name = _nameController.text;
    final result = {
      'id': widget.item?.id ?? const Uuid().v4(),
      'name': name,
      'category': _selectedCategory,
      'quantity': int.tryParse(_quantityController.text) ?? 1,
      'unit': _selectedUnit,
      'notes': _notesController.text,
      'isChecked': widget.item?.isChecked ?? false,
      'image_url': _imageUrl,
      'store_aisle': _selectedStoreAisle,
    };

    if (widget.item == null) {
      // New item mode: Save directly and stay on screen for continuous entry
      try {
        final newItem = GroceryItem(
          id: result['id'] as String,
          name: result['name'] as String,
          category: result['category'] as String,
          quantity: (result['quantity'] as num).toInt(),
          unit: result['unit'] as String,
          notes: (result['notes'] as String?) ?? '',
          listId: widget.listId,
          isChecked: false,
          storeAisle: (result['store_aisle'] as String?) ?? 'Other',
          imageUrl: _imageUrl,
        );

        await _repository.addGroceryItem(newItem);
        await AIService.learnItem(name, _selectedCategory); // Learn for future suggestions

        // Notify parent list to refresh in background
        Get.find<NavigationController>().triggerDataRefresh();

        // Immediate physical/visual feedback
        HapticFeedback.mediumImpact();
        SnackbarService.showSimple('"$name" added');

        // Clear fields for next item
        setState(() {
          _nameController.clear();
          _notesController.clear();
          _quantity = 1;
          _quantityController.text = '1';
        });
      } catch (e) {
        SnackbarService.showError('Error', 'Failed to add item: $e');
      }
    } else {
      // Edit mode: Pop back with result (parent handles update)
      Get.back(result: result);
    }
  }
}


