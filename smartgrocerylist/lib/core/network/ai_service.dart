import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  // User behavior tracking for ML predictions
  static final Map<String, int> _userTypingPatterns = {};
  static final List<String> _recentlyAddedItems = [];
  static final Map<String, List<String>> _contextualSuggestions = {};

  // New ML Model for real-time item prediction
  static final Map<String, Map<String, double>> _behaviorPredictionModel = {};
  static final Map<String, List<String>> _listContextPatterns = {};
  static final Map<String, int> _itemFrequencyMap = {};
  static bool _newModelInitialized = false;

  // Initialize ML model with user data
  static Future<void> initializeMLModel() async {
    await _loadUserBehaviorData();
    await _initializeNewMLModel();
  }

  // Initialize the new ML model for real-time predictions
  static Future<void> _initializeNewMLModel() async {
    if (_newModelInitialized) return;

    // Initialize with common behavioral patterns
    _behaviorPredictionModel.addAll({
      'morning': {'coffee': 0.8, 'bread': 0.6, 'milk': 0.7, 'eggs': 0.5},
      'weekend': {'chicken': 0.7, 'pasta': 0.6, 'cheese': 0.8, 'wine': 0.4},
      'dinner': {'chicken': 0.9, 'rice': 0.7, 'vegetables': 0.8, 'salad': 0.6},
      'snack': {'chips': 0.6, 'cookies': 0.5, 'fruit': 0.7, 'yogurt': 0.8},
    });

    _newModelInitialized = true;
  }

  // Track user typing patterns for ML learning
  static void trackTypingPattern(String input, String finalItem) {
    final pattern = input.toLowerCase();
    _userTypingPatterns[pattern] = (_userTypingPatterns[pattern] ?? 0) + 1;

    // Add to recently added items for context
    if (!_recentlyAddedItems.contains(finalItem)) {
      _recentlyAddedItems.insert(0, finalItem);
      if (_recentlyAddedItems.length > 50) {
        _recentlyAddedItems.removeLast(); // Keep only recent 50 items
      }
    }

    // Learn contextual relationships
    _learnContextualPatterns(input, finalItem);

    // Update new ML model with real-time behavior
    _updateNewMLModel(input, finalItem);

    // Save updated model data
    _saveUserBehaviorData();
  }

  // Update the new ML model with real-time user behavior
  static void _updateNewMLModel(String input, String finalItem) {
    // Track item frequency
    _itemFrequencyMap[finalItem] = (_itemFrequencyMap[finalItem] ?? 0) + 1;

    // Learn context patterns (what items are added together)
    final contextKey = _getCurrentContextKey();
    if (!_listContextPatterns.containsKey(contextKey)) {
      _listContextPatterns[contextKey] = [];
    }
    if (!_listContextPatterns[contextKey]!.contains(finalItem)) {
      _listContextPatterns[contextKey]!.add(finalItem);
    }

    // Learn behavioral patterns based on time/context
    final behaviorKey = _getCurrentBehaviorKey();
    if (!_behaviorPredictionModel.containsKey(behaviorKey)) {
      _behaviorPredictionModel[behaviorKey] = {};
    }

    // Increase confidence score for this item in this context
    final currentScore =
        _behaviorPredictionModel[behaviorKey]![finalItem] ?? 0.0;
    _behaviorPredictionModel[behaviorKey]![finalItem] = (currentScore + 0.1)
        .clamp(0.0, 1.0);
  }

  // Get current context key (based on current list or time)
  static String _getCurrentContextKey() {
    // In production, this would be based on the current list ID or category
    // For now, return a default context
    return 'current_list';
  }

  // Get current behavior key (based on time of day, day of week, etc.)
  static String _getCurrentBehaviorKey() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'dinner';
    if (now.weekday >= 6) return 'weekend';
    return 'weekday';
  }

  // Get predictions from new ML model
  static List<String> getRealTimePredictions(
    String currentInput,
    String listId,
  ) {
    final predictions = <String>[];
    final behaviorKey = _getCurrentBehaviorKey();
    final contextKey = _getCurrentContextKey();

    // Get behavior-based predictions
    final behaviorPredictions = _behaviorPredictionModel[behaviorKey] ?? {};
    final sortedBehavior =
        behaviorPredictions.entries
            .where((e) => e.value > 0.3) // Only high confidence predictions
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    predictions.addAll(sortedBehavior.map((e) => e.key));

    // Get context-based predictions
    final contextItems = _listContextPatterns[contextKey] ?? [];
    predictions.addAll(
      contextItems.where(
        (item) =>
            !predictions.contains(item) &&
            item.toLowerCase().contains(currentInput.toLowerCase()),
      ),
    );

    // Get frequency-based predictions
    final frequentItems =
        _itemFrequencyMap.entries
            .where((e) => e.value > 2) // Items added more than twice
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    predictions.addAll(
      frequentItems
          .map((e) => e.key)
          .where(
            (item) =>
                !predictions.contains(item) &&
                item.toLowerCase().contains(currentInput.toLowerCase()),
          ),
    );

    return predictions.take(5).toList(); // Limit to 5 predictions
  }

  // Enhanced suggestions combining both ML models
  static Future<List<String>> getEnhancedItemSuggestions(
    String input,
    List<String> history,
    String listId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final bool aiEnabled = prefs.getBool('ai_suggestions') ?? true;

    if (!aiEnabled) return [];

    final allSuggestions = <String>{};

    // Get suggestions from existing ML model
    final existingSuggestions = await getItemSuggestions(input, history);
    allSuggestions.addAll(existingSuggestions);

    // Get predictions from new ML model
    final newPredictions = getRealTimePredictions(input, listId);
    allSuggestions.addAll(newPredictions);

    // Prioritize and limit results
    final prioritized = _prioritizeSuggestions(allSuggestions.toList(), input);
    return prioritized.take(10).toList();
  }

  // Prioritize suggestions based on relevance and confidence
  static List<String> _prioritizeSuggestions(
    List<String> suggestions,
    String input,
  ) {
    final lowerInput = input.toLowerCase();

    return suggestions..sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(lowerInput);
      final bStarts = b.toLowerCase().startsWith(lowerInput);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      final aContains = a.toLowerCase().contains(lowerInput);
      final bContains = b.toLowerCase().contains(lowerInput);
      if (aContains && !bContains) return -1;
      if (!aContains && bContains) return 1;

      // If tie, prefer shorter items (more specific matches)
      return a.length.compareTo(b.length);
    });
  }

  // Load/Save user behavior data
  static Future<void> _saveUserBehaviorData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ml_typing_patterns', jsonEncode(_userTypingPatterns));
    await prefs.setStringList('ml_recent_items', _recentlyAddedItems);
    await prefs.setString('ml_frequency_map', jsonEncode(_itemFrequencyMap));

    // Save contextual suggestions
    await prefs.setString('ml_contextual_suggestions', jsonEncode(_contextualSuggestions));

    // Save behavior prediction model (simplified)
    final Map<String, dynamic> serializableBehavior = {};
    _behaviorPredictionModel.forEach((key, map) {
      serializableBehavior[key] = map;
    });
    await prefs.setString('ml_behavior_model', jsonEncode(serializableBehavior));
  }

  static Future<void> _loadUserBehaviorData() async {
    final prefs = await SharedPreferences.getInstance();

    final patternsStr = prefs.getString('ml_typing_patterns');
    if (patternsStr != null) {
      final Map<String, dynamic> decoded = jsonDecode(patternsStr);
      decoded.forEach((key, value) => _userTypingPatterns[key] = value as int);
    } else {
      // Default common patterns
      _userTypingPatterns.addAll({'mil': 5, 'egg': 5, 'bre': 5, 'app': 5});
    }

    _recentlyAddedItems.clear();
    _recentlyAddedItems.addAll(prefs.getStringList('ml_recent_items') ?? []);

    final freqStr = prefs.getString('ml_frequency_map');
    if (freqStr != null) {
      final Map<String, dynamic> decoded = jsonDecode(freqStr);
      decoded.forEach((key, value) => _itemFrequencyMap[key] = value as int);
    }

    final contextStr = prefs.getString('ml_contextual_suggestions');
    if (contextStr != null) {
      final Map<String, dynamic> decoded = jsonDecode(contextStr);
      decoded.forEach((key, value) {
        _contextualSuggestions[key] = List<String>.from(value as List);
      });
    }

    final behaviorStr = prefs.getString('ml_behavior_model');
    if (behaviorStr != null) {
      final Map<String, dynamic> decoded = jsonDecode(behaviorStr);
      decoded.forEach((key, mapValue) {
        final Map<String, double> innerMap = {};
        (mapValue as Map<String, dynamic>).forEach((k, v) => innerMap[k] = (v as num).toDouble());
        _behaviorPredictionModel[key] = innerMap;
      });
    }
  }

  // Learn contextual patterns from user behavior
  static void _learnContextualPatterns(String input, String finalItem) {
    final contextKey = input.substring(0, min(3, input.length)).toLowerCase();
    if (!_contextualSuggestions.containsKey(contextKey)) {
      _contextualSuggestions[contextKey] = [];
    }
    if (!_contextualSuggestions[contextKey]!.contains(finalItem)) {
      _contextualSuggestions[contextKey]!.add(finalItem);
    }
  }

  // Enhanced smart suggestions based on partial input and user behavior
  static Future<List<String>> getItemSuggestions(
    String input,
    List<String> history,
  ) async {
    if (input.isEmpty) return [];

    final lowerInput = input.toLowerCase();
    final suggestions = <String>[];
    final seen = <String>{};

    // 1. ML-based predictions from user typing patterns
    final patternMatches = _getPatternBasedSuggestions(lowerInput);
    suggestions.addAll(patternMatches.where((s) => seen.add(s)));

    // 2. Contextual suggestions based on user behavior
    final contextualMatches = _getContextualSuggestions(lowerInput);
    suggestions.addAll(contextualMatches.where((s) => seen.add(s)));

    // 3. History-based suggestions
    final historyMatches = history
        .where((item) => item.toLowerCase().contains(lowerInput))
        .take(3);
    suggestions.addAll(historyMatches.where((s) => seen.add(s)));

    // 4. Recently added items
    final recentMatches = _recentlyAddedItems
        .where((item) => item.toLowerCase().contains(lowerInput))
        .take(2);
    suggestions.addAll(recentMatches.where((s) => seen.add(s)));

    // 5. Fallback to category-based suggestions
    if (suggestions.length < 5) {
      final categoryMatches = _getCategoryBasedSuggestions(lowerInput);
      suggestions.addAll(
        categoryMatches.where((s) => seen.add(s)).take(5 - suggestions.length),
      );
    }

    return suggestions.take(8).toList(); // Limit to 8 suggestions
  }

  // Get suggestions based on learned typing patterns
  static List<String> _getPatternBasedSuggestions(String input) {
    final suggestions = <String>[];

    // Find patterns that match the current input
    for (final pattern in _userTypingPatterns.keys) {
      if (pattern.startsWith(input) || input.startsWith(pattern)) {
        final frequency = _userTypingPatterns[pattern] ?? 0;
        if (frequency > 3) {
          // Only suggest frequently used patterns
          suggestions.addAll(_getCommonItemsForPattern(pattern));
        }
      }
    }

    return suggestions;
  }

  // Get contextual suggestions based on learned behavior
  static List<String> _getContextualSuggestions(String input) {
    final contextKey = input.substring(0, min(3, input.length));
    return _contextualSuggestions[contextKey] ?? [];
  }

  // Get common items for typing patterns
  static List<String> _getCommonItemsForPattern(String pattern) {
    final patternMap = {
      'mil': ['Milk', 'Whole Milk', '2% Milk', 'Almond Milk', 'Oat Milk'],
      'egg': ['Eggs', 'Large Eggs', 'Organic Eggs', 'Free Range Eggs'],
      'bre': ['Bread', 'Whole Wheat Bread', 'Sourdough Bread', 'White Bread'],
      'chi': ['Chicken', 'Chicken Breast', 'Chicken Thighs', 'Ground Chicken'],
      'ban': ['Bananas', 'Organic Bananas', 'Banana Chips'],
      'app': ['Apples', 'Red Apples', 'Green Apples', 'Organic Apples'],
      'tom': ['Tomatoes', 'Cherry Tomatoes', 'Roma Tomatoes'],
      'che': [
        'Cheese',
        'Cheddar Cheese',
        'Mozzarella Cheese',
        'Parmesan Cheese',
      ],
      'yog': ['Yogurt', 'Greek Yogurt', 'Plain Yogurt', 'Vanilla Yogurt'],
      'but': ['Butter', 'Unsalted Butter', 'Salted Butter'],
    };

    return patternMap[pattern] ?? [];
  }

  // Enhanced category-based suggestions
  static List<String> _getCategoryBasedSuggestions(String input) {
    final suggestions = <String>[];

    // Existing category logic with enhancements
    if (input.contains('milk')) {
      suggestions.addAll([
        'Whole Milk',
        '2% Milk',
        'Skim Milk',
        'Almond Milk',
        'Oat Milk',
        'Soy Milk',
        'Coconut Milk',
        'Lactose Free Milk',
      ]);
    }

    if (input.contains('egg')) {
      suggestions.addAll([
        'Large Eggs',
        'Extra Large Eggs',
        'Free Range Eggs',
        'Organic Eggs',
        'Egg Whites',
        'Egg Yolks',
        'Hard Boiled Eggs',
      ]);
    }

    if (input.contains('bread')) {
      suggestions.addAll([
        'Whole Wheat Bread',
        'Sourdough Bread',
        'Rye Bread',
        'Pita Bread',
        'Bagels',
        'English Muffins',
        'Croissants',
        'Baguette',
      ]);
    }

    if (input.contains('chicken')) {
      suggestions.addAll([
        'Chicken Breast',
        'Chicken Thighs',
        'Chicken Wings',
        'Ground Chicken',
        'Whole Chicken',
        'Chicken Drumsticks',
        'Rotisserie Chicken',
      ]);
    }

    if (input.contains('cheese')) {
      suggestions.addAll([
        'Cheddar Cheese',
        'Mozzarella Cheese',
        'Parmesan Cheese',
        'Swiss Cheese',
        'American Cheese',
        'Feta Cheese',
        'Goat Cheese',
      ]);
    }

    if (input.contains('yogurt') || input.contains('yoghurt')) {
      suggestions.addAll([
        'Greek Yogurt',
        'Plain Yogurt',
        'Vanilla Yogurt',
        'Strawberry Yogurt',
        'Activia Yogurt',
        'Chobani Yogurt',
      ]);
    }

    return suggestions;
  }

  // Helper function
  static int min(int a, int b) => a < b ? a : b;

  // Auto-categorize items
  static Future<String> categorizeItem(String itemName) async {
    final categories = {
      'Produce': [
        'apple',
        'banana',
        'orange',
        'tomato',
        'onion',
        'garlic',
        'pepper',
        'lettuce',
        'spinach',
        'carrot',
        'potato',
        'fruit',
        'vegetable',
        'herb',
      ],
      'Dairy & Eggs': [
        'milk',
        'cheese',
        'yogurt',
        'egg',
        'butter',
        'cream',
        'sour cream',
        'cottage',
        'ricotta',
      ],
      'Meat & Seafood': [
        'chicken',
        'beef',
        'pork',
        'fish',
        'salmon',
        'shrimp',
        'turkey',
        'lamb',
        'bacon',
        'sausage',
        'ham',
      ],
      'Bakery': [
        'bread',
        'bagel',
        'croissant',
        'muffin',
        'pastry',
        'tortilla',
        'bun',
        'roll',
      ],
      'Pantry Staples': [
        'pasta',
        'rice',
        'flour',
        'sugar',
        'sauce',
        'ketchup',
        'mustard',
        'oil',
        'vinegar',
        'spice',
        'canned',
        'bean',
        'lentil',
      ],
      'Frozen Foods': ['ice cream', 'frozen', 'pizza', 'fries', 'vegetables'],
      'Beverages': [
        'water',
        'soda',
        'juice',
        'coffee',
        'tea',
        'wine',
        'beer',
        'drink',
      ],
      'Snacks': [
        'chip',
        'crack',
        'cookie',
        'candy',
        'chocolate',
        'nut',
        'pretzel',
        'popcorn',
      ],
      'Personal Care': [
        'shampoo',
        'soap',
        'toothpaste',
        'deodorant',
        'lotion',
        'cream',
      ],
      'Household Items': [
        'cleaner',
        'detergent',
        'paper',
        'towel',
        'bag',
        'battery',
      ],
    };

    final lowerItem = itemName.toLowerCase();

    for (final entry in categories.entries) {
      for (final keyword in entry.value) {
        if (lowerItem.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Other';
  }

  // Generate recipe from ingredients
  static Future<String> generateRecipeSuggestion(
    List<String> ingredients,
    String cuisine,
    List<String> dietary,
  ) async {
    // Mock AI response - in production, call GPT-4 API
    return '''
    Based on your ingredients ($ingredients), here are some recipe ideas:

    1. Quick Stir Fry
    - Perfect for using up vegetables and protein
    - 15-20 minutes

    2. One-Pot Pasta
    - Simple and delicious
    - 25 minutes

    3. Sheet Pan Dinner
    - Easy cleanup
    - 30 minutes
    ''';
  }

  // Analyze receipt text
  static Future<List<Map<String, dynamic>>> parseReceipt(String ocrText) async {
    // Mock receipt parsing - in production, use GPT-4 Vision
    // This would extract items, quantities, and prices from receipt
    return [];
  }

  // Healthy alternatives
  static Future<List<Map<String, String>>> getHealthyAlternatives(
    String item,
    String dietaryGoal,
  ) async {
    final alternatives = {
      'white bread': [
        {'name': 'Whole Wheat Bread', 'benefit': 'More fiber'},
        {'name': 'Sourdough', 'benefit': 'Lower glycemic index'},
      ],
      'soda': [
        {'name': 'Sparkling Water', 'benefit': 'No sugar'},
        {'name': 'Kombucha', 'benefit': 'Probiotics'},
      ],
      'chips': [
        {'name': 'Popcorn', 'benefit': 'Whole grain'},
        {'name': 'Veggie Chips', 'benefit': 'More nutrients'},
      ],
    };

    final lowerItem = item.toLowerCase();
    for (final entry in alternatives.entries) {
      if (lowerItem.contains(entry.key)) {
        return entry.value;
      }
    }

    return [
      {'name': 'Consider fresh options', 'benefit': 'Less processed'},
    ];
  }

  // Image recognition for item suggestions
  static Future<String> suggestItemFromImage(String imagePath) async {
    // Mock AI image recognition - in production, use Google ML Kit or OpenAI Vision
    // For now, return a mock suggestion based on common grocery items
    return 'Milk'; // Mock response
  }
}
