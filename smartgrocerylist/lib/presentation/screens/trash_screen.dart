import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grocerylist/controllers/navigation_controller.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';
import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/data/repositories/grocery_repository.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _repo = GroceryRepository();
  List<ShoppingList> _activeLists = [];
  List<TrashItem> _items = [];
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _load();
    _worker = ever(Get.find<NavigationController>().refreshTrash, (_) => _load());
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final lists = await _repo.getTrashedShoppingLists();
    final groceries = await _repo.getAllTrashedGroceryItems();
    final active = await _repo.getAllShoppingLists();

    final nameMap = {
      for (var l in active) l.id: l.name,
      for (var l in lists) l.id: l.name,
    };

    final combined = <TrashItem>[];
    for (final l in lists) {
      combined.add(TrashItem(
        id: l.id,
        name: l.name,
        listName: 'Your Lists',
        deletedAt: l.deletedAt ?? l.lastModified,
        type: 'list',
        originalData: l.toMap(),
      ));
    }
    for (final g in groceries) {
      combined.add(TrashItem(
        id: g.id,
        name: g.name,
        listName: nameMap[g.listId] ?? 'Unknown List',
        deletedAt: g.deletedAt ?? g.addedDate,
        type: 'item',
        originalData: g.toMap(),
      ));
    }
    combined.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

    if (mounted) {
      setState(() {
        _activeLists = active;
        _items = combined;
      });
    }
  }

  Future<void> _restore(TrashItem item) async {
    if (item.type == 'item') {
      final listId = item.originalData?['list_id'] ?? item.originalData?['listId'];
      if (listId != null && !_activeLists.any((l) => l.id == listId)) {
        SnackbarService.showWarning(
          'Cannot Restore',
          'Restore the parent list first',
        );
        return;
      }
      await _repo.restoreGroceryItem(item.id);
    } else {
      await _repo.restoreShoppingList(item.id);
    }
    await _load();
    Get.find<NavigationController>().triggerTrashRefresh();
    SnackbarService.showSuccess('Restored', '"${item.name}" is back');
  }

  Future<void> _deletePerm(TrashItem item) async {
    if (item.type == 'list') {
      await _repo.deleteShoppingList(item.id);
    } else {
      await _repo.deleteGroceryItem(item.id);
    }
    await _load();
    SnackbarService.showError('Deleted', '"${item.name}" permanently deleted');
  }

  void _confirmEmptyTrash() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Empty Trash?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'All items will be permanently deleted. This cannot be undone.',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _repo.emptyTrash();
              _load();
              SnackbarService.showInfo('Trash Emptied', 'All items permanently deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Empty All', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trash',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _confirmEmptyTrash,
              child: Text('Empty',
                  style: GoogleFonts.outfit(
                      color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _items.isEmpty ? _empty(cs) : _list(cs),
    );
  }

  Widget _empty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_sweep_rounded, size: 48, color: Colors.grey),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text('Trash is empty',
              style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 6),
          Text('Deleted items appear here for 30 days.',
              style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  Widget _list(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return _TrashTile(
          item: item,
          onRestore: () => _restore(item),
          onDelete: () => _deletePerm(item),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 30)).slideX(begin: 0.1);
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
class _TrashTile extends StatelessWidget {
  final TrashItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  const _TrashTile({required this.item, required this.onRestore, required this.onDelete});

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    return '${d.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isList = item.type == 'list';
    final tileColor = isList ? Colors.blueAccent : Colors.deepOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tileColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isList ? Icons.list_alt_rounded : Icons.shopping_basket_rounded,
            color: tileColor,
            size: 22,
          ),
        ),
        title: Text(item.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${item.listName}',
                style: GoogleFonts.outfit(fontSize: 12, color: cs.onSurfaceVariant)),
            Text('Deleted ${_ago(item.deletedAt)}',
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
          ],
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (v) => v == 'res' ? onRestore() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'res',
              height: 42,
              child: Row(children: [
                Icon(Icons.restore_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 10),
                Text('Restore', style: GoogleFonts.outfit(fontSize: 14)),
              ]),
            ),
            PopupMenuItem(
              value: 'del',
              height: 42,
              child: Row(children: [
                const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text('Delete Forever',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.redAccent)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

