import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.price,
    super.originalPrice,
    required super.quantity,
    super.selectedVariantId,
    super.selectedVariants,
    super.isSelected,
    super.isInStock,
    required super.maxQuantity,
    required super.addedAt,
    super.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null 
          ? (json['originalPrice'] as num).toDouble() 
          : null,
      quantity: json['quantity'] as int,
      selectedVariantId: json['selectedVariantId'] as String?,
      selectedVariants: json['selectedVariants'] != null
          ? Map<String, String>.from(json['selectedVariants'] as Map)
          : {},
      isSelected: json['isSelected'] as bool? ?? true,
      isInStock: json['isInStock'] as bool? ?? true,
      maxQuantity: json['maxQuantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'selectedVariantId': selectedVariantId,
      'selectedVariants': selectedVariants,
      'isSelected': isSelected,
      'isInStock': isInStock,
      'maxQuantity': maxQuantity,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      productImage: entity.productImage,
      price: entity.price,
      originalPrice: entity.originalPrice,
      quantity: entity.quantity,
      selectedVariantId: entity.selectedVariantId,
      selectedVariants: entity.selectedVariants,
      isSelected: entity.isSelected,
      isInStock: entity.isInStock,
      maxQuantity: entity.maxQuantity,
      addedAt: entity.addedAt,
      updatedAt: entity.updatedAt,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      originalPrice: originalPrice,
      quantity: quantity,
      selectedVariantId: selectedVariantId,
      selectedVariants: selectedVariants,
      isSelected: isSelected,
      isInStock: isInStock,
      maxQuantity: maxQuantity,
      addedAt: addedAt,
      updatedAt: updatedAt,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? originalPrice,
    int? quantity,
    String? selectedVariantId,
    Map<String, String>? selectedVariants,
    bool? isSelected,
    bool? isInStock,
    int? maxQuantity,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      isSelected: isSelected ?? this.isSelected,
      isInStock: isInStock ?? this.isInStock,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}