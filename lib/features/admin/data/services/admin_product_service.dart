import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get all products
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          // Ensure all fields have default values
          data['name'] = data['name'] ?? '';
          data['price'] = data['price'] ?? 0.0;
          data['originalPrice'] = data['originalPrice'] ?? 0.0;
          data['rating'] = data['rating'] ?? 0.0;
          data['soldCount'] = data['soldCount'] ?? 0;
          data['stock'] = data['stock'] ?? 0;
          data['categoryId'] = data['categoryId'] ?? '';
          data['images'] = data['images'] ?? [];
          data['description'] = data['description'] ?? '';
          return data;
        } catch (e) {
          print('Error parsing product: $e');
          return <String, dynamic>{};
        }
      }).where((data) => data.isNotEmpty).toList();
    });
  }

  // Add product
  Future<void> addProduct(Map<String, dynamic> product) async {
    product['createdAt'] = FieldValue.serverTimestamp();
    product['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).add(product);
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> product) async {
    product['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(productId).update(product);
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection(_collection).doc(productId).delete();
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final doc = await _firestore.collection(_collection).doc(productId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  // Update product stock
  Future<void> updateStock(String productId, int stock) async {
    await _firestore.collection(_collection).doc(productId).update({
      'stock': stock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sync mock data to Firebase (one-time operation)
  Future<void> syncMockDataToFirebase(List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();
    
    for (var product in products) {
      // Create a copy to avoid modifying original
      final productData = Map<String, dynamic>.from(product);
      
      // Ensure all required fields are present and not null
      productData['id'] = productData['id'] ?? '';
      productData['name'] = productData['name'] ?? '';
      productData['price'] = productData['price'] ?? 0.0;
      productData['originalPrice'] = productData['originalPrice'] ?? 0.0;
      productData['rating'] = productData['rating'] ?? 0.0;
      productData['soldCount'] = productData['soldCount'] ?? 0;
      productData['stock'] = productData['stock'] ?? 0;
      productData['categoryId'] = productData['categoryId'] ?? '';
      productData['images'] = productData['images'] ?? [];
      productData['description'] = productData['description'] ?? '';
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, productData);
    }
    
    await batch.commit();
  }
}
