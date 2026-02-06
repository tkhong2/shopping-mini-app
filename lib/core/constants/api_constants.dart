class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.shopping-app.com';
  static const String imageBaseUrl = 'https://images.shopping-app.com';
  
  // API Endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String forgotPassword = '$auth/forgot-password';
  static const String refreshToken = '$auth/refresh-token';
  
  static const String products = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String reviews = '/reviews';
  static const String banners = '/banners';
  static const String flashSales = '/flash-sales';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String cartsCollection = 'carts';
  static const String reviewsCollection = 'reviews';
  static const String bannersCollection = 'banners';
  static const String flashSalesCollection = 'flash_sales';
  
  // Storage Paths
  static const String productImagesPath = 'products';
  static const String userAvatarsPath = 'avatars';
  static const String categoryIconsPath = 'categories';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Cache Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartDataKey = 'cart_data';
  static const String wishlistDataKey = 'wishlist_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Request Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
