import 'package:flutter/foundation.dart';
import '../../domain/entities/cart_item_entity.dart';

class SimpleCartProvider extends ChangeNotifier {
  final List<CartItemEntity> _items = [];
  
  List<CartItemEntity> get items => _items;
  
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  
  List<CartItemEntity> get selectedItems => 
      _items.where((item) => item.isSelected).toList();

  double get totalPrice => selectedItems.fold(
      0, (sum, item) => sum + (item.price * item.quantity));

  double get originalTotalPrice => selectedItems.fold(
      0, (sum, item) => sum + ((item.originalPrice ?? item.price) * item.quantity));

  double get totalDiscount => originalTotalPrice - totalPrice;

  bool get hasSelectedItems => selectedItems.isNotEmpty;

  void addToCart(CartItemEntity item) {
    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (i) => i.productId == item.productId && 
             i.selectedVariantId == item.selectedVariantId
    );

    if (existingIndex >= 0) {
      // Update quantity
      final existingItem = _items[existingIndex];
      final newQuantity = (existingItem.quantity + item.quantity)
          .clamp(1, existingItem.maxQuantity);
      _items[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
    } else {
      // Add new item
      _items.add(item);
    }
    
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];
    final clampedQuantity = newQuantity.clamp(1, item.maxQuantity);
    
    if (clampedQuantity == item.quantity) return;

    _items[itemIndex] = item.copyWith(
      quantity: clampedQuantity,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void toggleItemSelection(String itemId) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];
    _items[itemIndex] = item.copyWith(
      isSelected: !item.isSelected,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }

  void selectAllItems(bool selected) {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(
        isSelected: selected,
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }
}
