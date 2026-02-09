import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ImportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Import products from assets/data/products.json to Firebase
  Future<void> importProductsFromAssets() async {
    try {
      print('Starting product import from assets...');
      
      // Step 1: Load products from JSON
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> productsJson = json.decode(jsonString);
      print('Loaded ${productsJson.length} products from JSON');
      
      // Step 2: Get category mapping (old ID -> Firebase document ID)
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final categoryMapping = <String, String>{};
      
      print('\nBuilding category mapping:');
      for (var doc in categoriesSnapshot.docs) {
        final data = doc.data();
        final oldId = data['id'] as String?;
        if (oldId != null && oldId.startsWith('cat_')) {
          categoryMapping[oldId] = doc.id;
          print('  $oldId -> ${doc.id} (${data['name']})');
        }
      }
      
      // Step 3: Import products
      int importedCount = 0;
      int skippedCount = 0;
      int updatedCount = 0;
      
      print('\nImporting products...');
      for (var productJson in productsJson) {
        final oldCategoryId = productJson['categoryId'] as String?;
        final productName = productJson['name'] as String? ?? 'Unknown';
        
        if (oldCategoryId == null) {
          print('⚠ Skipping "$productName": no categoryId');
          skippedCount++;
          continue;
        }
        
        // Map old categoryId to new Firebase document ID
        final newCategoryId = categoryMapping[oldCategoryId];
        if (newCategoryId == null) {
          print('⚠ Skipping "$productName": no mapping for $oldCategoryId');
          skippedCount++;
          continue;
        }
        
        // Prepare product data
        final productData = {
          'name': productJson['name'],
          'price': productJson['price'],
          'originalPrice': productJson['originalPrice'],
          'rating': (productJson['rating'] as num?)?.toDouble() ?? 0.0,
          'soldCount': productJson['soldCount'] ?? 0,
          'stock': productJson['stock'] ?? 0,
          'categoryId': newCategoryId, // Use new Firebase document ID
          'images': productJson['images'] ?? [],
          'description': productJson['description'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        // Check if product already exists by name
        final existingProducts = await _firestore
            .collection('products')
            .where('name', isEqualTo: productName)
            .limit(1)
            .get();
        
        if (existingProducts.docs.isNotEmpty) {
          // Update existing product
          final docId = existingProducts.docs.first.id;
          await _firestore.collection('products').doc(docId).update({
            ...productData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          updatedCount++;
          print('✓ Updated "$productName" (category: $oldCategoryId -> $newCategoryId)');
        } else {
          // Add new product
          await _firestore.collection('products').add(productData);
          importedCount++;
          print('✓ Imported "$productName" (category: $oldCategoryId -> $newCategoryId)');
        }
      }
      
      print('\n=== Import Summary ===');
      print('Total products in JSON: ${productsJson.length}');
      print('Imported (new): $importedCount');
      print('Updated (existing): $updatedCount');
      print('Skipped: $skippedCount');
      print('Import completed!');
    } catch (e, stackTrace) {
      print('Error during import: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
