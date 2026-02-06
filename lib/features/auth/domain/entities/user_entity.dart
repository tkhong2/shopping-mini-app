import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> addresses;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoURL,
    required this.createdAt,
    this.updatedAt,
    this.addresses = const [],
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        phoneNumber,
        photoURL,
        createdAt,
        updatedAt,
        addresses,
        isEmailVerified,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? addresses,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}