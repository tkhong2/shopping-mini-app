import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase implements UseCase<List<ProductEntity>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(
      query: params.query,
      categoryId: params.categoryId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minRating: params.minRating,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class SearchProductsParams extends Equatable {
  final String query;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const SearchProductsParams({
    required this.query,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [
        query,
        categoryId,
        minPrice,
        maxPrice,
        minRating,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}