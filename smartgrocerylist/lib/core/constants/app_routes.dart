class AppRoutes {
  static const String splash = '/splash';
  static const String authCheck = '/auth-check';
  static const String signIn = '/signin';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String trash = '/trash';
  static const String help = '/help';
  static const String privacy = '/privacy';
  static const String listDetail = '/list/:id';
  static const String addItem = '/add-item/:id';
  static const String editItem = '/edit-item/:id';
  static const String objectDetection = '/object-detection/:id';

  // Helper method to generate parameterized routes
  static String getListDetailRoute(String id) => '/list/$id';
  static String getAddItemRoute(String id) => '/add-item/$id';
  static String getEditItemRoute(String id) => '/edit-item/$id';
  static String getObjectDetectionRoute(String id) => '/object-detection/$id';
}

