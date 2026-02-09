import 'dart:convert';
import 'package:flutter/services.dart';

class MockProducts {
  static List<Map<String, dynamic>>? _products;
  static List<Map<String, dynamic>>? _categories;

  static Future<void> loadData() async {
    if (_products == null) {
      final String productsJson = await rootBundle.loadString('assets/data/products.json');
      _products = List<Map<String, dynamic>>.from(json.decode(productsJson));
    }
    if (_categories == null) {
      final String categoriesJson = await rootBundle.loadString('assets/data/categories.json');
      _categories = List<Map<String, dynamic>>.from(json.decode(categoriesJson));
    }
  }

  static List<Map<String, dynamic>> get products {
    if (_products == null) {
      throw Exception('Data not loaded. Call loadData() first.');
    }
    return _products!;
  }

  static List<Map<String, dynamic>> get categories {
    if (_categories == null) {
      throw Exception('Data not loaded. Call loadData() first.');
    }
    return _categories!;
  }

  static Map<String, dynamic>? getProductById(String id) {
    try {
      return products.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getProductsByCategory(String categoryId) {
    return products.where((p) => p['categoryId'] == categoryId).toList();
  }

  static List<Map<String, dynamic>> getFlashSaleProducts() {
    return products.take(10).toList();
  }

  static List<Map<String, dynamic>> getTopDeals() {
    return products.take(12).toList();
  }

  static Map<String, dynamic>? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> searchProducts(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final description = (p['description'] as String).toLowerCase();
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // Get all products for admin
  static List<Map<String, dynamic>> getAllProducts() {
    return List<Map<String, dynamic>>.from(products);
  }

  // Get all categories for admin
  static List<Map<String, dynamic>> getAllCategories() {
    return List<Map<String, dynamic>>.from(categories);
  }
}
