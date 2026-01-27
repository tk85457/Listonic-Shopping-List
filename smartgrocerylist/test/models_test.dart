import 'package:flutter_test/flutter_test.dart';
import 'package:smartgrocerylist/data/models/models.dart';

void main() {
  group('GroceryItem Model', () {
    test('should create a valid GroceryItem', () {
      final item = GroceryItem(
        name: 'Milk',
        category: 'Dairy & Eggs',
        listId: 'list1',
        quantity: 2,
        unit: 'gallons',
        notes: 'Whole milk preferred',
      );

      expect(item.name, 'Milk');
      expect(item.category, 'Dairy & Eggs');
      expect(item.quantity, 2);
      expect(item.isChecked, false);
      expect(item.listId, 'list1');
    });

    test('should convert to map and from map', () {
      final item = GroceryItem(
        name: 'Bread',
        category: 'Bakery',
        listId: 'list1',
        quantity: 1,
        unit: 'loaf',
      );

      final map = item.toMap();
      final restored = GroceryItem.fromMap(map);

      expect(restored.name, item.name);
      expect(restored.category, item.category);
    });
  });

  group('ShoppingList Model', () {
    test('should create a valid ShoppingList', () {
      final list = ShoppingList(name: 'Weekly Groceries');

      expect(list.name, 'Weekly Groceries');
      expect(list.isDefault, false);
      expect(list.sharedWith, []);
    });

    test('should convert to map and from map', () {
      final list = ShoppingList(
        name: 'Party Supplies',
        createdBy: 'user1',
        isDefault: true,
        sharedWith: ['user2', 'user3'],
      );

      final map = list.toMap();
      final restored = ShoppingList.fromMap(map);

      expect(restored.name, list.name);
      expect(restored.isDefault, true);
      expect(restored.sharedWith, ['user2', 'user3']);
    });

    test('should handle empty sharedWith', () {
      final list = ShoppingList(name: 'My List');
      final map = list.toMap();
      final restored = ShoppingList.fromMap(map);

      expect(restored.sharedWith, []);
    });
  });

  group('PantryItem Model', () {
    test('should create a valid PantryItem', () {
      final item = PantryItem(
        name: 'Canned Tomatoes',
        category: 'Pantry Staples',
        quantity: 3,
        unit: 'cans',
        purchaseDate: DateTime(2024, 1, 1),
        expirationDate: DateTime(2025, 1, 1),
        location: 'Pantry',
      );

      expect(item.name, 'Canned Tomatoes');
      expect(item.location, 'Pantry');
    });

    test('should check if item is expiring soon', () {
      final soonItem = PantryItem(
        name: 'Yogurt',
        category: 'Dairy & Eggs',
        quantity: 1,
        unit: 'container',
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        expirationDate: DateTime.now().add(const Duration(days: 2)),
        location: 'Fridge',
      );

      expect(soonItem.isExpiringSoon, true);
    });

    test('should check if item is not expiring soon', () {
      final normalItem = PantryItem(
        name: 'Rice',
        category: 'Pantry Staples',
        quantity: 1,
        unit: 'bag',
        purchaseDate: DateTime(2024, 1, 1),
        expirationDate: DateTime(2025, 6, 1),
        location: 'Pantry',
      );

      expect(normalItem.isExpiringSoon, false);
    });

    test('should check if item is expired', () {
      final expiredItem = PantryItem(
        name: 'Expired Milk',
        category: 'Dairy & Eggs',
        quantity: 1,
        unit: 'carton',
        purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
        expirationDate: DateTime.now().subtract(const Duration(days: 5)),
        location: 'Fridge',
      );

      expect(expiredItem.isExpired, true);
    });

    test('should handle null expiration date', () {
      final item = PantryItem(
        name: 'Salt',
        category: 'Pantry Staples',
        quantity: 1,
        unit: 'container',
        purchaseDate: DateTime.now(),
        expirationDate: null,
        location: 'Pantry',
      );

      expect(item.isExpired, false);
      expect(item.isExpiringSoon, false);
    });
  });

  group('Recipe Model', () {
    test('should create a valid Recipe', () {
      final ingredient = RecipeIngredient(
        name: 'Spaghetti',
        quantity: 500,
        unit: 'grams',
      );

      final recipe = Recipe(
        name: 'Spaghetti Bolognese',
        servings: 4,
        prepTime: 15,
        cookTime: 45,
        ingredients: [ingredient],
        cuisine: 'Italian',
        dietaryTags: ['gluten'],
        isFavorite: true,
      );

      expect(recipe.name, 'Spaghetti Bolognese');
      expect(recipe.cuisine, 'Italian');
      expect(recipe.isFavorite, true);
      expect(recipe.totalTime, 60);
      expect(recipe.ingredients.length, 1);
    });

    test('should calculate total time correctly', () {
      final recipe = Recipe(
        name: 'Quick Meal',
        servings: 2,
        prepTime: 10,
        cookTime: 20,
        ingredients: [],
      );

      expect(recipe.totalTime, 30);
    });
  });

  group('RecipeIngredient Model', () {
    test('should create a valid RecipeIngredient', () {
      final ingredient = RecipeIngredient(
        name: 'Olive Oil',
        quantity: 2,
        unit: 'tablespoons',
        isOptional: true,
      );

      expect(ingredient.name, 'Olive Oil');
      expect(ingredient.quantity, 2);
      expect(ingredient.isOptional, true);
    });

    test('should convert to map and from map', () {
      final ingredient = RecipeIngredient(
        name: 'Garlic',
        quantity: 3,
        unit: 'cloves',
        isOptional: false,
      );

      final map = ingredient.toMap();
      final restored = RecipeIngredient.fromMap(map);

      expect(restored.name, ingredient.name);
      expect(restored.quantity, ingredient.quantity);
      expect(restored.isOptional, ingredient.isOptional);
    });
  });
}
