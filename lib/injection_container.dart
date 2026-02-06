import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Core
import 'core/network/network_info.dart';

// Shared Services
import 'shared/services/storage_service.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Product
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/get_product_detail_usecase.dart';
import 'features/product/domain/usecases/get_products_by_category_usecase.dart';
import 'features/product/domain/usecases/search_products_usecase.dart';
import 'features/product/domain/usecases/get_product_reviews_usecase.dart';
import 'features/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'features/product/presentation/bloc/product_list/product_list_bloc.dart';

// Order
import 'features/order/presentation/bloc/checkout_bloc.dart';
import 'features/order/presentation/bloc/order_history_bloc.dart';

// Profile
import 'features/profile/presentation/provider/profile_provider.dart';

// Home
import 'features/home/presentation/provider/home_provider.dart';
import 'features/product/domain/usecases/get_product_reviews_usecase.dart';
import 'features/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'features/product/presentation/bloc/product_list/product_list_bloc.dart';

// Cart
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'features/cart/presentation/provider/cart_provider.dart';

// Wishlist
import 'features/wishlist/presentation/provider/wishlist_provider.dart';

// Temporary imports for other features - will be replaced with actual implementations
import 'temp_placeholders.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        forgotPasswordUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  //! Features - Product
  // Bloc
  sl.registerFactory(() => ProductDetailBloc(
        getProductDetailUseCase: sl(),
        getProductReviewsUseCase: sl(),
      ));
  sl.registerFactory(() => ProductListBloc(
        getProductsByCategoryUseCase: sl(),
        searchProductsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductReviewsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Home (Temporary placeholders)
  // Provider
  sl.registerFactory(() => HomeProvider(
        getBannersUseCase: null, // Temporary - using mock data
        getFlashSalesUseCase: null, // Temporary - using mock data
      ));

  // Use cases - Temporarily disabled
  // sl.registerLazySingleton(() => GetBannersUseCase(sl()));
  // sl.registerLazySingleton(() => GetFlashSalesUseCase(sl()));

  // Repository - Temporarily disabled
  // sl.registerLazySingleton<HomeRepository>(
  //   () => HomeRepositoryImpl(
  //     remoteDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );

  // Data sources - Temporarily disabled
  // sl.registerLazySingleton<HomeRemoteDataSource>(
  //   () => HomeRemoteDataSourceImpl(
  //     firestore: sl(),
  //   ),
  // );

  //! Features - Cart
  // Provider
  sl.registerFactory(() => CartProvider(
        addToCartUseCase: sl(),
        removeFromCartUseCase: sl(),
        updateCartQuantityUseCase: sl(),
        getCartItemsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(
      storageService: sl(),
    ),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Order (Temporary placeholders)
  // Bloc
  sl.registerFactory(() => CheckoutBloc(
        createOrderUseCase: sl(),
      ));
  sl.registerFactory(() => OrderHistoryBloc(
        getOrderHistoryUseCase: sl(),
        cancelOrderUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderHistoryUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! Features - Profile (Temporary placeholders)
  // Provider
  sl.registerFactory(() => ProfileProvider(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
      firebaseStorage: sl(),
    ),
  );

  //! Features - Wishlist
  // Provider
  sl.registerFactory(() => WishlistProvider(
        storageService: sl(),
      ));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! Shared Services
  sl.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(),
  );

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => http.Client());
}