import 'package:uuid/uuid.dart';

class GroceryItem {
  String id;
  String name;
  String category;
  int quantity;
  String unit;
  bool isChecked;
  String notes;
  String listId;
  DateTime addedDate;
  String addedBy;
  DateTime? deletedAt;
  String? imageUrl;
  String storeAisle;

  GroceryItem({
    String? id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.unit = 'item',
    this.isChecked = false,
    this.notes = '',
    required this.listId,
    DateTime? addedDate,
    this.addedBy = 'me',
    this.deletedAt,
    this.imageUrl,
    this.storeAisle = 'Other',
  }) : id = id ?? const Uuid().v4(),
       addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'is_checked': isChecked,
      'notes': notes,
      'added_date': addedDate.toIso8601String(),
      'added_by': addedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'image_url': imageUrl,
      'store_aisle': storeAisle,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: (map['quantity'] ?? 1).toInt(),
      unit: map['unit'] ?? 'item',
      isChecked: map['is_checked'] ?? (map['isChecked'] == 1),
      notes: map['notes'] ?? '',
      listId: map['list_id'] ?? map['listId'],
      addedDate: DateTime.parse(map['added_date'] ?? map['addedDate']),
      addedBy: map['added_by'] ?? map['addedBy'] ?? 'me',
      deletedAt: (map['deleted_at'] ?? map['deletedAt']) != null
          ? DateTime.parse(map['deleted_at'] ?? map['deletedAt'])
          : null,
      imageUrl: map['image_url'] ?? map['imageUrl'],
      storeAisle: map['store_aisle'] ?? map['storeAisle'] ?? 'Other',
    );
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    bool? isChecked,
    String? notes,
    String? listId,
    DateTime? addedDate,
    String? addedBy,
    DateTime? deletedAt,
    bool restore = false,
    String? imageUrl,
    String? storeAisle,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
      listId: listId ?? this.listId,
      addedDate: addedDate ?? this.addedDate,
      addedBy: addedBy ?? this.addedBy,
      deletedAt: restore ? null : (deletedAt ?? this.deletedAt),
      imageUrl: imageUrl ?? this.imageUrl,
      storeAisle: storeAisle ?? this.storeAisle,
    );
  }
}

class ShoppingList {
  String id;
  String name;
  DateTime createdDate;
  DateTime lastModified;
  String createdBy;
  bool isDefault;
  List<String> sharedWith;
  DateTime? deletedAt;
  int totalItems;
  int checkedItems;

  ShoppingList({
    String? id,
    required this.name,
    DateTime? createdDate,
    DateTime? lastModified,
    this.createdBy = 'me',
    this.isDefault = false,
     this.sharedWith = const [],
    this.deletedAt,
    this.totalItems = 0,
    this.checkedItems = 0,
  }) : id = id ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now(),
       lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdDate.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
      'created_by': createdBy,
      'is_default': isDefault,
      'shared_with': sharedWith,
      'deleted_at': deletedAt?.toIso8601String(),
      'total_items': totalItems,
      'checked_items': checkedItems,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'],
      name: map['name'],
      createdDate: DateTime.parse(map['created_at'] ?? map['created_date'] ?? map['createdDate'] ?? DateTime.now().toIso8601String()),
      lastModified: DateTime.parse(map['last_modified'] ?? map['lastModified'] ?? DateTime.now().toIso8601String()),
      createdBy: map['created_by'] ?? map['createdBy'] ?? 'me',
      isDefault: map['is_default'] ?? (map['isDefault'] == 1),
      sharedWith: map['shared_with'] is List
          ? List<String>.from(map['shared_with'])
          : map['shared_with'] != null && map['shared_with'].toString().isNotEmpty
              ? map['shared_with'].toString().split(',')
              : [],
      deletedAt: (map['deleted_at'] ?? map['deletedAt']) != null
          ? DateTime.parse(map['deleted_at'] ?? map['deletedAt'])
          : null,
      totalItems: map['total_items'] ?? map['totalItems'] ?? 0,
      checkedItems: map['checked_items'] ?? map['checkedItems'] ?? 0,
    );
  }

  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
    DateTime? lastModified,
    String? createdBy,
    bool? isDefault,
    List<String>? sharedWith,
    DateTime? deletedAt,
    bool restore = false,
    int? totalItems,
    int? checkedItems,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
      createdBy: createdBy ?? this.createdBy,
      isDefault: isDefault ?? this.isDefault,
      sharedWith: sharedWith ?? this.sharedWith,
      deletedAt: restore ? null : (deletedAt ?? this.deletedAt),
      totalItems: totalItems ?? this.totalItems,
      checkedItems: checkedItems ?? this.checkedItems,
    );
  }

  double get totalEstimatedCost => 0.0;
}

class PantryItem {
  String id;
  String name;
  String category;
  double quantity;
  String unit;
  DateTime purchaseDate;
  DateTime? expirationDate;
  String location;
  String? imageUrl;

