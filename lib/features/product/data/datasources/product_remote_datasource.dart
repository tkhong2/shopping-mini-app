import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductModel> getProductDetail(String productId);
  
  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });
  
  Future<List<ProductModel>> searchProducts({
    required String query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });
  
  Future<List<ProductModel>> getFeaturedProducts({
    int page = 1,
    int limit = 20,
  });
  
  Future<List<ProductModel>> getRecommendedProducts({
    String? userId,
    int page = 1,
    int limit = 20,
  });
  
  Future<List<ReviewModel>> getProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    String? sortBy,
  });
  
  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
    String? variantInfo,
  });
  
  Future<void> markReviewHelpful(String reviewId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ProductModel> getProductDetail(String productId) async {
    try {
      final doc = await firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        throw const NotFoundException('Không tìm thấy sản phẩm');
      }

      return ProductModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      Query query = firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true);

      // Apply sorting
      if (sortBy != null) {
        final isDescending = sortOrder == 'desc';
        query = query.orderBy(sortBy, descending: isDescending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      // If pagination, skip the offset documents
      final docs = page > 1 
          ? querySnapshot.docs.skip((page - 1) * limit).toList()
          : querySnapshot.docs;

      return docs.map((doc) {
        return ProductModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      Query firestoreQuery = firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (categoryId != null) {
        firestoreQuery = firestoreQuery.where('categoryId', isEqualTo: categoryId);
      }

      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minRating != null) {
        firestoreQuery = firestoreQuery.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply sorting
      if (sortBy != null) {
        final isDescending = sortOrder == 'desc';
        firestoreQuery = firestoreQuery.orderBy(sortBy, descending: isDescending);
      }

      // Apply pagination
      firestoreQuery = firestoreQuery.limit(limit);
      if (page > 1) {
        // For simplicity, we'll use offset-based pagination
        // In production, use cursor-based pagination for better performance
      }

      final querySnapshot = await firestoreQuery.get();

      // Filter by search query (client-side for simplicity)
      // In production, use Algolia or Elasticsearch for better search
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return products;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('tags', arrayContains: 'featured')
          .orderBy('rating', descending: true)
          .limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getRecommendedProducts({
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // For simplicity, return popular products
      // In production, implement recommendation algorithm
      final query = firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ReviewModel>> getProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    String? sortBy,
  }) async {
    try {
      Query query = firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId);

      // Apply sorting
      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: true);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return ReviewModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
    String? variantInfo,
  }) async {
    try {
      // TODO: Get current user info
      final reviewData = {
        'productId': productId,
        'userId': 'current-user-id', // Replace with actual user ID
        'userName': 'Current User', // Replace with actual user name
        'userAvatar': null,
        'rating': rating,
        'comment': comment,
        'images': images ?? [],
        'createdAt': DateTime.now().toIso8601String(),
        'isVerifiedPurchase': false, // Check if user purchased this product
        'helpfulCount': 0,
        'variantInfo': variantInfo,
      };

      await firestore.collection('reviews').add(reviewData);

      // Update product rating (simplified calculation)
      // In production, use Cloud Functions for this
      await _updateProductRating(productId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final reviewsSnapshot = await firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        final reviews = reviewsSnapshot.docs
            .map((doc) => doc.data()['rating'] as double)
            .toList();

        final averageRating = reviews.reduce((a, b) => a + b) / reviews.length;
        final reviewCount = reviews.length;

        await firestore.collection('products').doc(productId).update({
          'rating': averageRating,
          'reviewCount': reviewCount,
        });
      }
    } catch (e) {
      // Log error but don't throw to avoid breaking the review submission
      print('Error updating product rating: $e');
    }
  }
}