import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<void> syncCartItems(String userId, List<CartItemModel> items);
  Future<void> addCartItem(String userId, CartItemModel item);
  Future<void> updateCartItem(String userId, CartItemModel item);
  Future<void> removeCartItem(String userId, String itemId);
  Future<void> clearCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;

  CartRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final doc = await firestore
          .collection('carts')
          .doc(userId)
          .get();

      if (!doc.exists) return [];

      final data = doc.data()!;
      final items = data['items'] as List<dynamic>?;
      
      if (items == null) return [];

      return items
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get cart items: $e');
    }
  }

  @override
  Future<void> syncCartItems(String userId, List<CartItemModel> items) async {
    try {
      final cartData = {
        'items': items.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('carts')
          .doc(userId)
          .set(cartData, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to sync cart items: $e');
    }
  }

  @override
  Future<void> addCartItem(String userId, CartItemModel item) async {
    try {
      final currentItems = await getCartItems(userId);
      
      // Check if item with same product and variant already exists
      final existingIndex = currentItems.indexWhere((existingItem) =>
          existingItem.productId == item.productId &&
          existingItem.selectedVariantId == item.selectedVariantId);

      if (existingIndex != -1) {
        // Update quantity of existing item
        final existingItem = currentItems[existingIndex];
        final newQuantity = (existingItem.quantity + item.quantity)
            .clamp(1, existingItem.maxQuantity);
        
        currentItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
          updatedAt: DateTime.now(),
        );
      } else {
        // Add new item
        currentItems.add(item);
      }

      await syncCartItems(userId, currentItems);
    } catch (e) {
      throw ServerException('Failed to add cart item: $e');
    }
  }

  @override
  Future<void> updateCartItem(String userId, CartItemModel item) async {
    try {
      final currentItems = await getCartItems(userId);
      final index = currentItems.indexWhere((i) => i.id == item.id);
      
      if (index == -1) {
        throw ServerException('Cart item not found');
      }

      currentItems[index] = item.copyWith(updatedAt: DateTime.now());
      await syncCartItems(userId, currentItems);
    } catch (e) {
      throw ServerException('Failed to update cart item: $e');
    }
  }

  @override
  Future<void> removeCartItem(String userId, String itemId) async {
    try {
      final currentItems = await getCartItems(userId);
      currentItems.removeWhere((item) => item.id == itemId);
      await syncCartItems(userId, currentItems);
    } catch (e) {
      throw ServerException('Failed to remove cart item: $e');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await firestore
          .collection('carts')
          .doc(userId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to clear cart: $e');
    }
  }
}