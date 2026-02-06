import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';

class CartProvider extends ChangeNotifier {
  final AddToCartUseCase addToCartUseCase;
  final GetCartItemsUseCase getCartItemsUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;

  CartProvider({
    required this.addToCartUseCase,
    required this.getCartItemsUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
  });

  List<CartItemEntity> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemEntity> get items => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  List<CartItemEntity> get selectedItems => 
      _cartItems.where((item) => item.isSelected).toList();

  double get totalPrice => selectedItems.fold(
      0, (sum, item) => sum + item.totalPrice);

  double get originalTotalPrice => selectedItems.fold(
      0, (sum, item) => sum + item.originalTotalPrice);

  double get totalDiscount => originalTotalPrice - totalPrice;

  bool get hasSelectedItems => selectedItems.isNotEmpty;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadCartItems() async {
    _setLoading(true);
    _setError(null);

    final result = await getCartItemsUseCase(
      GetCartItemsParams(userId: _currentUserId),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (items) => _cartItems = items,
    );

    _setLoading(false);
  }

  Future<void> addToCart(CartItemEntity item) async {
    _setError(null);

    final result = await addToCartUseCase(
      AddToCartParams(item: item, userId: _currentUserId),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) => loadCartItems(), // Reload to get updated cart
    );
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = _cartItems[itemIndex];
    final clampedQuantity = newQuantity.clamp(1, item.maxQuantity);
    
    if (clampedQuantity == item.quantity) return;

    final updatedItem = item.copyWith(
      quantity: clampedQuantity,
      updatedAt: DateTime.now(),
    );

    // Optimistic update
    _cartItems[itemIndex] = updatedItem;
    notifyListeners();

    final result = await updateCartQuantityUseCase(
      UpdateCartQuantityParams(item: updatedItem, userId: _currentUserId),
    );

    result.fold(
      (failure) {
        // Revert on failure
        _cartItems[itemIndex] = item;
        _setError(_mapFailureToMessage(failure));
      },
      (_) {}, // Success - keep the optimistic update
    );
  }

  Future<void> removeItem(String itemId) async {
    final originalItems = List<CartItemEntity>.from(_cartItems);
    
    // Optimistic update
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();

    final result = await removeFromCartUseCase(
      RemoveFromCartParams(itemId: itemId, userId: _currentUserId),
    );

    result.fold(
      (failure) {
        // Revert on failure
        _cartItems = originalItems;
        _setError(_mapFailureToMessage(failure));
      },
      (_) {}, // Success - keep the optimistic update
    );
  }

  void toggleItemSelection(String itemId) {
    final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = _cartItems[itemIndex];
    final updatedItem = item.copyWith(
      isSelected: !item.isSelected,
      updatedAt: DateTime.now(),
    );

    _cartItems[itemIndex] = updatedItem;
    notifyListeners();

    // Update in background
    updateCartQuantityUseCase(
      UpdateCartQuantityParams(item: updatedItem, userId: _currentUserId),
    );
  }

  void selectAllItems(bool selected) {
    _cartItems = _cartItems.map((item) => 
        item.copyWith(isSelected: selected, updatedAt: DateTime.now())).toList();
    notifyListeners();

    // Update all items in background
    for (final item in _cartItems) {
      updateCartQuantityUseCase(
        UpdateCartQuantityParams(item: item, userId: _currentUserId),
      );
    }
  }

  void clearError() {
    _setError(null);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType) {
      case const (CacheFailure):
        return 'Lỗi lưu trữ cục bộ';
      case const (ServerFailure):
        return 'Lỗi máy chủ';
      case const (NetworkFailure):
        return 'Không có kết nối mạng';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }
}

// Failure classes for type checking
class CacheFailure {}
class ServerFailure {}
class NetworkFailure {}