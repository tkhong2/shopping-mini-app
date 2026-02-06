import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    super.icon,
    super.image,
    super.parentId,
    required super.order,
    required super.isActive,
    super.productCount,
    required super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      parentId: json['parentId'] as String?,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
      productCount: json['productCount'] as int? ?? 0,
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
      'icon': icon,
      'image': image,
      'parentId': parentId,
      'order': order,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      image: image,
      parentId: parentId,
      order: order,
      isActive: isActive,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}