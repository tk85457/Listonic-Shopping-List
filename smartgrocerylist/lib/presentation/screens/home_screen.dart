import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/controllers/navigation_controller.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';
import 'package:smartgrocerylist/core/themes/app_theme.dart';
import 'package:smartgrocerylist/core/services/share_service.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:smartgrocerylist/data/repositories/grocery_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GroceryRepository _repository = GroceryRepository();

  List<ShoppingList> _lists = [];
  Worker? _refreshWorker;
  ShoppingList? _lastDeletedList; // Track for undo

  @override
  void initState() {
    super.initState();
    _checkAndShowPermissions();
    _loadLists();

    _refreshWorker = ever(
      Get.find<NavigationController>().refreshData,
      (_) => _loadLists(),
    );
  }

  Future<void> _loadLists() async {
    try {
      _lists = await _repository.getAllShoppingLists();
      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load shopping lists',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedPermissions =
        prefs.getBool('permissions_requested') ?? false;

    if (!kIsWeb && !hasRequestedPermissions) {
      // Wait a bit for the screen to load, then show step-by-step permissions
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _showStepByStepPermissions();
      }
    }
  }

  Future<void> _showStepByStepPermissions() async {
    final permissions = [
      Permission.microphone,
      if (!kIsWeb) Permission.photos,
      Permission.notification,
    ];

    for (var permission in permissions) {
      if (!(await permission.status.isGranted)) {
        String title = '';
        String desc = '';

        if (permission == Permission.microphone) {
          title = 'Microphone Permission';
          desc = 'Allow microphone access for voice input features.';
        } else if (permission == Permission.photos) {
          title = 'Gallery Permission';
          desc = 'Allow gallery access to select photos for items.';
        } else if (permission == Permission.notification) {
          title = 'Notification Permission';
          desc = 'Allow notifications for reminders and smart alerts.';
        }

        await _showPermissionDialog(title, desc, permission);
      }
    }

    // Save that we've requested permissions
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', true);
  }

  Future<void> _showPermissionDialog(
    String title,
    String description,
    Permission permission,
  ) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(description),
            const SizedBox(height: 16),
            const Text(
              'You can change this later in app settings.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final status = await permission.request();
              if (!context.mounted) return;
              Navigator.of(context).pop();

              if (status.isGranted) {
                Get.snackbar(
                  'Permission Granted',
                  '$title access granted successfully!',
                  backgroundColor: AppTheme.primaryGreen,
                  colorText: Colors.white,
                  duration: const Duration(milliseconds: 500),
                );
              } else if (status.isPermanentlyDenied) {
                Get.snackbar(
                  'Permission Denied',
                  'Please enable $title in app settings to use this feature.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1),
                );
              }
            },
            child: const Text('Allow'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestNudge() {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((p) => p.getBool('isGuest') ?? false),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guest Mode (${_lists.length}/3 lists)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade900),
                        ),
                        Text(
                          'Sign in to sync your lists to the cloud.',
                          style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/signin'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Sign In', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: -1, duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Navigation is handled by MainNavigationScreen
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildGuestNudge(),
            _lists.isEmpty ? _buildEmptyState() : _buildListsGrid(),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateListDialog(context),
                label: Text(
                  'New List',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Icons.add_rounded),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
              ).animate().scale(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack).shake(delay: const Duration(milliseconds: 600)),
            const SizedBox(height: 32),
            Text(
              'No lists yet',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              'Create your first shopping list and start organized shopping today!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.2),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _showCreateListDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), // Darker shade
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildListsGrid() {
    return RefreshIndicator(
      onRefresh: _loadLists,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final list = _lists[index];
          return _buildListCard(list, context, index);
        },
      ),
    );
  }

  Widget _buildListCard(ShoppingList list, BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final navController = Get.find<NavigationController>();
            navController.setCurrentList(list);
            Get.toNamed('/list/${list.id}', arguments: list);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${list.totalItems} items',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(list.lastModified),
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (list.sharedWith.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.group_rounded, size: 16, color: colorScheme.secondary),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onSelected: (value) async {
                    if (value == 'rename') {
                      _renameList(list);
                    } else if (value == 'share') {
                      final items = await _repository.getGroceryItems(list.id);
                      await ShareService.shareList(list, items);
                    } else if (value == 'invite') {
                      _showInviteDialog(list);
                    } else if (value == 'sync') {
                      final auth = Get.find<AuthController>();
                      if (auth.isPremium.value) {
                        Get.snackbar('Syncing', 'Syncing "${list.name}" to cloud...', showProgressIndicator: true);
                        await _repository.updateShoppingList(list); // Triggers sync inside repo
                        final items = await _repository.getGroceryItems(list.id);
                        for (var item in items) await _repository.updateGroceryItem(item);
                        Get.back(); // Close snackbar if it's still there
                        Get.snackbar('Success', 'List synced successfully!', backgroundColor: Colors.green.shade100);
                      } else {
                        Get.snackbar(
                          'Premium Feature',
                          'First purchase premium then work this option',
                          backgroundColor: Colors.orange.shade100,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } else if (value == 'delete') {
                      _deleteList(list.id);
                    }
                  },
                  itemBuilder: (context) => [
                    _buildPopupItem('rename', Icons.edit_rounded, 'Rename'),
                    _buildPopupItem('share', Icons.share_rounded, 'Share Text'),
                    _buildPopupItem('invite', Icons.person_add_rounded, 'Invite Collaborator'),
                    _buildPopupItem('sync', Icons.cloud_upload_outlined, 'Sync to Cloud'),
                    const PopupMenuDivider(),
                    _buildPopupItem('delete', Icons.delete_outline_rounded, 'Delete', isDestructive: true),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100), duration: const Duration(milliseconds: 500)).slideX(begin: 0.1);
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? Colors.red : null,
              fontWeight: isDestructive ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  void _showCreateListDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Create New List', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'List name',
            hintText: 'e.g., Weekly Groceries',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createList(nameController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createList(String name) async {
    try {
      // Check authentication status
      final authController = Get.find<AuthController>();
      final isAuthenticated = await authController.isLoggedIn();

      // Check if user is guest
      // Check if user is guest or free
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('isGuest') ?? false;
      final isPremium = authController.isPremium.value;

      // Free user / Guest user limit: 3 lists maximum
      if (!isPremium && _lists.length >= 3) {
        Get.toNamed('/premium');
        Get.snackbar(
          'Limit Reached',
          'Free users can create up to 3 lists. Go Premium for unlimited lists!',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.black87,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // For authenticated users or guest users under limit
      final newList = ShoppingList(
        id: const Uuid().v4(),
        name: name,
        createdDate: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await _repository.addShoppingList(newList);
      await _loadLists();

      // Show success message with different text for guest users
      String successMessage = 'List "$name" created';
      if (isGuest) {
        successMessage += ' (${_lists.length}/3 lists)';
      }

      Get.snackbar(
        'Success',
        successMessage,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      String errorMessage = 'Failed to create list';
      Get.snackbar(
        'Error',
        '$errorMessage: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _renameList(ShoppingList list) async {
    final TextEditingController renameController = TextEditingController(
      text: list.name,
    );

    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Rename List', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: renameController,
          decoration: InputDecoration(
            hintText: 'Enter new list name',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = renameController.text.trim();
              if (newName.isEmpty) {
                Get.snackbar('Error', 'List name cannot be empty', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              final allLists = await _repository.getAllShoppingLists();
              final isDuplicate = allLists.any((l) => l.name.toLowerCase() == newName.toLowerCase() && l.id != list.id);
              if (isDuplicate) {
                Get.snackbar('Error', 'A list with this name already exists', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              final updatedList = list.copyWith(name: newName, lastModified: DateTime.now());
              await _repository.updateShoppingList(updatedList);
              await _loadLists();

              if (context.mounted) Navigator.pop(context, newName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteList(String id) async {
    final listToDelete = _lists.firstWhere((list) => list.id == id);
    // Item deletion is handled by the repository

    // Store for undo
    _lastDeletedList = listToDelete;

    await _repository.softDeleteShoppingList(listToDelete.id);
    await _loadLists();

    Get.find<NavigationController>().triggerTrashRefresh();

    Get.snackbar(
      'List Deleted',
      '${listToDelete.name} moved to trash',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4), // Give time to undo
      mainButton: TextButton(
        onPressed: () async {
          await _restoreDeletedList();
        },
        child: const Text('Undo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    // Clear the reference after snackbar duration
    Future.delayed(const Duration(seconds: 5), () {
      _lastDeletedList = null;
    });
  }

  Future<void> _restoreDeletedList() async {
    if (_lastDeletedList == null) return;

    try {
      await _repository.restoreShoppingList(_lastDeletedList!.id);
      await _loadLists();
      Get.find<NavigationController>().triggerTrashRefresh();

      Get.snackbar(
        'List Restored',
        '${_lastDeletedList!.name} has been restored',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      _lastDeletedList = null; // Clear after restore
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to restore list: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showInviteDialog(ShoppingList list) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Invite Collaborator', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email of the person you want to collaborate with on this list.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'user@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && GetUtils.isEmail(email)) {
                try {
                  await _repository.inviteCollaborator(list.id, email);
                  Navigator.pop(context);
                  Get.snackbar('Success', 'Invitation sent to $email', backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar('Error', 'Failed to send invitation: $e', backgroundColor: Colors.red, colorText: Colors.white);
                }
              } else {
                Get.snackbar('Error', 'Please enter a valid email address', backgroundColor: Colors.orange, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}


class ListSearchDelegate extends SearchDelegate {
  final List<ShoppingList> lists;

  ListSearchDelegate(this.lists);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final results = lists
        .where((list) => list.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: Text(results[index].name),
        subtitle: Text('${results[index].totalItems} items'),
        onTap: () {
          close(context, results[index]);
          navController.setCurrentList(results[index]);
          Get.toNamed('/list/${results[index].id}');
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final suggestions = lists
        .where((list) => list.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: Text(suggestions[index].name),
        subtitle: Text('${suggestions[index].totalItems} items'),
        onTap: () {
          close(context, suggestions[index]);
          navController.setCurrentList(suggestions[index]);
          Get.toNamed('/list/${suggestions[index].id}');
        },
      ),
    );
  }
}
