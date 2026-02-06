import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCartItems(String? userId);
  Future<Either<Failure, void>> addToCart(CartItemEntity item, String? userId);
  Future<Either<Failure, void>> updateCartItem(CartItemEntity item, String? userId);
  Future<Either<Failure, void>> removeFromCart(String itemId, String? userId);
  Future<Either<Failure, void>> clearCart(String? userId);
  Future<Either<Failure, void>> syncCart(String userId);
  Stream<List<CartItemEntity>> watchCartItems();
}