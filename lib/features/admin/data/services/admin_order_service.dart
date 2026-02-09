import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Get all orders
  Stream<List<Map<String, dynamic>>> getOrders() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Convert Timestamp to DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        return data;
      }).toList();
      
      // Sort by createdAt if available
      docs.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];
        if (aDate is DateTime && bDate is DateTime) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });
      
      return docs;
    });
  }

  // Get orders by status
  Stream<List<Map<String, dynamic>>> getOrdersByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        return data;
      }).toList();
      
      // Sort by createdAt if available
      docs.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];
        if (aDate is DateTime && bDate is DateTime) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });
      
      return docs;
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status, String statusText) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'status': status,
      'statusText': statusText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final doc = await _firestore.collection(_collection).doc(orderId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }
      return data;
    }
    return null;
  }

  // Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    final snapshot = await _firestore.collection(_collection).get();
    
    final stats = {
      'total': snapshot.docs.length,
      'pending': 0,
      'processing': 0,
      'shipping': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null && stats.containsKey(status)) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection(_collection).doc(orderId).delete();
  }
}
