import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductEntity>> getProductDetail(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.getProductDetail(productId);
        return Right(product.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProductsByCategory(
          categoryId: categoryId,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(products.map((product) => product.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.searchProducts(
          query: query,
          categoryId: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minRating: minRating,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(products.map((product) => product.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getFeaturedProducts(
          page: page,
          limit: limit,
        );
        return Right(products.map((product) => product.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRecommendedProducts({
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getRecommendedProducts(
          userId: userId,
          page: page,
          limit: limit,
        );
        return Right(products.map((product) => product.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final reviews = await remoteDataSource.getProductReviews(
          productId: productId,
          page: page,
          limit: limit,
          sortBy: sortBy,
        );
        return Right(reviews.map((review) => review.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, void>> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
    String? variantInfo,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addReview(
          productId: productId,
          rating: rating,
          comment: comment,
          images: images,
          variantInfo: variantInfo,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }

  @override
  Future<Either<Failure, void>> markReviewHelpful(String reviewId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markReviewHelpful(reviewId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }
}