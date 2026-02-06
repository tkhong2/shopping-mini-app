import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../entities/review_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductEntity>> getProductDetail(String productId);
  
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });
  
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
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
  
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, List<ProductEntity>>> getRecommendedProducts({
    String? userId,
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    String? sortBy,
  });
  
  Future<Either<Failure, void>> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
    String? variantInfo,
  });
  
  Future<Either<Failure, void>> markReviewHelpful(String reviewId);
}