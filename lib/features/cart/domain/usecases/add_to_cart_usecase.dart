import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<void, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToCartParams params) async {
    return await repository.addToCart(params.item, params.userId);
  }
}

class AddToCartParams {
  final CartItemEntity item;
  final String? userId;

  AddToCartParams({
    required this.item,
    this.userId,
  });
}