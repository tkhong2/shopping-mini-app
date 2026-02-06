class RouteNames {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main Routes
  static const String home = '/home';
  static const String main = '/main';
  
  // Product Routes
  static const String productDetail = '/product/:id';
  static const String productList = '/products';
  static const String search = '/search';
  static const String category = '/category';
  static const String categoryDetail = '/category/:id';
  
  // Cart & Order Routes
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/orders';
  static const String orderDetail = '/order/:id';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String editAddress = '/profile/addresses/edit/:id';
  
  // Wishlist
  static const String wishlist = '/wishlist';
  
  // Settings
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String language = '/settings/language';
  static const String theme = '/settings/theme';
  
  // Help & Support
  static const String help = '/help';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
}