  PantryItem({
    String? id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    this.expirationDate,
    required this.location,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final threeDaysFromNow = DateTime.now().add(const Duration(days: 3));
    return expirationDate!.isBefore(threeDaysFromNow) &&
        expirationDate!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: (map['quantity'] ?? 1).toDouble(),
      unit: map['unit'] ?? 'item',
      purchaseDate: DateTime.parse(map['purchase_date'] ?? map['purchaseDate']),
      expirationDate: (map['expiration_date'] ?? map['expirationDate']) != null
          ? DateTime.parse(map['expiration_date'] ?? map['expirationDate'])
          : null,
      location: map['location'] ?? 'Pantry',
      imageUrl: map['image_url'] ?? map['imageUrl'],
    );
  }
}

class Recipe {
  String id;
  String name;
  String? imageUrl;
  int servings;
  int prepTime;
  int cookTime;
  List<RecipeIngredient> ingredients;
  List<String> instructions;
  String cuisine;
  List<String> dietaryTags;
  bool isFavorite;
  String? instructionsText;

  Recipe({
    String? id,
    required this.name,
    this.imageUrl,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.ingredients,
    this.instructions = const [],
    this.cuisine = '',
    this.dietaryTags = const [],
    this.isFavorite = false,
    this.instructionsText,
  }) : id = id ?? const Uuid().v4();

  int get totalTime => prepTime + cookTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'servings': servings,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'instructions': instructions.join('|||'),
      'instructions_text': instructionsText ?? instructions.join('\n'),
      'cuisine': cuisine,
      'dietary_tags': dietaryTags,
      'is_favorite': isFavorite,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    final instr = map['instructions'] ?? map['instructions_text'] ?? '';
    final instructionList = instr is String && instr.contains('|||')
        ? instr.split('|||')
        : instr is String && instr.isNotEmpty
        ? instr.split('\n').where((s) => s.trim().isNotEmpty).toList()
        : <String>[];

    List<RecipeIngredient> parseIngredients(dynamic data) {
      if (data == null) return <RecipeIngredient>[];
      if (data is List) {
        return data.map((e) {
          if (e is Map<String, dynamic>) {
            return RecipeIngredient.fromMap(e);
          } else if (e is RecipeIngredient) {
            return e;
          }
          return RecipeIngredient(name: e.toString());
        }).toList();
      }
      return <RecipeIngredient>[];
    }

    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['image_url'] ?? map['imageUrl'],
      servings: map['servings'] ?? 4,
      prepTime: map['prep_time'] ?? map['prepTime'] ?? 15,
      cookTime: map['cook_time'] ?? map['cookTime'] ?? 30,
      ingredients: parseIngredients(map['ingredients'] ?? map['recipe_ingredients']),
      instructions: instructionList,
      cuisine: map['cuisine'] ?? '',
      dietaryTags: map['dietary_tags'] is List
          ? List<String>.from(map['dietary_tags'])
          : map['dietaryTags'] is String && (map['dietaryTags'] as String).isNotEmpty
              ? (map['dietaryTags'] as String).split(',')
              : <String>[],
      isFavorite: map['is_favorite'] ?? (map['isFavorite'] == 1),
      instructionsText: map['instructions_text'] ?? map['instructionsText'],
    );
  }
}

class RecipeIngredient {
  String name;
  double quantity;
  String unit;
  bool isOptional;

  RecipeIngredient({
    required this.name,
    this.quantity = 1,
    this.unit = 'item',
    this.isOptional = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'is_optional': isOptional,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 1).toDouble(),
      unit: map['unit'] ?? 'item',
      isOptional: map['is_optional'] ?? (map['isOptional'] == 1),
    );
  }
}

class TrashItem {
  String id;
  String name;
  String listName;
  DateTime deletedAt;
  String type;
  Map<String, dynamic>? originalData;

  TrashItem({
    required this.id,
    required this.name,
    required this.listName,
    required this.deletedAt,
    required this.type,
    this.originalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'listName': listName,
      'deletedAt': deletedAt.toIso8601String(),
      'type': type,
      'originalData': originalData,
    };
  }

  factory TrashItem.fromMap(Map<String, dynamic> map) {
    return TrashItem(
      id: map['id'],
      name: map['name'],
      listName: map['listName'],
      deletedAt: DateTime.parse(map['deletedAt']),
      type: map['type'] ?? 'item',
      originalData: map['originalData'],
    );
  }
}

class PurchaseHistoryItem {
  String id;
  String itemName;
  String category;
  double quantity;
  String unit;
  DateTime purchaseDate;
  String? store;

  PurchaseHistoryItem({
    String? id,
    required this.itemName,
    required this.category,
    this.quantity = 1,
    this.unit = 'item',
    DateTime? purchaseDate,
    this.store,
  }) : id = id ?? const Uuid().v4(),
       purchaseDate = purchaseDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate.toIso8601String(),
      'store': store,
    };
  }

  factory PurchaseHistoryItem.fromMap(Map<String, dynamic> map) {
    return PurchaseHistoryItem(
      id: map['id'],
      itemName: map['item_name'] ?? map['itemName'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 1).toDouble(),
      unit: map['unit'] ?? 'item',
      purchaseDate: DateTime.parse(map['purchase_date'] ?? map['purchaseDate']),
      store: map['store'],
    );
  }
}

