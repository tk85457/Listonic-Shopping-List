import 'package:isar/isar.dart';

part 'local_models.g.dart';

@collection
class LocalShoppingList {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  late String name;
  late DateTime createdAt;
  late DateTime lastModified;
  late String createdBy;
  late bool isDefault;
  late List<String> sharedWith;
  late DateTime? deletedAt;

  late bool isSynced;
  late bool isDirty;

  late int totalItems;
  late int checkedItems;

  LocalShoppingList();
}

@collection
class LocalGroceryItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index()
  late String listId;

  late String name;
  late String category;
  late int quantity;
  late String unit;
  late bool isChecked;
  late String notes;
  late DateTime addedDate;
  late String addedBy;
  late DateTime? deletedAt;
  late String? imageUrl;
  late String storeAisle;

  late bool isSynced;
  late bool isDirty;

  LocalGroceryItem();
}

