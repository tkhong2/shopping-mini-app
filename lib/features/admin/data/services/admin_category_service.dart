import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Get all categories
  Stream<List<Map<String, dynamic>>> getCategories() {
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
          data['productCount'] = data['productCount'] ?? 0;
          return data;
        } catch (e) {
          print('Error parsing category: $e');
          return <String, dynamic>{};
        }
      }).where((data) => data.isNotEmpty).toList();
    });
  }

  // Add category
  Future<void> addCategory(Map<String, dynamic> category) async {
    category['createdAt'] = FieldValue.serverTimestamp();
    category['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).add(category);
  }

  // Update category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> category) async {
    category['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(categoryId).update(category);
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection(_collection).doc(categoryId).delete();
  }

  // Get category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    final doc = await _firestore.collection(_collection).doc(categoryId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  // Sync mock data to Firebase
  Future<void> syncMockDataToFirebase(List<Map<String, dynamic>> categories) async {
    final batch = _firestore.batch();
    
    for (var category in categories) {
      // Create a copy to avoid modifying original
      final categoryData = Map<String, dynamic>.from(category);
      
      // Ensure all required fields are present and not null
      categoryData['id'] = categoryData['id'] ?? '';
      categoryData['name'] = categoryData['name'] ?? '';
      categoryData['productCount'] = categoryData['productCount'] ?? 0;
      categoryData['createdAt'] = FieldValue.serverTimestamp();
      categoryData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, categoryData);
    }
    
    await batch.commit();
  }
}
