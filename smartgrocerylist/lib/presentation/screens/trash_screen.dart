import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartgrocerylist/controllers/navigation_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:smartgrocerylist/data/repositories/grocery_repository.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final GroceryRepository _repository = GroceryRepository();
  List<ShoppingList> _activeLists = [];
  List<TrashItem> _cachedTrashItems = [];
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _loadTrashedItems();
    _refreshWorker = ever(
      Get.find<NavigationController>().refreshTrash,
      (_) => _loadTrashedItems(),
    );
  }

  Future<void> _loadTrashedItems() async {
    final trashedLists = await _repository.getTrashedShoppingLists();
    final trashedItems = await _repository.getAllTrashedGroceryItems();
    final activeLists = await _repository.getAllShoppingLists();

    setState(() {
      _activeLists = activeLists;
      _updateElements(trashedLists, trashedItems);
    });
  }

  void _updateElements(List<ShoppingList> trashedLists, List<GroceryItem> trashedItems) {
    final List<TrashItem> items = [];

    // Create map for easy list name lookup
    final Map<String, String> listNames = {
      for (var l in _activeLists) l.id: l.name,
      for (var l in trashedLists) l.id: l.name,
    };

    for (var list in trashedLists) {
      items.add(TrashItem(
        id: list.id,
        name: list.name,
        listName: 'Your Lists',
        deletedAt: list.deletedAt ?? list.lastModified,
        type: 'list',
        originalData: list.toMap(),
      ));
    }
    for (var item in trashedItems) {
      items.add(TrashItem(
        id: item.id,
        name: item.name,
        listName: listNames[item.listId] ?? 'Unknown List',
        deletedAt: item.deletedAt ?? item.addedDate,
        type: 'item',
        originalData: item.toMap(),
      ));
    }
    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    setState(() {
      _cachedTrashItems = items;
    });
  }

  Future<void> _restore(TrashItem item) async {
    try {
      if (item.type == 'item') {
        // Find listId from original data
        final String? listId = item.originalData?['list_id'] ?? item.originalData?['listId'];

        // Check if parent list is still active
        if (listId != null) {
          final parentIsActive = _activeLists.any((l) => l.id == listId);
          if (!parentIsActive) {
            Get.snackbar(
              'Cannot Restore',
              'Please restore the parent list first.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }
        await _repository.restoreGroceryItem(item.id);
      } else {
        await _repository.restoreShoppingList(item.id);
      }

      await _loadTrashedItems();

      // Trigger navigation refresh
      Get.find<NavigationController>().triggerTrashRefresh();

      Get.snackbar('Restored', '${item.name} is back!',
          backgroundColor: Theme.of(context).colorScheme.primary, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore: $e');
    }
  }

  Future<void> _deletePermanently(TrashItem item) async {
    try {
      if (item.type == 'list') {
        await _repository.deleteShoppingList(item.id);
      } else {
        await _repository.deleteGroceryItem(item.id);
      }
      await _loadTrashedItems();
      Get.snackbar('Deleted', '${item.name} removed permanently',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete');
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash Bin', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (_cachedTrashItems.isNotEmpty)
            TextButton(
              onPressed: _showEmptyConfirm,
              child: const Text('Empty', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _cachedTrashItems.isEmpty ? _buildEmptyState() : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_sweep_rounded, size: 80, color: Colors.grey),
          ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text('Nothing here', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Deleted items stay here for 30 days.'),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cachedTrashItems.length,
      itemBuilder: (ctx, idx) {
        final item = _cachedTrashItems[idx];
        return _buildTrashTile(item).animate().fadeIn(delay: Duration(milliseconds: idx * 50)).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildTrashTile(TrashItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (item.type == 'list' ? Colors.blue : Colors.orange).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.type == 'list' ? Icons.list_alt_rounded : Icons.shopping_basket_rounded,
            color: item.type == 'list' ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${item.listName}', style: const TextStyle(fontSize: 12)),
            Text('Deleted ${_timeAgo(item.deletedAt)}', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => v == 'res' ? _restore(item) : _deletePermanently(item),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'res', child: Row(children: [Icon(Icons.restore_rounded, size: 18), SizedBox(width: 8), Text('Restore')])),
            const PopupMenuItem(value: 'del', child: Row(children: [Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete FOREVER', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  void _showEmptyConfirm() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Empty Trash?'),
        content: const Text('This will permanently delete all items. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _repository.emptyTrash(); // Ensure this method exists or loop deletes
              _loadTrashedItems();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    super.dispose();
  }
}
