import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ResetDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Delete all products and categories, then import fresh data from JSON
  Future<void> resetDatabase() async {
    try {
      print('=== STARTING DATABASE RESET ===\n');
      
      // Step 1: Delete all products
      print('Step 1: Deleting all products...');
      final productsSnapshot = await _firestore.collection('products').get();
      print('Found ${productsSnapshot.docs.length} products to delete');
      
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✓ Deleted all products\n');
      
      // Step 2: Delete all categories
      print('Step 2: Deleting all categories...');
      final categoriesSnapshot = await _firestore.collection('categories').get();
      print('Found ${categoriesSnapshot.docs.length} categories to delete');
      
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✓ Deleted all categories\n');
      
      // Step 3: Import categories from JSON
      print('Step 3: Importing categories from JSON...');
      final String categoriesJson = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> categoriesData = json.decode(categoriesJson);
      
      final categoryMapping = <String, String>{}; // old ID -> new Firebase doc ID
      
      for (var categoryJson in categoriesData) {
        final oldId = categoryJson['id'] as String;
        final categoryData = {
          'id': oldId, // Keep old ID as a field for reference
          'name': categoryJson['name'],
          'icon': categoryJson['icon'],
          'productCount': categoryJson['productCount'] ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        final docRef = await _firestore.collection('categories').add(categoryData);
        categoryMapping[oldId] = docRef.id;
        print('✓ Imported category: ${categoryJson['name']} ($oldId -> ${docRef.id})');
      }
      print('✓ Imported ${categoriesData.length} categories\n');
      
      // Step 4: Import products from JSON with mapped category IDs
      print('Step 4: Importing products from JSON...');
      final String productsJson = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> productsData = json.decode(productsJson);
      
      int importedCount = 0;
      int skippedCount = 0;
      
      for (var productJson in productsData) {
        final oldCategoryId = productJson['categoryId'] as String?;
        final productName = productJson['name'] as String? ?? 'Unknown';
        
        if (oldCategoryId == null) {
          print('⚠ Skipping "$productName": no categoryId');
          skippedCount++;
          continue;
        }
        
        final newCategoryId = categoryMapping[oldCategoryId];
        if (newCategoryId == null) {
          print('⚠ Skipping "$productName": no mapping for $oldCategoryId');
          skippedCount++;
          continue;
        }
        
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
        
        await _firestore.collection('products').add(productData);
        importedCount++;
        
        if (importedCount % 10 == 0) {
          print('  Imported $importedCount products...');
        }
      }
      
      print('✓ Imported $importedCount products');
      if (skippedCount > 0) {
        print('⚠ Skipped $skippedCount products');
      }
      
      print('\n=== DATABASE RESET COMPLETED ===');
      print('Categories: ${categoriesData.length}');
      print('Products: $importedCount');
      print('All data is fresh and category IDs are correctly mapped!');
    } catch (e, stackTrace) {
      print('Error during database reset: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
