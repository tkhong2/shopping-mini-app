import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems(String? userId) async {
    try {
      // Always get local cart first for immediate response
      final localItems = await localDataSource.getCartItems();
      
      // If user is logged in and has network, sync with remote
      if (userId != null && await networkInfo.isConnected) {
        try {
          final remoteItems = await remoteDataSource.getCartItems(userId);
          
          // Merge local and remote items (remote takes precedence)
          final mergedItems = _mergeCartItems(localItems, remoteItems);
          
          // Update local storage with merged items
          await localDataSource.saveCartItems(mergedItems);
          
          return Right(mergedItems.map((item) => item.toEntity()).toList());
        } catch (e) {
          // If remote fails, return local items
          return Right(localItems.map((item) => item.toEntity()).toList());
        }
      }
      
      return Right(localItems.map((item) => item.toEntity()).toList());
    } on CacheException {
      return Left(CacheFailure('Failed to load cart items from cache'));
    } catch (e) {
      return Left(ServerFailure('Failed to load cart items: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity item, String? userId) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(item);
      
      // Add to local storage first
      await localDataSource.addCartItem(cartItemModel);
      
      // If user is logged in and has network, sync with remote
      if (userId != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.addCartItem(userId, cartItemModel);
        } catch (e) {
          // Continue even if remote sync fails
        }
      }
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Failed to add item to cart cache'));
    } catch (e) {
      return Left(ServerFailure('Failed to add item to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCartItem(CartItemEntity item, String? userId) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(item);
      
      // Update local storage first
      await localDataSource.updateCartItem(cartItemModel);
      
      // If user is logged in and has network, sync with remote
      if (userId != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateCartItem(userId, cartItemModel);
        } catch (e) {
          // Continue even if remote sync fails
        }
      }
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Failed to update cart item in cache'));
    } catch (e) {
      return Left(ServerFailure('Failed to update cart item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId, String? userId) async {
    try {
      // Remove from local storage first
      await localDataSource.removeCartItem(itemId);
      
      // If user is logged in and has network, sync with remote
      if (userId != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.removeCartItem(userId, itemId);
        } catch (e) {
          // Continue even if remote sync fails
        }
      }
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Failed to remove item from cart cache'));
    } catch (e) {
      return Left(ServerFailure('Failed to remove item from cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart(String? userId) async {
    try {
      // Clear local storage first
      await localDataSource.clearCart();
      
      // If user is logged in and has network, sync with remote
      if (userId != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.clearCart(userId);
        } catch (e) {
          // Continue even if remote sync fails
        }
      }
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Failed to clear cart cache'));
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncCart(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final localItems = await localDataSource.getCartItems();
      await remoteDataSource.syncCartItems(userId, localItems);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Failed to sync cart with server'));
    } catch (e) {
      return Left(ServerFailure('Failed to sync cart: ${e.toString()}'));
    }
  }

  @override
  Stream<List<CartItemEntity>> watchCartItems() async* {
    await for (final items in localDataSource.watchCartItems()) {
      yield items.map((item) => item.toEntity()).toList();
    }
  }

  // Helper method to merge local and remote cart items
  List<CartItemModel> _mergeCartItems(
    List<CartItemModel> localItems,
    List<CartItemModel> remoteItems,
  ) {
    final Map<String, CartItemModel> mergedMap = {};
    
    // Add local items first
    for (final item in localItems) {
      final key = '${item.productId}_${item.selectedVariantId ?? ''}';
      mergedMap[key] = item;
    }
    
    // Override with remote items (they take precedence)
    for (final item in remoteItems) {
      final key = '${item.productId}_${item.selectedVariantId ?? ''}';
      mergedMap[key] = item;
    }
    
    return mergedMap.values.toList();
  }
}