import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grocerylist/controllers/navigation_controller.dart';
import 'package:grocerylist/core/themes/app_theme.dart';
import 'package:grocerylist/core/services/share_service.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';
import 'package:grocerylist/core/services/ad_service.dart';
import 'package:grocerylist/presentation/widgets/ad_banner.dart';
import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/data/repositories/grocery_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isLoading = true;
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
    if (widget.list != null) {
      _listName = widget.list!.name;
      Get.find<NavigationController>().setCurrentList(widget.list!);
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
      setState(() => _isLoading = true);
      final items = await _repository.getGroceryItems(widget.listId);
      setState(() {
        _items.clear();
        _items.addAll(items);
        _isLoading = false;
      });
      _updateGroupedItems();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<GroceryItem>> _cachedGroupedItems = {};

  void _updateGroupedItems() {
    Map<String, List<GroceryItem>> grouped = {};
    for (var item in _items) {
      if (item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        grouped.putIfAbsent(item.category, () => []).add(item);
      }
    }
    setState(() => _cachedGroupedItems = grouped);
  }

  int get _checkedCount => _items.where((i) => i.isChecked).length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        Get.find<NavigationController>().clearCurrentList();
        try {
          AdService().showInterstitialAd(
            onComplete: () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        } catch (e) {
          debugPrint('📢 Interstitial Ad show exception: $e');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _isSelectionMode ? _selectionAppBar() : _normalAppBar(),
        body: Column(
          children: [
            _buildCounter(),
            _buildSearch(),
            Expanded(
              child: _isLoading
                  ? _shimmer()
                  : _items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: _cachedGroupedItems.length,
                      itemBuilder: (_, i) {
                        final cat = _cachedGroupedItems.keys.elementAt(i);
                        return _buildCategory(
                          cat,
                          _cachedGroupedItems[cat]!,
                          i,
                        );
                      },
                    ),
            ),
            const AdBanner(),
          ],
        ),
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _goToAddItem();
                },
                label: Text(
                  'Add Item',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Icons.add_rounded),
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  // ── Counter ───────────────────────────────────────────────────
  Widget _buildCounter() {
    final cs = Theme.of(context).colorScheme;
    final total = _items.length;
    final checked = _checkedCount;
    final progress = total == 0 ? 0.0 : checked / total;
    final pct = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          // Circular mini progress
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.5,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$pct%',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$checked of $total items done',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Done badge when all complete
          if (total > 0 && checked == total)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Done!',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.08);
  }

  // ── Search ────────────────────────────────────────────────────
  Widget _buildSearch() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          _searchQuery = v;
          _updateGroupedItems();
        },
        style: GoogleFonts.outfit(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _updateGroupedItems();
                  },
                )
              : null,
          hintText: 'Search items...',
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _emptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_shopping_cart_rounded,
              size: 44,
              color: cs.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            'List is empty',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first item',
            style: GoogleFonts.outfit(fontSize: 13, color: cs.onSurfaceVariant),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────
  Widget _shimmer() {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 6,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        highlightColor: cs.surface,
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Category section ──────────────────────────────────────────
  Widget _buildCategory(String cat, List<GroceryItem> items, int idx) {
    final color =
        AppTheme.categoryColors[cat] ?? AppTheme.categoryColors['Other']!;
    final cs = Theme.of(context).colorScheme;

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    color: cs.outlineVariant.withValues(alpha: 0.25),
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((item) => _buildItemTile(item, color)),
          ],
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: idx * 40),
          duration: 500.ms,
        )
        .slideX(begin: 0.08, curve: Curves.easeOutQuart);
  }

  // ── Item tile ─────────────────────────────────────────────────
  Widget _buildItemTile(GroceryItem item, Color catColor) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedItemIds.contains(item.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withValues(alpha: 0.1)
            : item.isChecked
            ? cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.5)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.5)
              : item.isChecked
              ? Colors.transparent
              : isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSelectionMode
              ? () => _toggleSelection(item.id)
              : () => _toggleItemChecked(item),
          onLongPress: _isSelectionMode
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  _enterSelectionMode();
                  _toggleSelection(item.id);
                },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Row(
              children: [
                _buildCheckbox(item, catColor),
                const SizedBox(width: 8),
                if (item.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: cs.onSurfaceVariant,
                          color: item.isChecked
                              ? cs.onSurfaceVariant
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        ),
                      ),
                      if (item.notes.isNotEmpty)
                        Text(
                          item.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Qty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.isChecked
                        ? Colors.transparent
                        : catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.quantity} ${item.unit}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.isChecked ? cs.onSurfaceVariant : catColor,
                    ),
                  ),
                ),
                if (!_isSelectionMode)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () => _showItemActions(item),
                    ),
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
        onChanged: (_) => _toggleSelection(item.id),
        activeColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      );
    }
    return SizedBox(
      width: 32,
      height: 32,
      child: Checkbox(
        value: item.isChecked,
        onChanged: (_) => _toggleItemChecked(item),
        activeColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // ── AppBars ───────────────────────────────────────────────────
  PreferredSizeWidget _normalAppBar() {
    return AppBar(
      title: Text(
        _listName,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (v) {
            if (v == 'rename') _showRenameDialog();
            if (v == 'delete_all') _deleteAllItems();
            if (v.startsWith('copy_')) _handleEnhancedCopy(v);
          },
          itemBuilder: (_) => [
            _popItem('rename', Icons.edit_rounded, 'Rename List'),
            const PopupMenuDivider(height: 1),
            _popItem(
              'copy_unpurchased',
              Icons.copy_rounded,
              'Copy Unpurchased',
            ),
            _popItem('copy_purchased', Icons.rule_rounded, 'Copy Purchased'),
            _popItem('copy_all', Icons.content_paste_rounded, 'Copy All'),
            const PopupMenuDivider(height: 1),
            _popItem(
              'delete_all',
              Icons.delete_sweep_rounded,
              'Delete All',
              red: true,
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _selectionAppBar() {
    return AppBar(
      title: Text(
        '${_selectedItemIds.length} Selected',
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: _exitSelectionMode,
      ),
      actions: [
        if (_selectedItemIds.isNotEmpty) ...[
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareSelectedItems,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _deleteSelectedItems,
          ),
        ],
      ],
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  PopupMenuItem<String> _popItem(
    String val,
    IconData icon,
    String label, {
    bool red = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuItem(
      value: val,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 18, color: red ? Colors.redAccent : cs.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: red ? Colors.redAccent : null,
              fontWeight: red ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Item actions bottom sheet ─────────────────────────────────
  void _showItemActions(GroceryItem item) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C2338) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.name,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _sheetAction(Icons.edit_rounded, 'Edit Item', cs.primary, () {
              Navigator.pop(context);
              _editItem(item);
            }),
            const SizedBox(height: 8),
            _sheetAction(Icons.share_rounded, 'Share Item', cs.primary, () {
              Navigator.pop(context);
              ShareService.shareItem(item, _listName);
            }),
            const SizedBox(height: 8),
            _sheetAction(
              Icons.delete_outline_rounded,
              'Delete Item',
              Colors.redAccent,
              () {
                Navigator.pop(context);
                _removeItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── All the logic methods (unchanged) ─────────────────────────

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
    final old = item.isChecked;
    final next = !old;
    if (next) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    setState(() => item.isChecked = next);
    try {
      await _repository.updateGroceryItem(item.copyWith(isChecked: next));
      _updateGroupedItems();
      Get.find<NavigationController>().triggerDataRefresh();
    } catch (e) {
      setState(() => item.isChecked = old);
      SnackbarService.showError('Error', 'Failed to update: $e');
    }
  }

  void _editItem(GroceryItem item) async {
    final result = await Get.toNamed(
      '/add-item/${widget.listId}',
      arguments: item,
    );
    if (result is Map<String, dynamic>) {
      try {
        final updated = item.copyWith(
          name: result['name'],
          category: result['category'],
          quantity: (result['quantity'] as num).toInt(),
          unit: result['unit'],
          notes: result['notes'] ?? '',
          imageUrl: result['image_url'],
          storeAisle: result['store_aisle'] ?? 'Other',
        );
        await _repository.updateGroceryItem(updated);
        final i = _items.indexWhere((x) => x.id == item.id);
        if (i >= 0) setState(() => _items[i] = updated);
        _updateGroupedItems();
        Get.find<NavigationController>().triggerDataRefresh();
        SnackbarService.showSimple('"${result['name']}" updated');
      } catch (e) {
        SnackbarService.showError('Error', 'Failed to update: $e');
      }
    }
  }

  Future<void> _goToAddItem() async {
    await Get.toNamed('/add-item/${widget.listId}');
    _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Remove Item',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Move "${item.name}" to trash?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Remove', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repository.softDeleteGroceryItem(item.id);
      setState(() => _items.removeWhere((i) => i.id == item.id));
      _updateGroupedItems();
      Get.find<NavigationController>().triggerTrashRefresh();
      SnackbarService.showWarning('Removed', '"${item.name}" moved to trash');
    }
  }

  void _deleteSelectedItems() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Items',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete ${_selectedItemIds.length} items?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Delete', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
    if (ok == true) {
      for (final id in _selectedItemIds) {
        await _repository.softDeleteGroceryItem(id);
      }
      setState(() {
        _items.removeWhere((i) => _selectedItemIds.contains(i.id));
        _selectedItemIds.clear();
        _isSelectionMode = false;
      });
      _updateGroupedItems();
      Get.find<NavigationController>().triggerTrashRefresh();
      SnackbarService.showWarning('Deleted', 'Items moved to trash');
    }
  }

  void _deleteAllItems() async {
    if (_items.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete All',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text('Move all items to trash?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Delete All', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
    if (ok == true) {
      for (final item in _items) {
        await _repository.softDeleteGroceryItem(item.id);
      }
      setState(() => _items.clear());
      _updateGroupedItems();
      Get.find<NavigationController>().triggerTrashRefresh();
      SnackbarService.showWarning('Done', 'All items moved to trash');
    }
  }

  void _handleEnhancedCopy(String type) async {
    String content = '🛒 $_listName\n\n';
    List<GroceryItem> filtered;
    if (type == 'copy_unpurchased') {
      filtered = _items.where((i) => !i.isChecked).toList();
      content += '-- 📝 UNPURCHASED --\n';
    } else if (type == 'copy_purchased') {
      filtered = _items.where((i) => i.isChecked).toList();
      content += '-- ✅ PURCHASED --\n';
    } else {
      filtered = _items;
      content += '-- 📦 ALL ITEMS --\n';
    }
    if (filtered.isEmpty) {
      SnackbarService.showWarning('Empty', 'No items match');
      return;
    }
    for (final item in filtered) {
      content +=
          '• [${item.isChecked ? 'DONE' : 'PENDING'}] ${item.name} (${item.quantity} ${item.unit})\n';
    }
    content += '\nGenerated by SmartCart - AI Shopping List';
    await ShareService.copyToClipboard(content);
    SnackbarService.showInfo('Copied!', 'List copied to clipboard');
  }

  void _showRenameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Rename List',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: _renameController,
          autofocus: true,
          style: GoogleFonts.outfit(),
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _renameController.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(context);
              final all = await _repository.getAllShoppingLists();
              if (all.any(
                (l) =>
                    l.name.toLowerCase() == name.toLowerCase() &&
                    l.id != widget.listId,
              )) {
                SnackbarService.showError('Error', 'Name already in use');
                return;
              }
              final cur =
                  widget.list ??
                  await _repository.getShoppingList(widget.listId);
              if (cur != null) {
                final updated = cur.copyWith(
                  name: name,
                  lastModified: DateTime.now(),
                );
                await _repository.updateShoppingList(updated);
                setState(() => _listName = name);
                Get.find<NavigationController>().setCurrentList(updated);
                SnackbarService.showSimple('"$name" renamed');
              }
              nav.pop(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Save', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
    if (result != null) _renameController.text = result;
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
    final sel = _items.where((i) => _selectedItemIds.contains(i.id)).toList();
    if (sel.isEmpty) return;
    await ShareService.shareMultipleItems(sel, _listName);
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    _searchController.dispose();
    _renameController.dispose();
    super.dispose();
  }
}

