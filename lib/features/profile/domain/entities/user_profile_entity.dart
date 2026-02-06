import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<AddressEntity> addresses;
  final UserPreferencesEntity preferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoUrl,
    this.dateOfBirth,
    this.gender,
    this.addresses = const [],
    required this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email;
  }

  AddressEntity? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? dateOfBirth,
    String? gender,
    List<AddressEntity>? addresses,
    UserPreferencesEntity? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        firstName,
        lastName,
        phoneNumber,
        photoUrl,
        dateOfBirth,
        gender,
        addresses,
        preferences,
        createdAt,
        updatedAt,
      ];
}

class AddressEntity extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  AddressEntity copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        isDefault,
      ];
}

class UserPreferencesEntity extends Equatable {
  final String language;
  final String currency;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String theme; // 'light', 'dark', 'system'

  const UserPreferencesEntity({
    this.language = 'vi',
    this.currency = 'VND',
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.theme = 'system',
  });

  UserPreferencesEntity copyWith({
    String? language,
    String? currency,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? theme,
  }) {
    return UserPreferencesEntity(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      theme: theme ?? this.theme,
    );
  }

  @override
  List<Object?> get props => [
        language,
        currency,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        theme,
      ];
}