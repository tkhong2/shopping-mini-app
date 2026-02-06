import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? image;
  final String? parentId;
  final int order;
  final bool isActive;
  final int productCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.image,
    this.parentId,
    required this.order,
    required this.isActive,
    this.productCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isParentCategory => parentId == null;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        image,
        parentId,
        order,
        isActive,
        productCount,
        createdAt,
        updatedAt,
      ];
}