import 'package:cloud_firestore/cloud_firestore.dart';

class FixCategoryIdsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fix all products to use correct category document IDs
  Future<void> fixAllProductCategoryIds() async {
    try {
      print('Starting category ID fix...');
      
      // Step 1: Build mapping from old ID to Firebase document ID
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final categoryMapping = <String, String>{};
      
      print('\nCategory mapping:');
      for (var doc in categoriesSnapshot.docs) {
        final data = doc.data();
        final oldId = data['id'] as String?;
        final name = data['name'] as String?;
        
        if (oldId != null) {
          categoryMapping[oldId] = doc.id;
          print('  $oldId -> ${doc.id} ($name)');
        }
      }
      
      // Step 2: Get all products
      final productsSnapshot = await _firestore.collection('products').get();
      print('\nProcessing ${productsSnapshot.docs.length} products...');
      
      int fixedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final currentCategoryId = data['categoryId'] as String?;
        final productName = data['name'] as String? ?? 'Unknown';
        
        if (currentCategoryId == null || currentCategoryId.isEmpty) {
          print('⚠ Skipping "$productName": no categoryId');
          skippedCount++;
          continue;
        }
        
        // Check if categoryId needs fixing
        String? correctCategoryId;
        
        // Case 1: categoryId is old format (cat_X)
        if (currentCategoryId.startsWith('cat_')) {
          correctCategoryId = categoryMapping[currentCategoryId];
          if (correctCategoryId != null) {
            await _firestore.collection('products').doc(doc.id).update({
              'categoryId': correctCategoryId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            fixedCount++;
            print('✓ Fixed "$productName": $currentCategoryId -> $correctCategoryId');
          } else {
            print('✗ No mapping for "$productName": $currentCategoryId');
            errorCount++;
          }
        }
        // Case 2: categoryId is a Firebase doc ID but wrong one
        else {
          // Check if this categoryId exists in categories
          final categoryExists = categoriesSnapshot.docs.any((cat) => cat.id == currentCategoryId);
          
          if (!categoryExists) {
            // Try to find correct category by checking if currentCategoryId matches any old ID
            bool found = false;
            for (var entry in categoryMapping.entries) {
              if (entry.value == currentCategoryId || entry.key == currentCategoryId) {
                // Already correct or matches old ID
                found = true;
                break;
              }
            }
            
            if (!found) {
              print('⚠ "$productName" has invalid categoryId: $currentCategoryId');
              errorCount++;
            } else {
              print('○ "$productName" already has correct categoryId');
              skippedCount++;
            }
          } else {
            print('○ "$productName" already has correct categoryId');
            skippedCount++;
          }
        }
      }
      
      print('\n=== Fix Summary ===');
      print('Total products: ${productsSnapshot.docs.length}');
      print('Fixed: $fixedCount');
      print('Skipped (already correct): $skippedCount');
      print('Errors: $errorCount');
      print('Fix completed!');
    } catch (e, stackTrace) {
      print('Error during fix: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
