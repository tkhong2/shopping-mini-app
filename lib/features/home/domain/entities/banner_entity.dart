import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String actionType; // 'product', 'category', 'url', 'none'
  final String? actionValue;
  final bool isActive;
  final int priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BannerEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.actionType,
    this.actionValue,
    required this.isActive,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }
    
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }
    
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        actionType,
        actionValue,
        isActive,
        priority,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}