import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartgrocerylist/controllers/navigation_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/core/services/share_service.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:smartgrocerylist/data/repositories/grocery_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  final ShoppingList? list;

  const ListDetailScreen({super.key, required this.listId, this.list});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  String _listName = 'Weekly Groceries';
  final List<GroceryItem> _items = [];
  final GroceryRepository _repository = GroceryRepository();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  String _searchQuery = '';

  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    // Set the list name from the passed list or use default
    if (widget.list != null) {
      _listName = widget.list!.name;
      // Update navigation controller with the passed list
      final navController = Get.find<NavigationController>();
      navController.setCurrentList(widget.list!);
    }
    _renameController.text = _listName;
    _loadItems();

    _refreshWorker = ever(
      Get.find<NavigationController>().refreshData,
      (_) => _loadItems(),
    );
  }

  Future<void> _loadItems() async {
    try {
      final items = await _repository.getGroceryItems(widget.listId);
      setState(() {
        _items.clear();
        _items.addAll(items);
      });
      _updateGroupedItems();
    } catch (e) {
      // Handle error
    }
  }

  // Group items by category
  Map<String, List<GroceryItem>> _cachedGroupedItems = {};

  void _updateGroupedItems() {
    Map<String, List<GroceryItem>> grouped = {};
    for (var item in _items) {
      if (item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        if (!grouped.containsKey(item.category)) {
          grouped[item.category] = [];
        }
        grouped[item.category]!.add(item);
      }
    }
    setState(() {
      _cachedGroupedItems = grouped;
    });
  }

  int get _checkedCount {
    return _items.where((item) => item.isChecked).length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navController = Get.find<NavigationController>();
        navController.clearCurrentList();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Real-time Item Counter & Progress
              _buildModernCounter(),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchQuery = value;
                    _updateGroupedItems();
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _updateGroupedItems();
                            },
                          )
                        : null,
                    hintText: 'Search in ${_listName}...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),

              // Items list
              Expanded(
                child: _items.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _cachedGroupedItems.length,
                        itemBuilder: (context, index) {
                          final category = _cachedGroupedItems.keys.elementAt(index);
                          final items = _cachedGroupedItems[category]!;
                          return _buildCategorySection(category, items, index);
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: _navigateToAddItem,
                label: Text('Add Item', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.add_rounded),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
              ).animate().scale(delay: const Duration(milliseconds: 300), curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildModernCounter() {
    final colorScheme = Theme.of(context).colorScheme;
    final total = _items.length;
    final checked = _checkedCount;
    final progress = total == 0 ? 0.0 : checked / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shopping Progress',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$checked',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' / $total items',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your list is empty',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "+" to add items and start shopping',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      title: Text('${_selectedItemIds.length} Selected', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: _exitSelectionMode,
      ),
      actions: [
        if (_selectedItemIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareSelectedItems,
          ),
        if (_selectedItemIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _deleteSelectedItems,
          ),
      ],
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        _listName,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onSelected: (value) {
            if (value == 'rename') {
              _showRenameDialog();
            } else if (value == 'delete_all') {
              _deleteAllItems();
            } else if (value.startsWith('copy_')) {
              _handleEnhancedCopy(value);
            }
          },
          itemBuilder: (context) => [
            _buildPopupItem('rename', Icons.edit_rounded, 'Rename List'),
            const PopupMenuDivider(),
            _buildPopupItem('copy_unpurchased', Icons.copy_rounded, 'Copy Unpurchased Only'),
            _buildPopupItem('copy_purchased', Icons.rule_rounded, 'Copy Purchased Only'),
            _buildPopupItem('copy_all', Icons.content_paste_rounded, 'Copy Whole List'),
            const PopupMenuDivider(),
            _buildPopupItem('delete_all', Icons.delete_sweep_rounded, 'Delete All Items', isDestructive: true),
          ],
        ),
      ],
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: isDestructive ? Colors.red : null, fontWeight: isDestructive ? FontWeight.bold : null)),
        ],
      ),
    );
  }

  void _handleEnhancedCopy(String type) async {
    String content = '🛒 $_listName\n\n';
    List<GroceryItem> filteredItems = [];

    if (type == 'copy_unpurchased') {
      filteredItems = _items.where((item) => !item.isChecked).toList();
      content += '-- 📝 UNPURCHASED ITEMS --\n';
    } else if (type == 'copy_purchased') {
      filteredItems = _items.where((item) => item.isChecked).toList();
      content += '-- ✅ PURCHASED ITEMS --\n';
    } else {
      filteredItems = _items;
      content += '-- 📦 ALL ITEMS --\n';
    }

    if (filteredItems.isEmpty) {
      Get.snackbar('Empty', 'No items match your criteria', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    for (var item in filteredItems) {
      final status = item.isChecked ? '[DONE]' : '[PENDING]';
      content += '• $status ${item.name} (${item.quantity} ${item.unit})\n';
    }

    content += '\nGenerated by Smart Grocery List';

    await ShareService.copyToClipboard(content);
    Get.snackbar(
      'Copied!',
      'List content copied to clipboard',
      backgroundColor: Theme.of(context).colorScheme.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteSelectedItems() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text('Delete ${_selectedItemIds.length} items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      for (var id in _selectedItemIds) {
        await _repository.softDeleteGroceryItem(id);
      }
      setState(() {
        _items.removeWhere((item) => _selectedItemIds.contains(item.id));
        _selectedItemIds.clear();
        _isSelectionMode = false;
      });
      _updateGroupedItems();
      Get.find<NavigationController>().triggerTrashRefresh();
      Get.snackbar('Deleted', 'Items moved to trash', backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void _deleteAllItems() async {
    if (_items.isEmpty) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Items'),
        content: const Text('Move all items to trash?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      for (var item in _items) {
        await _repository.softDeleteGroceryItem(item.id);
      }
      setState(() {
        _items.clear();
      });
      _updateGroupedItems();
      Get.find<NavigationController>().triggerTrashRefresh();
      Get.snackbar('Deleted', 'All items moved to trash', backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void _editItem(GroceryItem item) async {
    final result = await Get.toNamed('/add-item/${widget.listId}', arguments: item);
    if (result != null && result is Map<String, dynamic>) {
      try {
        final updatedItem = item.copyWith(
          name: result['name'],
          category: result['category'],
          quantity: (result['quantity'] as num).toInt(),
          unit: result['unit'],
          notes: result['notes'] ?? '',
          imageUrl: result['image_url'],
          storeAisle: result['store_aisle'] ?? 'Other',
        );
        await _repository.updateGroceryItem(updatedItem);

        final index = _items.indexWhere((i) => i.id == item.id);
        if (index >= 0) {
          setState(() {
            _items[index] = updatedItem;
          });
          _updateGroupedItems();
          Get.find<NavigationController>().triggerDataRefresh();
        }
        Get.snackbar('Success', 'Item updated', backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Error', 'Failed to update item: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  Future<void> _navigateToAddItem() async {
    final result = await Get.toNamed('/add-item/${widget.listId}');
    if (result != null && result is Map<String, dynamic>) {
      try {
        final newItem = GroceryItem(
          id: result['id'],
          name: result['name'],
          category: result['category'],
          quantity: (result['quantity'] as num).toInt(),
          unit: result['unit'],
          notes: result['notes'] ?? '',
          listId: widget.listId,
          isChecked: false,
          storeAisle: result['store_aisle'] ?? 'Other',
        );
        await _repository.addGroceryItem(newItem);
        setState(() => _items.add(newItem));
        _updateGroupedItems();
        Get.find<NavigationController>().triggerDataRefresh();
        Get.snackbar('Success', 'Item "${newItem.name}" added', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'Failed to add item: $e', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _buildCategorySection(String category, List<GroceryItem> items, int index) {
    final color = AppTheme.categoryColors[category] ?? AppTheme.categoryColors['Other']!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildItemTile(item, color)),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.05);
  }

  Widget _buildItemTile(GroceryItem item, Color categoryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedItemIds.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : item.isChecked
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
            ? colorScheme.primary
            : item.isChecked
              ? Colors.transparent
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          if (!item.isChecked && !isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isSelectionMode
            ? () => _toggleSelection(item.id)
            : () => _toggleItemChecked(item),
          onLongPress: _isSelectionMode ? null : () {
            _enterSelectionMode();
            _toggleSelection(item.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildCheckbox(item, categoryColor),
                const SizedBox(width: 8),
                if (item.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                        ),
                      ),
                      if (item.notes.isNotEmpty)
                        Text(
                          item.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isChecked ? Colors.transparent : categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.quantity}${item.unit}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.isChecked ? colorScheme.onSurfaceVariant : categoryColor,
                    ),
                  ),
                ),
                if (!_isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    onPressed: () => _showItemActions(item),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(GroceryItem item, Color color) {
    if (_isSelectionMode) {
      return Checkbox(
        value: _selectedItemIds.contains(item.id),
        onChanged: (v) => _toggleSelection(item.id),
        activeColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      );
    }

    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: item.isChecked,
        onChanged: (v) => _toggleItemChecked(item),
        activeColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  void _toggleItemChecked(GroceryItem item) async {
    final oldChecked = item.isChecked;
    final newChecked = !oldChecked;
    setState(() => item.isChecked = newChecked);
    try {
      await _repository.updateGroceryItem(item.copyWith(isChecked: newChecked));
      _updateGroupedItems();
      Get.find<NavigationController>().triggerDataRefresh();
    } catch (e) {
      setState(() => item.isChecked = oldChecked);
      Get.snackbar('Error', 'Failed to update item: $e', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showItemActions(GroceryItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildActionTile(Icons.edit_rounded, 'Edit Item', () {
              Navigator.pop(context);
              _editItem(item);
            }),
            _buildActionTile(Icons.share_rounded, 'Share Item', () {
              Navigator.pop(context);
              ShareService.shareItem(item, _listName);
            }),
            _buildActionTile(Icons.delete_outline_rounded, 'Delete Item', () {
              Navigator.pop(context);
              _removeItem(item);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : null, fontWeight: isDestructive ? FontWeight.bold : null)),
      onTap: onTap,
    );
  }

  void _removeItem(GroceryItem item) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Move "${item.name}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      // Soft delete from database
      await _repository.softDeleteGroceryItem(item.id);

      // Remove from UI
      setState(() {
        _items.removeWhere((i) => i.id == item.id);
      });
      _updateGroupedItems();

      // Trigger trash refresh
      Get.find<NavigationController>().triggerTrashRefresh();

      Get.snackbar(
        'Item Removed',
        '${item.name} moved to trash',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _showRenameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: _renameController,
          decoration: const InputDecoration(hintText: 'Enter new list name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _renameController.text.trim();
              if (newName.isEmpty) {
                Get.snackbar(
                  'Error',
                  'List name cannot be empty',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Check for duplicates
              final allLists = await _repository.getAllShoppingLists();
              final isDuplicate = allLists.any(
                (list) =>
                    list.name.toLowerCase() == newName.toLowerCase() &&
                    list.id != widget.listId,
              );
              if (isDuplicate) {
                Get.snackbar(
                  'Error',
                  'A list with this name already exists',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Update the list
              final currentList =
                  widget.list ??
                  await _repository.getShoppingList(widget.listId);
              if (currentList != null) {
                final updatedList = currentList.copyWith(
                  name: newName,
                  lastModified: DateTime.now(),
                );
                await _repository.updateShoppingList(updatedList);

                // Update UI
                setState(() {
                  _listName = newName;
                });

                // Update navigation controller
                final navController = Get.find<NavigationController>();
                navController.setCurrentList(updatedList);

                Get.snackbar(
                  'Success',
                  'List renamed successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }

              if (context.mounted) {
                Navigator.pop(context, newName);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Update the controller text
      _renameController.text = result;
    }
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedItemIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
  }

  void _shareSelectedItems() async {
    final selectedItems = _items.where((item) => _selectedItemIds.contains(item.id)).toList();
    if (selectedItems.isEmpty) return;

    await ShareService.shareMultipleItems(selectedItems, _listName);
  }
  @override
  void dispose() {
    _refreshWorker?.dispose();
    super.dispose();
  }
}
