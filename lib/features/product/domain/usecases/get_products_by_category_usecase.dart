import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryUseCase implements UseCase<List<ProductEntity>, GetProductsByCategoryParams> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsByCategoryParams params) async {
    return await repository.getProductsByCategory(
      categoryId: params.categoryId,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetProductsByCategoryParams extends Equatable {
  final String categoryId;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const GetProductsByCategoryParams({
    required this.categoryId,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [categoryId, page, limit, sortBy, sortOrder];
}