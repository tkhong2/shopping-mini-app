import 'package:flutter/foundation.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../../shared/services/storage_service.dart';

class WishlistProvider extends ChangeNotifier {
  final StorageService storageService;
  static const String _wishlistKey = 'wishlist_items';

  WishlistProvider({required this.storageService});

  List<ProductEntity> _wishlistItems = [];
  bool _isLoading = false;

  List<ProductEntity> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  int get itemCount => _wishlistItems.length;

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  Future<void> loadWishlist() async {
    _setLoading(true);
    
    try {
      final wishlistData = await storageService.getObject(_wishlistKey);
      if (wishlistData != null) {
        final items = wishlistData['items'] as List<dynamic>?;
        if (items != null) {
          _wishlistItems = items
              .map((item) => _productFromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
    
    _setLoading(false);
  }

  Future<void> addToWishlist(ProductEntity product) async {
    if (isInWishlist(product.id)) return;

    _wishlistItems.add(product);
    notifyListeners();
    
    await _saveWishlist();
  }

  Future<void> removeFromWishlist(String productId) async {
    _wishlistItems.removeWhere((item) => item.id == productId);
    notifyListeners();
    
    await _saveWishlist();
  }

  Future<void> toggleWishlist(ProductEntity product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }

  Future<void> clearWishlist() async {
    _wishlistItems.clear();
    notifyListeners();
    
    await storageService.remove(_wishlistKey);
  }

  Future<void> _saveWishlist() async {
    try {
      final wishlistData = {
        'items': _wishlistItems.map((item) => _productToJson(item)).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await storageService.setObject(_wishlistKey, wishlistData);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper methods for JSON serialization
  Map<String, dynamic> _productToJson(ProductEntity product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'images': product.images,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'brand': product.brand,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'soldCount': product.soldCount,
      'stock': product.stock,
      'isInStock': product.isInStock,
      'tags': product.tags,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt?.toIso8601String(),
    };
  }

  ProductEntity _productFromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null 
          ? (json['originalPrice'] as num).toDouble() 
          : null,
      images: List<String>.from(json['images'] as List),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      brand: json['brand'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      soldCount: json['soldCount'] as int,
      stock: json['stock'] as int,
      isActive: json['isInStock'] as bool? ?? true,
      tags: List<String>.from(json['tags'] as List? ?? []),
      variants: [], // Simplified for wishlist
      specifications: {}, // Simplified for wishlist
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}