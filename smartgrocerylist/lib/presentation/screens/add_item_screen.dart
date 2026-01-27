import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/data/repositories/grocery_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:smartgrocerylist/core/network/ai_service.dart';
import 'package:smartgrocerylist/core/services/voice_service.dart';
import 'package:smartgrocerylist/core/services/supabase_service.dart';

class AddItemScreen extends StatefulWidget {
  final String listId;
  final GroceryItem? item;

  const AddItemScreen({super.key, required this.listId, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late final TextEditingController _quantityController;
  String? _imageUrl;
  bool _isUploadingImage = false;

  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;

  String? _selectedCategory;
  int _quantity = 1;
  String? _selectedUnit;
  String? _selectedStoreAisle;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _notesController.text = widget.item!.notes ?? '';
      _quantity = widget.item!.quantity.toInt();
      _selectedCategory = widget.item!.category;
      _selectedUnit = widget.item!.unit;
      _selectedStoreAisle = widget.item!.storeAisle;
      _imageUrl = widget.item!.imageUrl;
    } else {
      _selectedCategory = 'Produce';
      _selectedUnit = 'item';
      _selectedStoreAisle = 'Produce';
    }
    _quantityController = TextEditingController(text: _quantity.toString());
    AIService.initializeMLModel();
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

  List<String> _mlSuggestions = [];
  bool _isLoadingSuggestions = false;

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
      setState(() => _mlSuggestions = []);
      return;
    }
    setState(() => _isLoadingSuggestions = true);
    try {
      final history = await _getGroceryItems();
      final suggestions = await AIService.getEnhancedItemSuggestions(input, history, widget.listId);
      if (mounted) {
        setState(() {
          _mlSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  Future<List<String>> _getGroceryItems() async {
    try {
      final repository = Get.find<GroceryRepository>();
      final items = await repository.getGroceryItems(widget.listId);
      return items.map((e) => e.name).toList();
    } catch (e) {
      return [];
    }
  }

  void _startVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      return;
    }

    // Show a small hint that we're listening
    Get.snackbar(
      'Listening...',
      'Speak the name of the item you want to add',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade100,
      icon: const Icon(Icons.mic_rounded, color: Colors.blue),
      duration: const Duration(seconds: 2),
    );

    if (!(await _voiceService.initialize())) {
      Get.snackbar('Error', 'Voice recognition not available',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    await _voiceService.startListening(
      onResult: (text) async {
        if (text.isNotEmpty) {
          _nameController.text = text;
          // Auto-categorize as they speak (if they pause)
          if (!_isListening) {
            final category = await AIService.categorizeItem(text);
            setState(() {
              _selectedCategory = category;
              _selectedStoreAisle = _getAisleForCategory(category);
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

  Future<void> _handleImageInput(ImageSource source) async {
    PermissionStatus status = PermissionStatus.granted;
    if (!kIsWeb) {
      status = source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();
    }

    if (status.isDenied) return;

    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() => _isUploadingImage = true);

        Get.snackbar('Analyzing', 'Identifying item...',
            showProgressIndicator: true, backgroundColor: Colors.blueAccent, colorText: Colors.white);

        final suggestion = await AIService.suggestItemFromImage(image.path);

        _nameController.text = suggestion;
        final category = await AIService.categorizeItem(suggestion);

        // Upload to Supabase
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await SupabaseService.uploadImage(image.path, fileName);

        setState(() {
          _imageUrl = url;
          _selectedCategory = category;
          _selectedStoreAisle = _getAisleForCategory(category);
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      Get.snackbar('Error', 'Failed to analyze or upload image');
    }
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
              onPressed: _addItem,
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
              ),
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
                      onChanged: (v) => setState(() => _selectedUnit = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildModernDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v;
                    _selectedStoreAisle = _getAisleForCategory(v!);
                  });
                },
                prefixIcon: Icons.category_outlined,
              ),
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
              ).animate().scale(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 32),
              _buildQuickAddSection(),
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
          value: value,
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
        IconButton(
          tooltip: 'AI Scan',
          icon: Icon(Icons.center_focus_strong_rounded, color: colorScheme.primary),
          onPressed: () async {
            final result = await Get.toNamed('/object-detection/${widget.listId}');
            if (result != null && result is Map<String, dynamic>) {
              _nameController.text = result['name'];
              final category = await AIService.categorizeItem(result['name']);
              setState(() {
                _selectedCategory = category;
                _selectedStoreAisle = _getAisleForCategory(category);
              });
            }
          },
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: const Duration(seconds: 2), color: colorScheme.primary.withOpacity(0.3)),
        if (_isUploadingImage)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          PopupMenuButton<ImageSource>(
            tooltip: 'Add Photo',
            icon: Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
            onSelected: _handleImageInput,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: ImageSource.camera, child: Text('Take Photo')),
              const PopupMenuItem(value: ImageSource.gallery, child: Text('Choose Gallery')),
            ],
          ),
      ],
    );
  }

  Widget _buildSmartSuggestions() {
    if (_mlSuggestions.isEmpty && !_isLoadingSuggestions) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text('SMART SUGGESTIONS',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              if (_isLoadingSuggestions) ...[
                const SizedBox(width: 8),
                const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _mlSuggestions.map((s) => ActionChip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              onPressed: () async {
                _nameController.text = s;
                final cat = await AIService.categorizeItem(s);
                setState(() => _selectedCategory = cat);
              },
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Add', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Milk', 'Eggs', 'Bread', 'Butter', 'Cheese', 'Apples', 'Banana']
              .map((e) => ActionChip(
                    label: Text(e),
                    onPressed: () async {
                      _nameController.text = e;
                      final cat = await AIService.categorizeItem(e);
                      setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _getAisleForCategory(String category) {
    return _aisles.contains(category) ? category : 'Pantry';
  }

  void _addItem() {
    if (_nameController.text.isEmpty) return;

    final result = {
      'id': widget.item?.id ?? const Uuid().v4(),
      'name': _nameController.text,
      'category': _selectedCategory,
      'quantity': int.tryParse(_quantityController.text) ?? 1,
      'unit': _selectedUnit,
      'notes': _notesController.text,
      'isChecked': widget.item?.isChecked ?? false,
      'image_url': _imageUrl,
      'store_aisle': _selectedStoreAisle,
    };
    // Track for ML learning
    AIService.trackTypingPattern(_nameController.text.substring(0, min(3, _nameController.text.length)), _nameController.text);

    Get.back(result: result);
  }
}
