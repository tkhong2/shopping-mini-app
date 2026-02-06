import 'package:equatable/equatable.dart';

class FlashSaleEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double originalPrice;
  final double salePrice;
  final int discountPercentage;
  final int quantity;
  final int sold;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FlashSaleEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercentage,
    required this.quantity,
    required this.sold,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endTime);
  }

  bool get isSoldOut {
    return sold >= quantity;
  }

  int get remainingQuantity {
    return quantity - sold;
  }

  // Compatibility property
  int get soldQuantity => sold;

  double get soldPercentage {
    if (quantity == 0) return 0;
    return (sold / quantity) * 100;
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) {
      return Duration.zero;
    }
    return endTime.difference(now);
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        originalPrice,
        salePrice,
        discountPercentage,
        quantity,
        sold,
        startTime,
        endTime,
        isActive,
        createdAt,
        updatedAt,
      ];
}