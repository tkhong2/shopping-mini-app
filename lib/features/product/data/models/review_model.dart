import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.rating,
    required super.comment,
    super.images,
    required super.createdAt,
    super.updatedAt,
    required super.isVerifiedPurchase,
    super.helpfulCount,
    super.variantInfo,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      variantInfo: json['variantInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'variantInfo': variantInfo,
    };
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      images: entity.images,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isVerifiedPurchase: entity.isVerifiedPurchase,
      helpfulCount: entity.helpfulCount,
      variantInfo: entity.variantInfo,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVerifiedPurchase: isVerifiedPurchase,
      helpfulCount: helpfulCount,
      variantInfo: variantInfo,
    );
  }
}