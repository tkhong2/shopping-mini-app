import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Get products by category
  Stream<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) {
    print('FirebaseProductService: Getting products for category: $categoryId');
    
    // Simply query products where categoryId matches
    // Products should already have the correct Firebase document ID as categoryId
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      print('FirebaseProductService: Found ${snapshot.docs.length} products for category $categoryId');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('  - Product: ${data['name']} (categoryId: ${data['categoryId']})');
        return data;
      }).toList();
    }).handleError((error) {
      print('FirebaseProductService Error: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Search products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final snapshot = await _firestore.collection('products').get();
      final lowerQuery = query.toLowerCase();
      
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] as String? ?? '').toLowerCase();
        final description = (data['description'] as String? ?? '').toLowerCase();
        return name.contains(lowerQuery) || description.contains(lowerQuery);
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get flash sale products (first 10, newest first)
  Stream<List<Map<String, dynamic>>> getFlashSaleProducts() {
    print('FirebaseProductService: Getting flash sale products...');
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      print('FirebaseProductService: Received ${snapshot.docs.length} flash sale products');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('Product: ${data['name']}');
        return data;
      }).toList();
    }).handleError((error) {
      print('FirebaseProductService Error: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Get top deals (first 12, newest first)
  Stream<List<Map<String, dynamic>>> getTopDeals() {
    print('FirebaseProductService: Getting top deals...');
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(12)
        .snapshots()
        .map((snapshot) {
      print('FirebaseProductService: Received ${snapshot.docs.length} top deals');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((error) {
      print('FirebaseProductService Error: $error');
      return <Map<String, dynamic>>[];
    });
  }
}
