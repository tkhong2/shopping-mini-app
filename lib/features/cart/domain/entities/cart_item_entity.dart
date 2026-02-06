import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String? selectedVariantId;
  final Map<String, String> selectedVariants;
  final bool isSelected;
  final bool isInStock;
  final int maxQuantity;
  final DateTime addedAt;
  final DateTime? updatedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.originalPrice,
    required this.quantity,
    this.selectedVariantId,
    this.selectedVariants = const {},
    this.isSelected = true,
    this.isInStock = true,
    required this.maxQuantity,
    required this.addedAt,
    this.updatedAt,
  });

  double get totalPrice => price * quantity;
  
  double get originalTotalPrice => (originalPrice ?? price) * quantity;
  
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountAmount => hasDiscount 
      ? (originalPrice! - price) * quantity 
      : 0;

  String get variantDisplayText {
    if (selectedVariants.isEmpty) return '';
    return selectedVariants.values.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        price,
        originalPrice,
        quantity,
        selectedVariantId,
        selectedVariants,
        isSelected,
        isInStock,
        maxQuantity,
        addedAt,
        updatedAt,
      ];

  CartItemEntity copyWith({
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
    return CartItemEntity(
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