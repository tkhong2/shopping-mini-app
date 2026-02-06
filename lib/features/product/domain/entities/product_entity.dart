import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final String brand;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final int stock;
  final bool isActive;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final List<ProductVariantEntity> variants;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
    required this.stock,
    required this.isActive,
    this.tags = const [],
    this.specifications = const {},
    this.variants = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage => hasDiscount 
      ? ((originalPrice! - price) / originalPrice!) * 100 
      : 0;

  bool get isInStock => stock > 0;

  String get mainImage => images.isNotEmpty ? images.first : '';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        images,
        categoryId,
        categoryName,
        brand,
        rating,
        reviewCount,
        soldCount,
        stock,
        isActive,
        tags,
        specifications,
        variants,
        createdAt,
        updatedAt,
      ];
}

class ProductVariantEntity extends Equatable {
  final String id;
  final String name;
  final String type; // 'color', 'size', 'storage', etc.
  final String value;
  final double? priceAdjustment;
  final int stock;
  final String? image;

  const ProductVariantEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.priceAdjustment,
    required this.stock,
    this.image,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        value,
        priceAdjustment,
        stock,
        image,
      ];
}