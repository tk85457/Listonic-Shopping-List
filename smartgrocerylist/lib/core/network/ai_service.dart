import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocerylist/core/constants/app_categories.dart';

class AIService {
  static const String _learnedItemsKey = 'user_learned_grocery_items';
  static Map<String, String> _learnedItems = {};
  static bool _isInitialized = false;

  static final Map<String, List<String>> _groceryData = {
    AppCategories.produce: [
      'Apples', 'Bananas', 'Strawberries', 'Blueberries', 'Oranges', 'Lemons', 'Limes',
      'Grapes', 'Watermelon', 'Pineapple', 'Mango', 'Avocado', 'Tomatoes', 'Onions',
      'Garlic', 'Potatoes', 'Carrots', 'Spinach', 'Lettuce', 'Broccoli', 'Cucumber',
      'Bell Peppers', 'Mushrooms', 'Asparagus', 'Zucchini', 'Corn', 'Sweet Potato',
    ],
    AppCategories.dairy: [
      'Milk', 'Whole Milk', 'Skim Milk', 'Almond Milk', 'Oat Milk', 'Greek Yogurt',
      'Plain Yogurt', 'Cheddar Cheese', 'Mozzarella', 'Parmesan', 'Butter', 'Eggs',
      'Sour Cream', 'Cottage Cheese', 'Cream Cheese', 'Heavy Cream',
    ],
    AppCategories.meat: [
      'Chicken Breast', 'Chicken Thighs', 'Ground Beef', 'Steak', 'Bacon', 'Sausage',
      'Pork Chops', 'Salmon', 'Shrimp', 'Cod', 'Turkey', 'Lamb', 'Ham',
    ],
    AppCategories.bakery: [
      'Bread', 'Whole Wheat Bread', 'White Bread', 'Sourdough', 'Bagels', 'Tortillas',
      'Croissants', 'Muffins', 'Buns', 'Pita Bread',
    ],
    AppCategories.pantry: [
      'Rice', 'Pasta', 'Spaghetti', 'Olive Oil', 'Vegetable Oil', 'Flour', 'Sugar',
      'Salt', 'Black Pepper', 'Honey', 'Maple Syrup', 'Peanut Butter', 'Jam', 'Coffee',
      'Tea', 'Oats', 'Cereal', 'Tomato Sauce', 'Canned Beans', 'Quinoa', 'Lentils',
    ],
    AppCategories.frozen: [
      'Ice Cream', 'Frozen Pizza', 'Frozen Peas', 'Frozen Mixed Veggies', 'Frozen Berries',
      'Fish Sticks', 'Chicken Nuggets', 'Frozen Waffles',
    ],
    AppCategories.beverages: [
      'Water', 'Sparkling Water', 'Orange Juice', 'Apple Juice', 'Soda', 'Coke', 'Pepsi',
      'Energy Drink', 'Wine', 'Beer', 'Iced Tea',
    ],
    AppCategories.snacks: [
      'Chips', 'Popcorn', 'Pretzels', 'Crackers', 'Mixed Nuts', 'Chocolate', 'Cookies',
      'Granola Bars', 'Gummy Bears',
    ],
    AppCategories.household: [
      'Paper Towels', 'Toilet Paper', 'Dish Soap', 'Laundry Detergent', 'Trash Bags',
      'Sponges', 'All-purpose Cleaner', 'Tissues',
    ],
    AppCategories.personalCare: [
      'Shampoo', 'Conditioner', 'Body Wash', 'Toothpaste', 'Deodorant', 'Hand Soap',
      'Shaving Cream', 'Sunscreen',
    ],
  };

