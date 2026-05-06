class AppCategories {
  static const String produce = 'Produce';
  static const String dairy = 'Dairy & Eggs';
  static const String meat = 'Meat & Seafood';
  static const String bakery = 'Bakery';
  static const String pantry = 'Pantry Staples';
  static const String frozen = 'Frozen Foods';
  static const String beverages = 'Beverages';
  static const String snacks = 'Snacks';
  static const String personalCare = 'Personal Care';
  static const String household = 'Household Items';
  static const String other = 'Other';

  static const List<String> all = [
    produce,
    dairy,
    meat,
    bakery,
    pantry,
    frozen,
    beverages,
    snacks,
    personalCare,
    household,
    other,
  ];

  static const List<String> aisles = [
    produce,
    meat,
    dairy,
    bakery,
    'Pantry',
    'Frozen',
    beverages,
    snacks,
    personalCare,
    'Household',
  ];

  static String getAisleForCategory(String category) {
    return aisles.contains(category) ? category : 'Pantry';
  }
}

