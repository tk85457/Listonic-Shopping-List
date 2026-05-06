import 'package:isar/isar.dart';

part 'ml_tracking.g.dart';

@collection
class TypingPattern {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String pattern;

  late int frequency;
}

@collection
class RecentItem {
  Id id = Isar.autoIncrement;

  late String name;

  @Index()
  late DateTime addedAt;
}

@collection
class ItemFrequency {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late int frequency;
}

@collection
class ContextualSuggestion {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String patternKey;

  late List<String> suggestions;
}

