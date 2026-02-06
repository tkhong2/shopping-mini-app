import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.images,
    required super.categoryId,
    required super.categoryName,
    required super.brand,
    required super.rating,
    required super.reviewCount,
    required super.soldCount,
    required super.stock,
    required super.isActive,
    super.tags,
    super.specifications,
    super.variants,
    required super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null 
          ? (json['originalPrice'] as num).toDouble() 
          : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      brand: json['brand'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      soldCount: json['soldCount'] as int? ?? 0,
      stock: json['stock'] as int,
      isActive: json['isActive'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'soldCount': soldCount,
      'stock': stock,
      'isActive': isActive,
      'tags': tags,
      'specifications': specifications,
      'variants': variants.map((v) => (v as ProductVariantModel).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      originalPrice: entity.originalPrice,
      images: entity.images,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      brand: entity.brand,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      soldCount: entity.soldCount,
      stock: entity.stock,
      isActive: entity.isActive,
      tags: entity.tags,
      specifications: entity.specifications,
      variants: entity.variants,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      images: images,
      categoryId: categoryId,
      categoryName: categoryName,
      brand: brand,
      rating: rating,
      reviewCount: reviewCount,
      soldCount: soldCount,
      stock: stock,
      isActive: isActive,
      tags: tags,
      specifications: specifications,
      variants: variants,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    required super.name,
    required super.type,
    required super.value,
    super.priceAdjustment,
    required super.stock,
    super.image,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      priceAdjustment: json['priceAdjustment'] != null 
          ? (json['priceAdjustment'] as num).toDouble() 
          : null,
      stock: json['stock'] as int,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'priceAdjustment': priceAdjustment,
      'stock': stock,
      'image': image,
    };
  }
}