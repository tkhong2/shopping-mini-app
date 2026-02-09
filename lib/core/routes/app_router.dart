import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/simple_product_detail_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/search_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/order_history_page.dart';
import '../../features/order/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/addresses_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/help/presentation/pages/contact_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import '../../features/category/presentation/pages/category_page.dart';
import '../../features/category/presentation/pages/simple_category_page.dart';
import '../../features/product/presentation/pages/simple_search_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/admin_product_form_page.dart';
import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/admin_category_form_page.dart';
import '../../features/admin/presentation/pages/admin_orders_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../shared/widgets/main_wrapper.dart';
import '../../shared/widgets/splash_page.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // Splash Route
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Main App with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RouteNames.category,
            builder: (context, state) => const SimpleCategoryPage(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      // Product Routes
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return SimpleProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: RouteNames.productList,
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          final query = state.uri.queryParameters['query'];
          return ProductListPage(
            categoryId: categoryId,
            searchQuery: query,
          );
        },
      ),
      GoRoute(
        path: RouteNames.search,
        builder: (context, state) => const SimpleSearchPage(),
      ),
      
      // Cart Route
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      
      // Order Routes
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: RouteNames.orderHistory,
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailPage(orderId: orderId);
        },
      ),
      
      // Profile Routes
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RouteNames.addresses,
        builder: (context, state) => const AddressesPage(),
      ),
      
      // Help Routes
      GoRoute(
        path: RouteNames.help,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: RouteNames.contact,
        builder: (context, state) => const ContactPage(),
      ),
      
      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      
      // Settings
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsPage(),
      ),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, state) => const AdminProductFormPage(),
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          final product = state.extra as Map<String, dynamic>?;
          return AdminProductFormPage(
            productId: productId,
            product: product,
          );
        },
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoriesPage(),
      ),
      GoRoute(
        path: '/admin/categories/add',
        builder: (context, state) => const AdminCategoryFormPage(),
      ),
      GoRoute(
        path: '/admin/categories/edit/:id',
        builder: (context, state) {
          final categoryId = state.pathParameters['id'];
          final category = state.extra as Map<String, dynamic>?;
          return AdminCategoryFormPage(
            categoryId: categoryId,
            category: category,
          );
        },
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Trang không tồn tại',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
  
  static GoRouter get router => _router;
}