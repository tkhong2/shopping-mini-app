import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.phoneNumber,
    super.photoURL,
    required super.createdAt,
    super.updatedAt,
    super.addresses,
    super.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse DateTime from either Timestamp or String
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now();
      }
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      photoURL: json['photoURL'] as String?,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? parseDateTime(json['updatedAt'])
          : null,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'addresses': addresses,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      photoURL: entity.photoURL,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      addresses: entity.addresses,
      isEmailVerified: entity.isEmailVerified,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoURL: photoURL,
      createdAt: createdAt,
      updatedAt: updatedAt,
      addresses: addresses,
      isEmailVerified: isEmailVerified,
    );
  }
}