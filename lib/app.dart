import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_router.dart';
import 'injection_container.dart' as di;

// Providers
import 'features/home/presentation/provider/home_provider.dart';
import 'features/cart/presentation/provider/simple_cart_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/profile/presentation/provider/address_provider.dart';
import 'features/wishlist/presentation/provider/wishlist_provider.dart';
import 'features/notifications/presentation/provider/notification_provider.dart';
import 'features/order/presentation/provider/order_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/widgets/auth_state_listener.dart';

// BLoCs
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'features/product/presentation/bloc/product_list/product_list_bloc.dart';
import 'features/order/presentation/bloc/checkout_bloc.dart';
import 'features/order/presentation/bloc/order_history_bloc.dart';

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        
        // Feature Providers
        ChangeNotifierProvider(
          create: (_) => di.sl<HomeProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => SimpleCartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AddressProvider();
            provider.loadAddresses(); // Load addresses on startup
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<WishlistProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = OrderProvider();
            provider.loadOrders(); // Load orders on startup
            return provider;
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AuthBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProductDetailBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProductListBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<CheckoutBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<OrderHistoryBloc>(),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AuthStateListener(
              child: MaterialApp.router(
                title: 'Shopping App',
                debugShowCheckedModeBanner: false,
                
                // Theme
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: themeProvider.themeMode,
                
                // Router
                routerConfig: AppRouter.router,
              
                // Localization (TODO: Add later)
                // locale: const Locale('vi', 'VN'),
                // localizationsDelegates: const [
                //   GlobalMaterialLocalizations.delegate,
                //   GlobalWidgetsLocalizations.delegate,
                //   GlobalCupertinoLocalizations.delegate,
                // ],
                // supportedLocales: const [
                //   Locale('vi', 'VN'),
                //   Locale('en', 'US'),
                // ],
              ),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      
      // Primary Colors
      primarySwatch: _createMaterialColor(AppColors.primary),
      primaryColor: AppColors.primary,
      
      // Background Colors
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      
      // Primary Colors
      primarySwatch: _createMaterialColor(AppColors.primary),
      primaryColor: AppColors.primary,
      
      // Background Colors
      scaffoldBackgroundColor: AppColors.surfaceDark,
      canvasColor: const Color(0xFF1E1E1E),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textWhite,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}