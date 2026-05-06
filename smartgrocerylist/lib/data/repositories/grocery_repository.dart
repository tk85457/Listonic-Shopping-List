import 'package:grocerylist/data/models/models.dart';
import 'package:grocerylist/core/services/local_storage_service.dart';

class GroceryRepository {
  // Handles Local (Guest) storage.

  // --- Shopping List methods ---
  Future<List<ShoppingList>> getAllShoppingLists() async {
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
    await LocalStorageService.saveShoppingList(list);
  }

  Future<void> updateShoppingList(ShoppingList list) async {
    await LocalStorageService.saveShoppingList(list);
  }

  Future<void> softDeleteShoppingList(String id) async {
    await LocalStorageService.softDeleteShoppingList(id);
  }

  Future<void> restoreShoppingList(String id) async {
    await LocalStorageService.restoreShoppingList(id);
  }

  Future<void> deleteShoppingList(String id) async {
    await LocalStorageService.deleteShoppingListPermanently(id);
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
  }

  Future<void> updateGroceryItem(GroceryItem item) async {
    await LocalStorageService.saveGroceryItem(item);
  }

  Future<void> softDeleteGroceryItem(String id) async {
    await LocalStorageService.softDeleteGroceryItem(id);
  }

  Future<void> restoreGroceryItem(String id) async {
    await LocalStorageService.restoreGroceryItem(id);
  }

  Future<void> deleteGroceryItem(String id) async {
    await LocalStorageService.deleteGroceryItemPermanently(id);
  }

  // --- Pantry Items methods ---
  Future<List<PantryItem>> getAllPantryItems() async {
    return await LocalStorageService.getPantryItems();
  }

  Future<void> addPantryItem(PantryItem item) async {
    await LocalStorageService.savePantryItem(item);
  }

  Future<void> updatePantryItem(PantryItem item) async {
    await LocalStorageService.savePantryItem(item);
  }

  Future<void> deletePantryItem(String id) async {
    await LocalStorageService.deletePantryItem(id);
  }

  // --- Recipe methods ---
  Future<List<Recipe>> getAllRecipes() async {
    return await LocalStorageService.getRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await LocalStorageService.saveRecipe(recipe);
  }

  // --- Purchase History methods ---
  Future<void> addToPurchaseHistory(PurchaseHistoryItem item) async {
    await LocalStorageService.savePurchaseHistoryItem(item);
  }

  Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    return await LocalStorageService.getPurchaseHistory();
  }

  Future<List<String>> getFrequentlyPurchasedItems() async {
    // Simple local logic could be added here later
    return [];
  }

  Future<void> emptyTrash() async {
    await LocalStorageService.emptyTrash();
  }
}


