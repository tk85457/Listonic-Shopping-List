import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocerylist/data/models/models.dart';
import 'package:smartgrocerylist/core/services/supabase_service.dart';
import 'package:smartgrocerylist/core/services/local_storage_service.dart';

class GroceryRepository {
  // Handles both Cloud (Supabase) and Local (Guest) storage.

  Future<bool> _isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuest') ?? false;
  }

  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPremium = prefs.getBool('isPremium') ?? false;
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn && isPremium;
  }

  Future<void> syncAllData() async {
    if (!(await _shouldSync())) return;

    try {
      final lists = await LocalStorageService.getShoppingLists();
      for (var list in lists) {
        await SupabaseService.createShoppingList(list);
        final items = await LocalStorageService.getGroceryItems(list.id);
        for (var item in items) {
          await SupabaseService.createGroceryItem(item);
        }
      }

      final pantry = await LocalStorageService.getPantryItems();
      for (var item in pantry) {
        await SupabaseService.createPantryItem(item);
      }

      final recipes = await LocalStorageService.getRecipes();
      for (var recipe in recipes) {
        await SupabaseService.createRecipe(recipe);
      }

      print('Sync completed successfully');
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // --- Shopping List methods ---
  Future<List<ShoppingList>> getAllShoppingLists() async {
    // Merge local and cloud lists? For now, local is truth.
    // If premium, we could fetch from cloud and update local periodically.
    return await LocalStorageService.getShoppingLists();
  }

  Future<List<ShoppingList>> getTrashedShoppingLists() async {
    return await LocalStorageService.getTrashedShoppingLists();
  }

  Future<ShoppingList?> getShoppingList(String id) async {
    final lists = await LocalStorageService.getShoppingLists();
    try {
      return lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addShoppingList(ShoppingList list) async {
    // Always save local first
    await LocalStorageService.saveShoppingList(list);

    // Sync if premium
    if (await _shouldSync()) {
      try {
        await SupabaseService.createShoppingList(list);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> updateShoppingList(ShoppingList list) async {
    await LocalStorageService.saveShoppingList(list);

    if (await _shouldSync()) {
      try {
        await SupabaseService.updateShoppingList(list.id, list.toMap());
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> softDeleteShoppingList(String id) async {
    await LocalStorageService.softDeleteShoppingList(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.softDeleteShoppingList(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> restoreShoppingList(String id) async {
    await LocalStorageService.restoreShoppingList(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.restoreShoppingList(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> deleteShoppingList(String id) async {
    await LocalStorageService.deleteShoppingListPermanently(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.deleteShoppingList(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> inviteCollaborator(String listId, String email) async {
    if (await _shouldSync()) {
      await SupabaseService.inviteCollaborator(listId, email);
    }
  }

  // --- Grocery Items methods ---
  Future<List<GroceryItem>> getGroceryItems(String listId) async {
    return await LocalStorageService.getGroceryItems(listId);
  }

  Future<List<GroceryItem>> getTrashedGroceryItems(String listId) async {
    final all = await LocalStorageService.getAllTrashedGroceryItems();
    return all.where((i) => i.listId == listId).toList();
  }

  Future<List<GroceryItem>> getAllTrashedGroceryItems() async {
    return await LocalStorageService.getAllTrashedGroceryItems();
  }

  Future<void> addGroceryItem(GroceryItem item) async {
    await LocalStorageService.saveGroceryItem(item);

    if (await _shouldSync()) {
      try {
        await SupabaseService.createGroceryItem(item);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> updateGroceryItem(GroceryItem item) async {
    await LocalStorageService.saveGroceryItem(item);

    if (await _shouldSync()) {
      try {
        await SupabaseService.updateGroceryItem(item.id, item.toMap());
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> softDeleteGroceryItem(String id) async {
    await LocalStorageService.softDeleteGroceryItem(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.softDeleteGroceryItem(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> restoreGroceryItem(String id) async {
    await LocalStorageService.restoreGroceryItem(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.restoreGroceryItem(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> deleteGroceryItem(String id) async {
    await LocalStorageService.deleteGroceryItemPermanently(id);

    if (await _shouldSync()) {
      try {
        await SupabaseService.deleteGroceryItem(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  // --- Pantry Items methods ---
  Future<List<PantryItem>> getAllPantryItems() async {
    return await LocalStorageService.getPantryItems();
  }

  Future<void> addPantryItem(PantryItem item) async {
    await LocalStorageService.savePantryItem(item);
    if (await _shouldSync()) {
      try {
        await SupabaseService.createPantryItem(item);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> updatePantryItem(PantryItem item) async {
    await LocalStorageService.savePantryItem(item);
    if (await _shouldSync()) {
      try {
        await SupabaseService.updatePantryItem(item.id, item.toMap());
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<void> deletePantryItem(String id) async {
    await LocalStorageService.deletePantryItem(id);
    if (await _shouldSync()) {
      try {
        await SupabaseService.deletePantryItem(id);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  // --- Recipe methods ---
  Future<List<Recipe>> getAllRecipes() async {
    return await LocalStorageService.getRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await LocalStorageService.saveRecipe(recipe);
    if (await _shouldSync()) {
      try {
        await SupabaseService.createRecipe(recipe);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  // --- Purchase History methods ---
  Future<void> addToPurchaseHistory(PurchaseHistoryItem item) async {
    await LocalStorageService.savePurchaseHistoryItem(item);
    if (await _shouldSync()) {
      try {
        await SupabaseService.addToPurchaseHistory(item);
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }

  Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    return await LocalStorageService.getPurchaseHistory();
  }

  Future<List<String>> getFrequentlyPurchasedItems() async {
    // This logic relies on cloud for now, or we could calculate locally
    if (await _shouldSync()) {
      return await SupabaseService.getFrequentlyPurchasedItems();
    }
    // Simple local logic could be added here later
    return [];
  }

  Future<void> emptyTrash() async {
    await LocalStorageService.emptyTrash();
    if (await _shouldSync()) {
      try {
        await SupabaseService.emptyTrash();
      } catch (e) {
        print('Cloud sync failed: $e');
      }
    }
  }
}

