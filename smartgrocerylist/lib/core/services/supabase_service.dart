import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartgrocerylist/data/models/models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Shopping Lists
  static Future<List<ShoppingList>> getShoppingLists() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('shopping_lists')
        .select()
        .eq('created_by', userId)
        .filter('deleted_at', 'is', null)
        .order('last_modified', ascending: false);

    final lists = (response as List).map((json) => ShoppingList.fromMap(json)).toList();

    for (var list in lists) {
      final itemsRes = await _client.from('grocery_items').select('id, is_checked').eq('list_id', list.id).filter('deleted_at', 'is', null);
      final items = itemsRes as List;
      list.totalItems = items.length;
      list.checkedItems = items.where((i) => i['is_checked'] == true).length;
    }
    return lists;
  }

  static Future<List<ShoppingList>> getTrashedShoppingLists() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('shopping_lists')
        .select()
        .eq('created_by', userId)
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);

    final lists = (response as List).map((json) => ShoppingList.fromMap(json)).toList();

    for (var list in lists) {
      final itemsRes = await _client.from('grocery_items').select('id, is_checked').eq('list_id', list.id).filter('deleted_at', 'is', null);
      final items = itemsRes as List;
      list.totalItems = items.length;
      list.checkedItems = items.where((i) => i['is_checked'] == true).length;
    }
    return lists;
  }

  static Future<void> createShoppingList(ShoppingList list) async {
    final userId = _client.auth.currentUser?.id;
    // Allow creation even if userId is null (Guest mode / Backend handled)
    // if (userId == null) {
    //   throw Exception('User not authenticated. Please sign in to create lists.');
    // }

    final data = list.toMap();
    // Prune fields not in DB
    data.remove('total_items');
    data.remove('checked_items');
    data['created_by'] = userId;

    await _client.from('shopping_lists').upsert(data);
  }

  static Future<void> updateShoppingList(String id, Map<String, dynamic> updates) async {
    // Prune fields not in DB
    updates.remove('total_items');
    updates.remove('checked_items');
    await _client.from('shopping_lists').update(updates).eq('id', id);
  }

  static Future<void> softDeleteShoppingList(String id) async {
    await _client.from('shopping_lists').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static Future<void> deleteShoppingList(String id) async {
    await _client.from('shopping_lists').delete().eq('id', id);
  }

  static Future<void> restoreShoppingList(String id) async {
    await _client.from('shopping_lists').update({'deleted_at': null}).eq('id', id);
  }

  static Future<void> inviteCollaborator(String listId, String email) async {
    // Fetch current shared_with list
    final response = await _client
        .from('shopping_lists')
        .select('shared_with')
        .eq('id', listId)
        .single();

    List<String> sharedWith = List<String>.from(response['shared_with'] ?? []);
    if (!sharedWith.contains(email)) {
      sharedWith.add(email);
      await _client.from('shopping_lists').update({'shared_with': sharedWith}).eq('id', listId);
    }
  }


  // Grocery Items
  static Future<List<GroceryItem>> getGroceryItems(String listId) async {
    final response = await _client
        .from('grocery_items')
        .select()
        .eq('list_id', listId)
        .filter('deleted_at', 'is', null)
        .order('category', ascending: true);

    return (response as List).map((json) => GroceryItem.fromMap(json)).toList();
  }

  static Future<List<GroceryItem>> getAllTrashedGroceryItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('grocery_items')
        .select()
        .eq('added_by', userId)
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);

    return (response as List).map((json) => GroceryItem.fromMap(json)).toList();
  }

  static Future<void> createGroceryItem(GroceryItem item) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in to add items.');
    }

    final data = item.toMap();
    // Prune fields not in DB
    data.remove('store_aisle');
    data['added_by'] = userId;

    await _client.from('grocery_items').upsert(data);
  }

  static Future<void> updateGroceryItem(String id, Map<String, dynamic> updates) async {
    // Prune fields not in DB
    updates.remove('store_aisle');
    await _client.from('grocery_items').update(updates).eq('id', id);
  }

  static Future<void> softDeleteGroceryItem(String id) async {
    await _client.from('grocery_items').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static Future<void> deleteGroceryItem(String id) async {
    await _client.from('grocery_items').delete().eq('id', id);
  }

  static Future<void> restoreGroceryItem(String id) async {
    await _client.from('grocery_items').update({'deleted_at': null}).eq('id', id);
  }

  // Recipes
  static Future<List<Recipe>> getRecipes() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('recipes')
        .select('*, recipe_ingredients(*)')
        .eq('created_by', userId)
        .order('name', ascending: true);

    return (response as List).map((json) => Recipe.fromMap(json)).toList();
  }

  static Future<void> createRecipe(Recipe recipe) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final recipeData = recipe.toMap();
    recipeData['created_by'] = userId;
    recipeData.remove('ingredients'); // Handle separately

    final response = await _client.from('recipes').upsert(recipeData).select().single();
    final recipeId = response['id'];

    if (recipe.ingredients.isNotEmpty) {
      final ingredientsData = recipe.ingredients.map((ing) {
        final map = ing.toMap();
        map['recipe_id'] = recipeId;
        return map;
      }).toList();
      await _client.from('recipe_ingredients').upsert(ingredientsData);
    }
  }

  // Profiles
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return response as Map<String, dynamic>?;
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('profiles').update(updates).eq('id', userId);
  }

  // Pantry Items
  static Future<List<PantryItem>> getPantryItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('pantry_items')
        .select()
        .eq('created_by', userId)
        .order('name', ascending: true);

    return (response as List).map((json) => PantryItem.fromMap(json)).toList();
  }

  static Future<void> createPantryItem(PantryItem item) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final data = item.toMap();
    data['created_by'] = userId;
    await _client.from('pantry_items').upsert(data);
  }

  static Future<void> updatePantryItem(String id, Map<String, dynamic> updates) async {
    await _client.from('pantry_items').update(updates).eq('id', id);
  }

  static Future<void> deletePantryItem(String id) async {
    await _client.from('pantry_items').delete().eq('id', id);
  }

  // Purchase History
  static Future<void> addToPurchaseHistory(PurchaseHistoryItem item) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final data = item.toMap();
    data['created_by'] = userId;
    await _client.from('purchase_history').insert(data);
  }

  static Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('purchase_history')
        .select()
        .eq('created_by', userId)
        .order('purchase_date', ascending: false)
        .limit(100);

    return (response as List).map((json) => PurchaseHistoryItem.fromMap(json)).toList();
  }

  static Future<List<String>> getFrequentlyPurchasedItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('purchase_history')
        .select('item_name')
        .eq('created_by', userId);

    // Simple frequency count in Dart since we can't easily do complex GROUP BY in simple JS client without RPC sometimes
    // But for size of 100-1000 items, this is fine.
    final items = (response as List).map((i) => i['item_name'] as String).toList();
    final counts = <String, int>{};
    for (var item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).map((e) => e.key).toList();
  }

  // Storage
  static Future<String?> uploadImage(String path, String fileName) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final String extension = fileName.split('.').last;
      final String fullPath = 'public/$fileName';

      await _client.storage.from('item-images').uploadBinary(
            fullPath,
            bytes,
            fileOptions: const FileOptions(
                contentType: 'image/jpeg', upsert: true),
          );

      return _client.storage.from('item-images').getPublicUrl(fullPath);
    } catch (e) {
      return null;
    }
  }

  static Future<void> emptyTrash() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Delete trashed items first
    await _client.from('grocery_items')
        .delete()
        .eq('added_by', userId)
        .not('deleted_at', 'is', null);

    // Delete trashed lists
    await _client.from('shopping_lists')
        .delete()
        .eq('created_by', userId)
        .not('deleted_at', 'is', null);
  }
}
