import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class OrderItem {
  final String id;
  final String status;
  final DateTime createdAt;
  final double totalAmount;
  final List<OrderItemDetail> items;
  final String address;
  final String paymentMethod;

  OrderItem({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'address': address,
      'paymentMethod': paymentMethod,
    };
  }

  // Create from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => OrderItemDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
      address: json['address'] as String,
      paymentMethod: json['paymentMethod'] as String,
    );
  }
}

class OrderItemDetail {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  OrderItemDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
    };
  }

  // Create from JSON
  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class OrderProvider extends ChangeNotifier {
  static const String _storageKeyPrefix = 'user_orders_';
  final List<OrderItem> _orders = [];
  bool _isLoaded = false;
  String? _currentUserId;

  List<OrderItem> get orders => _orders;
  bool get isLoaded => _isLoaded;

  String _getStorageKey() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    return '$_storageKeyPrefix$userId';
  }

  // Load orders from local storage
  Future<void> loadOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest';
      
      // If user changed, reload
      if (_currentUserId != userId) {
        _currentUserId = userId;
        _isLoaded = false;
        _orders.clear();
      }

      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey();
      final ordersJson = prefs.getString(storageKey);

      debugPrint('Loading orders for user: $userId');
      debugPrint('Storage key: $storageKey');
      debugPrint('Orders JSON: $ordersJson');

      if (ordersJson != null && ordersJson.isNotEmpty) {
        final List<dynamic> ordersList = json.decode(ordersJson);
        _orders.clear();
        _orders.addAll(
          ordersList.map((orderJson) => OrderItem.fromJson(orderJson as Map<String, dynamic>)),
        );
        debugPrint('Loaded ${_orders.length} orders');
      } else {
        debugPrint('No orders found in storage');
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _isLoaded = true;
    }
  }

  // Save orders to local storage
  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey();
      final ordersJson = json.encode(_orders.map((order) => order.toJson()).toList());
      await prefs.setString(storageKey, ordersJson);
      debugPrint('Saved ${_orders.length} orders to storage with key: $storageKey');
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  List<OrderItem> getOrdersByStatus(String status) {
    if (status == 'Tất cả') return _orders;
    return _orders.where((order) => order.status == status).toList();
  }

  Future<void> addOrder({
    required String id,
    required double totalAmount,
    required List<OrderItemDetail> items,
    required String address,
    required String paymentMethod,
  }) async {
    final order = OrderItem(
      id: id,
      status: 'Chờ xác nhận',
      createdAt: DateTime.now(),
      totalAmount: totalAmount,
      items: items,
      address: address,
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      _orders[index] = OrderItem(
        id: oldOrder.id,
        status: newStatus,
        createdAt: oldOrder.createdAt,
        totalAmount: oldOrder.totalAmount,
        items: oldOrder.items,
        address: oldOrder.address,
        paymentMethod: oldOrder.paymentMethod,
      );
      await _saveOrders();
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'Đã hủy');
  }

  // Clear all orders (for testing or logout)
  Future<void> clearOrders() async {
    _orders.clear();
    await _saveOrders();
    notifyListeners();
  }
}
