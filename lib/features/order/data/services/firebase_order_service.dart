import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new order
  Future<String> createOrder({
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required String address,
    required String paymentMethod,
    String? deliveryNote,
    double deliveryFee = 0,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final orderData = {
        'orderId': orderId,
        'userId': _currentUserId,
        'status': 'pending', // pending, confirmed, shipping, delivered, cancelled
        'statusText': 'Chờ xác nhận',
        'totalAmount': totalAmount,
        'deliveryFee': deliveryFee,
        'items': items,
        'address': address,
        'paymentMethod': paymentMethod,
        'deliveryNote': deliveryNote ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      print('✅ Order created successfully: $orderId');
      return orderId;
    } catch (e) {
      print('❌ Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Get all orders for current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    if (_currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Query without orderBy to avoid needing composite index
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      // Sort on client side
      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending
      orders.sort((a, b) {
        // Handle both Timestamp and String
        int aTime = 0;
        int bTime = 0;
        
        final aCreatedAt = a['createdAt'];
        if (aCreatedAt is Timestamp) {
          aTime = aCreatedAt.millisecondsSinceEpoch;
        } else if (aCreatedAt is String) {
          try {
            aTime = DateTime.parse(aCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            aTime = 0;
          }
        }
        
        final bCreatedAt = b['createdAt'];
        if (bCreatedAt is Timestamp) {
          bTime = bCreatedAt.millisecondsSinceEpoch;
        } else if (bCreatedAt is String) {
          try {
            bTime = DateTime.parse(bCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            bTime = 0;
          }
        }
        
        return bTime.compareTo(aTime);
      });

      return orders;
    } catch (e) {
      print('❌ Error getting user orders: $e');
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get orders by status
  Future<List<Map<String, dynamic>>> getUserOrdersByStatus(String status) async {
    if (_currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get all user orders first without orderBy to avoid composite index
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      // Filter by status and sort on client side
      final filteredOrders = querySnapshot.docs
          .where((doc) => doc.data()['status'] == status)
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();

      // Sort by createdAt descending
      filteredOrders.sort((a, b) {
        // Handle both Timestamp and String
        int aTime = 0;
        int bTime = 0;
        
        final aCreatedAt = a['createdAt'];
        if (aCreatedAt is Timestamp) {
          aTime = aCreatedAt.millisecondsSinceEpoch;
        } else if (aCreatedAt is String) {
          try {
            aTime = DateTime.parse(aCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            aTime = 0;
          }
        }
        
        final bCreatedAt = b['createdAt'];
        if (bCreatedAt is Timestamp) {
          bTime = bCreatedAt.millisecondsSinceEpoch;
        } else if (bCreatedAt is String) {
          try {
            bTime = DateTime.parse(bCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            bTime = 0;
          }
        }
        
        return bTime.compareTo(aTime);
      });

      return filteredOrders;
    } catch (e) {
      print('❌ Error getting orders by status: $e');
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get single order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        data?['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error getting order: $e');
      throw Exception('Failed to get order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status, String statusText) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'statusText': statusText,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order status updated: $orderId -> $status ($statusText)');
    } catch (e) {
      print('❌ Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'statusText': 'Đã hủy',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order cancelled: $orderId');
    } catch (e) {
      print('❌ Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Stream orders for real-time updates
  Stream<List<Map<String, dynamic>>> streamUserOrders() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // Query without orderBy to avoid composite index
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending on client side
      orders.sort((a, b) {
        // Handle both Timestamp and String
        int aTime = 0;
        int bTime = 0;
        
        final aCreatedAt = a['createdAt'];
        if (aCreatedAt is Timestamp) {
          aTime = aCreatedAt.millisecondsSinceEpoch;
        } else if (aCreatedAt is String) {
          try {
            aTime = DateTime.parse(aCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            aTime = 0;
          }
        }
        
        final bCreatedAt = b['createdAt'];
        if (bCreatedAt is Timestamp) {
          bTime = bCreatedAt.millisecondsSinceEpoch;
        } else if (bCreatedAt is String) {
          try {
            bTime = DateTime.parse(bCreatedAt).millisecondsSinceEpoch;
          } catch (e) {
            bTime = 0;
          }
        }
        
        return bTime.compareTo(aTime);
      });

      return orders;
    });
  }

  // Admin: Get all orders
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting all orders: $e');
      throw Exception('Failed to get orders: $e');
    }
  }

  // Admin: Stream all orders
  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
