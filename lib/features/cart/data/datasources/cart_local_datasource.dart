import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<void> addCartItem(CartItemModel item);
  Future<void> updateCartItem(CartItemModel item);
  Future<void> removeCartItem(String itemId);
  Future<void> clearCart();
  Stream<List<CartItemModel>> watchCartItems();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final StorageService storageService;
  static const String _cartKey = 'cart_items';

  CartLocalDataSourceImpl({required this.storageService});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final cartData = await storageService.getObject(_cartKey);
      if (cartData == null) return [];

      final items = cartData['items'] as List<dynamic>?;
      if (items == null) return [];

      return items
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cart items: $e');
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    try {
      final cartData = {
        'items': items.map((item) => item.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await storageService.setObject(_cartKey, cartData);
    } catch (e) {
      throw CacheException('Failed to save cart items: $e');
    }
  }

  @override
  Future<void> addCartItem(CartItemModel item) async {
    try {
      final currentItems = await getCartItems();
      
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

      await saveCartItems(currentItems);
    } catch (e) {
      throw CacheException('Failed to add cart item: $e');
    }
  }

  @override
  Future<void> updateCartItem(CartItemModel item) async {
    try {
      final currentItems = await getCartItems();
      final index = currentItems.indexWhere((i) => i.id == item.id);
      
      if (index == -1) {
        throw CacheException('Cart item not found');
      }

      currentItems[index] = item.copyWith(updatedAt: DateTime.now());
      await saveCartItems(currentItems);
    } catch (e) {
      throw CacheException('Failed to update cart item: $e');
    }
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    try {
      final currentItems = await getCartItems();
      currentItems.removeWhere((item) => item.id == itemId);
      await saveCartItems(currentItems);
    } catch (e) {
      throw CacheException('Failed to remove cart item: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await storageService.remove(_cartKey);
    } catch (e) {
      throw CacheException('Failed to clear cart: $e');
    }
  }

  @override
  Stream<List<CartItemModel>> watchCartItems() async* {
    // For simplicity, we'll just yield the current items
    // In a real app, you might use a StreamController to emit changes
    yield await getCartItems();
  }
}