import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review_entity.dart';
import '../repositories/product_repository.dart';

class GetProductReviewsUseCase {
  final ProductRepository repository;

  GetProductReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call({
    required String productId,
    int page = 1,
    int limit = 10,
    String? sortBy,
  }) async {
    return await repository.getProductReviews(
      productId: productId,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }
}