import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:grocerylist/controllers/navigation_controller.dart';
import 'package:grocerylist/core/services/permission_service.dart';
import 'package:grocerylist/core/services/share_service.dart';
import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';
import 'package:grocerylist/core/services/ad_service.dart';
import 'package:grocerylist/data/repositories/grocery_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = GroceryRepository();
  List<ShoppingList> _lists = [];
  bool _isLoading = true;
  Worker? _worker;
  ShoppingList? _lastDeleted;

  @override
  void initState() {
    super.initState();
    _loadLists();
    _worker = ever(
      Get.find<NavigationController>().refreshData,
      (_) => _loadLists(),
    );
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PermissionService.checkAndShowPermissions(context);
      });
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);
    try {
      _lists = await _repo.getAllShoppingLists();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading ? _shimmer() : (_lists.isEmpty ? _empty() : _listView()),
            Positioned(
              bottom: 24,
              right: 20,
              child: _Fab(onTap: () => _createDialog(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: 56,
                    color: cs.primary,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .shake(delay: 700.ms, hz: 2, rotation: 0.02),
            const SizedBox(height: 28),
            Text(
              'No lists yet',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 10),
            Text(
              'Create your first shopping list\nand stay organised.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
            const SizedBox(height: 36),
            GestureDetector(
                  onTap: () => _createDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create List',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return RefreshIndicator(
      onRefresh: _loadLists,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        itemCount: _lists.length,
        itemBuilder: (_, i) => _ListCard(
          list: _lists[i],
          index: i,
          onTap: () {
            HapticFeedback.lightImpact();
            Get.find<NavigationController>().setCurrentList(_lists[i]);
            Get.toNamed('/list/${_lists[i].id}', arguments: _lists[i]);
          },
          onRename: () => _renameDialog(_lists[i]),
          onShare: () async {
            final items = await _repo.getGroceryItems(_lists[i].id);
            ShareService.shareList(_lists[i], items);
          },
          onDelete: () => _deleteList(_lists[i].id),
        ),
      ),
    );
  }

  Widget _shimmer() {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: 6,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        highlightColor: cs.surface,
        child: Container(
          height: 86,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _createDialog(BuildContext context) {
    final ctrl = TextEditingController();
    _showNameSheet(
      title: 'New List',
      hint: 'e.g., Weekly Groceries',
      icon: Icons.shopping_basket_rounded,
      confirmLabel: 'Create List',
      controller: ctrl,
      onConfirm: () async {
        if (ctrl.text.trim().isNotEmpty) await _createList(ctrl.text.trim());
      },
    );
  }

  void _renameDialog(ShoppingList list) {
    final ctrl = TextEditingController(text: list.name);
    _showNameSheet(
      title: 'Rename List',
      hint: 'New name',
      icon: Icons.edit_rounded,
      confirmLabel: 'Save',
      controller: ctrl,
      onConfirm: () async {
        final name = ctrl.text.trim();
        if (name.isEmpty) return;
        final all = await _repo.getAllShoppingLists();
        if (all.any(
          (l) => l.name.toLowerCase() == name.toLowerCase() && l.id != list.id,
        )) {
          SnackbarService.showWarning(
            'Oops',
            'A list with that name already exists',
          );
          return;
        }
        await _repo.updateShoppingList(
          list.copyWith(name: name, lastModified: DateTime.now()),
        );
        _loadLists();
      },
    );
  }

  void _showNameSheet({
    required String title,
    required String hint,
    required IconData icon,
    required String confirmLabel,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      // KEY FIX: isScrollControlled=true allows sheet to resize with keyboard
      isScrollControlled: true,
      // KEY FIX: useSafeArea=true prevents system UI overlap
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        // KEY FIX: use AnimatedPadding inside the sheet so it reacts to keyboard
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          // KEY FIX: viewInsets from sheetCtx — gets actual keyboard height
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, child) => Transform.translate(
              offset: Offset(0, 30 * (1 - val)),
              child: Opacity(opacity: val, child: child),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2338) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon + Title row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: cs.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Text field
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: Icon(
                        Icons.drive_file_rename_outline_rounded,
                        size: 20,
                        color: cs.primary,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : cs.primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (controller.text.trim().isEmpty) return;
                      HapticFeedback.mediumImpact();
                      onConfirm();
                      Navigator.of(sheetCtx).pop();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: cs.onSurface.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.text.trim().isEmpty) return;
                            HapticFeedback.mediumImpact();
                            onConfirm();
                            Navigator.of(sheetCtx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                confirmLabel,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createList(String name) async {
    final list = ShoppingList(
      id: const Uuid().v4(),
      name: name,
      createdDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    try {
      AdService().showInterstitialAd(
        onComplete: () async {
          await _repo.addShoppingList(list);
          await _loadLists();
          SnackbarService.showSimple('"$name" created');
        },
      );
    } catch (e) {
      debugPrint('📢 Interstitial Ad show exception: $e');
      await _repo.addShoppingList(list);
      await _loadLists();
      SnackbarService.showSimple('"$name" created');
    }
  }

  void _deleteList(String id) async {
    _lastDeleted = _lists.cast<ShoppingList?>().firstWhere((l) => l!.id == id, orElse: () => null);
    if (_lastDeleted == null) return;
    
    try {
      AdService().showInterstitialAd(
        onComplete: () async {
          await _repo.softDeleteShoppingList(id);
          await _loadLists();
          Get.find<NavigationController>().triggerTrashRefresh();
          _showDeleteSnackbar();
        },
      );
    } catch (e) {
      debugPrint('📢 Interstitial Ad show exception: $e');
      await _repo.softDeleteShoppingList(id);
      await _loadLists();
      Get.find<NavigationController>().triggerTrashRefresh();
      _showDeleteSnackbar();
    }
  }

  void _showDeleteSnackbar() {
    if (_lastDeleted == null) return;
    Get.snackbar(
      'Deleted',
      '"${_lastDeleted!.name}" moved to trash',
      backgroundColor: const Color(0xFFFF9800),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      duration: const Duration(milliseconds: 800),
      mainButton: TextButton(
        onPressed: _undoDelete,
        child: const Text(
          'UNDO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    Future.delayed(
      const Duration(milliseconds: 900),
      () => _lastDeleted = null,
    );
  }

  Future<void> _undoDelete() async {
    if (_lastDeleted == null) return;
    await _repo.restoreShoppingList(_lastDeleted!.id);
    await _loadLists();
    Get.find<NavigationController>().triggerTrashRefresh();
    SnackbarService.showSuccess('Restored', '"${_lastDeleted!.name}" is back');
    _lastDeleted = null;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// List Card
// ──────────────────────────────────────────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final ShoppingList list;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _ListCard({
    required this.list,
    required this.index,
    required this.onTap,
    required this.onRename,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completed = list.totalItems > 0
        ? (list.checkedItems / list.totalItems).clamp(0.0, 1.0)
        : 0.0;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.07),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: cs.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Tag(
                                label: '${list.totalItems} items',
                                icon: Icons.inventory_2_outlined,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 10),
                              _Tag(
                                label: _timeAgo(list.lastModified),
                                icon: Icons.access_time_rounded,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                          if (list.totalItems > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completed,
                                minHeight: 3,
                                backgroundColor: cs.primary.withValues(
                                  alpha: 0.12,
                                ),
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (v) {
                        if (v == 'rename') onRename();
                        if (v == 'share') onShare();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        _popup('rename', Icons.edit_rounded, 'Rename', cs),
                        _popup('share', Icons.share_rounded, 'Share', cs),
                        const PopupMenuDivider(height: 1),
                        _popup(
                          'delete',
                          Icons.delete_outline_rounded,
                          'Delete',
                          cs,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 40),
          duration: 500.ms,
        )
        .slideX(begin: 0.15, curve: Curves.easeOutQuart);
  }

  PopupMenuItem<String> _popup(
    String value,
    IconData icon,
    String label,
    ColorScheme cs, {
    Color? color,
  }) => PopupMenuItem(
    value: value,
    height: 42,
    child: Row(
      children: [
        Icon(icon, size: 18, color: color ?? cs.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    ),
  );

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Tag({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: color)),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FAB
// ──────────────────────────────────────────────────────────────────────────────
class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'New List',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      delay: 300.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