  static Future<void> initializeMLModel() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_learnedItemsKey);
      if (savedData != null) {
        _learnedItems = Map<String, String>.from(json.decode(savedData));
      }
      _isInitialized = true;
      debugPrint('🧠 AIService: Loaded ${_learnedItems.length} learned items.');
    } catch (e) {
      debugPrint('❌ AIService Init Error: $e');
    }
  }

  static Future<List<String>> getSuggestions(String query) async {
    if (!_isInitialized) await initializeMLModel();
    if (query.trim().isEmpty) return [];

    final lowercaseQuery = query.toLowerCase().trim();
    final List<String> suggestions = [];

    // 1. Add learned items (Prioritize user-preferred terms)
    _learnedItems.forEach((item, _) {
      if (item.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(item);
      }
    });

    // 2. Add static grocery data
    _groceryData.forEach((category, items) {
      for (var item in items) {
        // Avoid duplicates if user already learned it
        if (!suggestions.any((s) => s.toLowerCase() == item.toLowerCase())) {
          if (item.toLowerCase().contains(lowercaseQuery)) {
            suggestions.add(item);
          }
        }
      }
    });

    // 3. Sort by relevance (startsWith first)
    suggestions.sort((a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();

      // Check if they are learned items
      final aLearned = _learnedItems.containsKey(a);
      final bLearned = _learnedItems.containsKey(b);

      if (aLearned && !bLearned) return -1;
      if (!aLearned && bLearned) return 1;

      final aStarts = aLower.startsWith(lowercaseQuery);
      final bStarts = bLower.startsWith(lowercaseQuery);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      return aLower.compareTo(bLower);
    });

    return suggestions.take(10).toList();
  }

  static Future<String?> categorizeItem(String item) async {
    if (!_isInitialized) await initializeMLModel();
    final lowercaseItem = item.toLowerCase().trim();

    // Check learned first
    if (_learnedItems.containsKey(item)) {
       return _learnedItems[item];
    }
    // Case-insensitive learned check
    for(var entry in _learnedItems.entries) {
      if (entry.key.toLowerCase() == lowercaseItem) return entry.value;
    }

    // Exact match check in static data
    for (var entry in _groceryData.entries) {
      if (entry.value.any((e) => e.toLowerCase() == lowercaseItem)) {
        return entry.key;
      }
    }

    // Keyword check
    if (lowercaseItem.contains('milk') || lowercaseItem.contains('yogurt') || lowercaseItem.contains('cheese')) {
      return AppCategories.dairy;
    }
    if (lowercaseItem.contains('chicken') || lowercaseItem.contains('beef') || lowercaseItem.contains('meat') || lowercaseItem.contains('pork')) {
      return AppCategories.meat;
    }
    if (lowercaseItem.contains('apple') || lowercaseItem.contains('banana') || lowercaseItem.contains('veggie') || lowercaseItem.contains('fruit')) {
      return AppCategories.produce;
    }
    if (lowercaseItem.contains('bread') || lowercaseItem.contains('bun') || lowercaseItem.contains('roll')) {
      return AppCategories.bakery;
    }
    if (lowercaseItem.contains('frozen') || lowercaseItem.contains('ice cream')) {
      return AppCategories.frozen;
    }
    if (lowercaseItem.contains('drink') || lowercaseItem.contains('water') || lowercaseItem.contains('juice') || lowercaseItem.contains('soda')) {
      return AppCategories.beverages;
    }
    if (lowercaseItem.contains('rice') || lowercaseItem.contains('chawal') || lowercaseItem.contains('grain')) {
      return AppCategories.pantry;
    }

    return AppCategories.other;
  }

  static Future<void> learnItem(String item, String? category) async {
    if (!_isInitialized) await initializeMLModel();
    if (item.trim().isEmpty) return;

    final trimmedItem = item.trim();
    final cat = category ?? AppCategories.other;

    _learnedItems[trimmedItem] = cat;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_learnedItemsKey, json.encode(_learnedItems));
      debugPrint('✅ Learned item: "$trimmedItem" in category: $cat');
    } catch (e) {
      debugPrint('❌ Failed to save learned item: $e');
    }
  }

  static Future<void> trackTypingPattern(String query, String selection) async {
    // Learning happens on add_item instead of just typing to ensure accuracy
  }

  static List<String> getRecentLearnedItems() {
    return _learnedItems.keys.toList().reversed.take(10).toList();
  }
}

