import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentMethod {
  cod, // Cash on delivery
  creditCard,
  debitCard,
  bankTransfer,
  eWallet,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final AddressEntity shippingAddress;
  final AddressEntity? billingAddress;
  final String? notes;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddress,
    this.billingAddress,
    this.notes,
    this.trackingNumber,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    List<CartItemEntity>? items,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    AddressEntity? shippingAddress,
    AddressEntity? billingAddress,
    String? notes,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        subtotal,
        shippingFee,
        tax,
        discount,
        total,
        status,
        paymentMethod,
        paymentStatus,
        shippingAddress,
        billingAddress,
        notes,
        trackingNumber,
        createdAt,
        updatedAt,
        deliveredAt,
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