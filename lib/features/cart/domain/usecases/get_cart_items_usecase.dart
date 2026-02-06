import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase implements UseCase<List<CartItemEntity>, GetCartItemsParams> {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(GetCartItemsParams params) async {
    return await repository.getCartItems(params.userId);
  }
}

class GetCartItemsParams {
  final String? userId;

  GetCartItemsParams({this.userId});
}