
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocerylist/data/models/models.dart';

class LocalStorageService {
  static const String _listsKey = 'guest_shopping_lists';
  static const String _itemsKey = 'guest_grocery_items';
  static const String _pantryKey = 'guest_pantry_items';
  static const String _recipesKey = 'guest_recipes';
  static const String _historyKey = 'guest_purchase_history';

  // --- Shopping Lists ---
  static Future<List<ShoppingList>> getShoppingLists() async {
    final all = await _getAllListsRaw();
    final items = await _getAllItemsRaw();

    final lists = all.where((l) => l.deletedAt == null).toList();
    for (var list in lists) {
      final listItems = items.where((i) => i.listId == list.id && i.deletedAt == null);
      list.totalItems = listItems.length;
      list.checkedItems = listItems.where((i) => i.isChecked).length;
    }
    return lists;
  }

  static Future<List<ShoppingList>> getTrashedShoppingLists() async {
    final all = await _getAllListsRaw();
    final items = await _getAllItemsRaw();

    final lists = all.where((l) => l.deletedAt != null).toList();
    for (var list in lists) {
      final listItems = items.where((i) => i.listId == list.id && i.deletedAt == null);
      list.totalItems = listItems.length;
      list.checkedItems = listItems.where((i) => i.isChecked).length;
    }
    return lists;
  }

  static Future<List<ShoppingList>> _getAllListsRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_listsKey);
      if (encoded == null) return [];
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((item) => ShoppingList.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveShoppingList(ShoppingList list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ShoppingList> all = await _getAllListsRaw();

    final index = all.indexWhere((l) => l.id == list.id);
    if (index >= 0) {
      all[index] = list;
    } else {
      all.add(list);
    }

    await prefs.setString(_listsKey, jsonEncode(all.map((l) => l.toMap()).toList()));
  }

  static Future<void> softDeleteShoppingList(String id) async {
    final all = await _getAllListsRaw();
    final index = all.indexWhere((l) => l.id == id);
    if (index >= 0) {
      all[index] = all[index].copyWith(deletedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_listsKey, jsonEncode(all.map((l) => l.toMap()).toList()));
    }
  }

  static Future<void> restoreShoppingList(String id) async {
    final all = await _getAllListsRaw();
    final index = all.indexWhere((l) => l.id == id);
    if (index >= 0) {
      all[index] = all[index].copyWith(restore: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_listsKey, jsonEncode(all.map((l) => l.toMap()).toList()));
    }
  }

  static Future<void> deleteShoppingListPermanently(String id) async {
    final all = await _getAllListsRaw();
    all.removeWhere((l) => l.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_listsKey, jsonEncode(all.map((l) => l.toMap()).toList()));
  }

  // --- Grocery Items ---
  static Future<List<GroceryItem>> getGroceryItems(String listId) async {
    final all = await _getAllItemsRaw();
    return all.where((i) => i.listId == listId && i.deletedAt == null).toList();
  }

  static Future<List<GroceryItem>> getAllTrashedGroceryItems() async {
    final all = await _getAllItemsRaw();
    return all.where((i) => i.deletedAt != null).toList();
  }

  static Future<List<GroceryItem>> _getAllItemsRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_itemsKey);
      if (encoded == null) return [];
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((item) => GroceryItem.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveGroceryItem(GroceryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<GroceryItem> all = await _getAllItemsRaw();

    final index = all.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      all[index] = item;
    } else {
      all.add(item);
    }

    await prefs.setString(_itemsKey, jsonEncode(all.map((i) => i.toMap()).toList()));
  }

  static Future<void> softDeleteGroceryItem(String id) async {
    final all = await _getAllItemsRaw();
    final index = all.indexWhere((i) => i.id == id);
    if (index >= 0) {
      all[index] = all[index].copyWith(deletedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_itemsKey, jsonEncode(all.map((i) => i.toMap()).toList()));
    }
  }

  static Future<void> restoreGroceryItem(String id) async {
    final all = await _getAllItemsRaw();
    final index = all.indexWhere((i) => i.id == id);
    if (index >= 0) {
      all[index] = all[index].copyWith(restore: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_itemsKey, jsonEncode(all.map((i) => i.toMap()).toList()));
    }
  }

  static Future<void> deleteGroceryItemPermanently(String id) async {
    final all = await _getAllItemsRaw();
    all.removeWhere((i) => i.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, jsonEncode(all.map((i) => i.toMap()).toList()));
  }

  static Future<void> emptyTrash() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear trashed lists
    final allLists = await _getAllListsRaw();
    allLists.removeWhere((l) => l.deletedAt != null);
    await prefs.setString(_listsKey, jsonEncode(allLists.map((l) => l.toMap()).toList()));

    // Clear trashed items
    final allItems = await _getAllItemsRaw();
    allItems.removeWhere((i) => i.deletedAt != null);
    await prefs.setString(_itemsKey, jsonEncode(allItems.map((i) => i.toMap()).toList()));
  }

  // --- Pantry Items ---
  static Future<List<PantryItem>> getPantryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_pantryKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => PantryItem.fromMap(item)).toList();
  }

  static Future<void> savePantryItem(PantryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PantryItem> all = await getPantryItems();
    final index = all.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      all[index] = item;
    } else {
      all.add(item);
    }
    await prefs.setString(_pantryKey, jsonEncode(all.map((i) => i.toMap()).toList()));
  }

  static Future<void> deletePantryItem(String id) async {
    final all = await getPantryItems();
    all.removeWhere((i) => i.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pantryKey, jsonEncode(all.map((i) => i.toMap()).toList()));
  }

  // --- Recipes ---
  static Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_recipesKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => Recipe.fromMap(item)).toList();
  }

  static Future<void> saveRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Recipe> all = await getRecipes();
    all.add(recipe); // Simplified
    await prefs.setString(_recipesKey, jsonEncode(all.map((r) => r.toMap()).toList()));
  }

  // --- Purchase History ---
  static Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_historyKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => PurchaseHistoryItem.fromMap(item)).toList();
  }

  static Future<void> savePurchaseHistoryItem(PurchaseHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PurchaseHistoryItem> all = await getPurchaseHistory();
    all.add(item);
    await prefs.setString(_historyKey, jsonEncode(all.map((i) => i.toMap()).toList()));
  }
}

