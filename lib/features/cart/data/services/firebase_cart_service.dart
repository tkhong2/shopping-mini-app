import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get cart items for current user
  Stream<List<Map<String, dynamic>>> getCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final cartRef = _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final doc = await cartRef.get();

      if (doc.exists) {
        // Update quantity if item already exists
        final currentQuantity = doc.data()?['quantity'] as int? ?? 0;
        await cartRef.update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartRef.set({
          'productId': productId,
          'productName': productName,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Added to cart: $productName');
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .delete();

      print('Removed from cart: $productId');
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('Cart cleared');
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 0;
      }

      final snapshot = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      return snapshot.docs.fold<int>(0, (sum, doc) {
        final quantity = doc.data()['quantity'] as int? ?? 0;
        return sum + quantity;
      });
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }
}
