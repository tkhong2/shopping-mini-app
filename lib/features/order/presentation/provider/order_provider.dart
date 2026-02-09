import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_order_service.dart';

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
}

class OrderProvider extends ChangeNotifier {
  final FirebaseOrderService _orderService = FirebaseOrderService();
  final List<OrderItem> _orders = [];
  bool _isLoaded = false;
  String? _currentUserId;

  List<OrderItem> get orders => _orders;
  bool get isLoaded => _isLoaded;

  // Load orders from Firebase
  Future<void> loadOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      
      if (userId == null) {
        _orders.clear();
        _isLoaded = true;
        notifyListeners();
        return;
      }

      // If user changed, reload
      if (_currentUserId != userId) {
        _currentUserId = userId;
        _isLoaded = false;
        _orders.clear();
      }

      debugPrint('Loading orders for user: $userId');

      // Load from Firebase
      final ordersData = await _orderService.getUserOrders();
      
      _orders.clear();
      for (var orderData in ordersData) {
        final items = (orderData['items'] as List).map((item) {
          return OrderItemDetail(
            id: item['productId'] as String? ?? '',
            name: item['productName'] as String? ?? '',
            imageUrl: item['productImage'] as String? ?? '',
            quantity: item['quantity'] as int? ?? 0,
            price: (item['price'] as num?)?.toDouble() ?? 0,
          );
        }).toList();

        // Map status code to Vietnamese text
        final statusCode = orderData['status'] as String;
        final statusText = _mapStatusToText(statusCode);

        _orders.add(OrderItem(
          id: orderData['orderId'] as String,
          status: statusText,
          createdAt: (orderData['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
          totalAmount: (orderData['totalAmount'] as num).toDouble(),
          items: items,
          address: orderData['address'] as String,
          paymentMethod: orderData['paymentMethod'] as String,
        ));
      }

      debugPrint('Loaded ${_orders.length} orders from Firebase');

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  String _mapStatusToText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
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
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'Đã hủy');
  }

  // Clear all orders (for testing or logout)
  Future<void> clearOrders() async {
    _orders.clear();
    notifyListeners();
  }
}
