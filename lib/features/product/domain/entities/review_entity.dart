import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final String? variantInfo;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    required this.isVerifiedPurchase,
    this.helpfulCount = 0,
    this.variantInfo,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userAvatar,
        rating,
        comment,
        images,
        createdAt,
        updatedAt,
        isVerifiedPurchase,
        helpfulCount,
        variantInfo,
      ];
}