// Temporary placeholder classes for dependency injection
// These will be replaced with actual implementations later

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'core/errors/failures.dart';
import 'core/usecases/usecase.dart';
import 'features/order/domain/entities/order_entity.dart';
import 'features/profile/domain/entities/user_profile_entity.dart';

// Auth Domain - REMOVED (implemented)
// Auth Data - REMOVED (implemented)

// Home Domain
abstract class HomeRepository {}
class GetBannersUseCase implements UseCase<List<dynamic>, NoParams> {
  GetBannersUseCase(dynamic repo);
  @override
  Future<Either<Failure, List<dynamic>>> call(NoParams params) async {
    return Right([]);
  }
}
class GetFlashSalesUseCase implements UseCase<List<dynamic>, NoParams> {
  GetFlashSalesUseCase(dynamic repo);
  @override
  Future<Either<Failure, List<dynamic>>> call(NoParams params) async {
    return Right([]);
  }
}

// Home Data
abstract class HomeRemoteDataSource {}
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required dynamic remoteDataSource, required dynamic networkInfo});
}
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({required dynamic firestore});
}

// Product Domain - REMOVED (implemented)
// Product Data - REMOVED (implemented)
// Product BLoCs - REMOVED (implemented)

// Cart Domain - REMOVED (implemented)
// Cart Data - REMOVED (implemented)
// Cart Provider - REMOVED (implemented)

// Order Domain
abstract class OrderRepository {}
class CreateOrderUseCase implements UseCase<OrderEntity, dynamic> {
  CreateOrderUseCase(dynamic repo);
  @override
  Future<Either<Failure, OrderEntity>> call(dynamic params) async {
    // Mock implementation
    return Left(ServerFailure('Not implemented'));
  }
}
class GetOrderHistoryUseCase implements UseCase<List<OrderEntity>, dynamic> {
  GetOrderHistoryUseCase(dynamic repo);
  @override
  Future<Either<Failure, List<OrderEntity>>> call(dynamic params) async {
    return Right([]);
  }
}
class CancelOrderUseCase implements UseCase<void, dynamic> {
  CancelOrderUseCase(dynamic repo);
  @override
  Future<Either<Failure, void>> call(dynamic params) async {
    return Right(null);
  }
}

// Order Data
abstract class OrderRemoteDataSource {}
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required dynamic remoteDataSource, required dynamic networkInfo});
}
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({required dynamic firestore});
}

// Order BLoCs - REMOVED (implemented)

// Profile Domain
abstract class ProfileRepository {}
class GetProfileUseCase implements UseCase<UserProfileEntity, dynamic> {
  GetProfileUseCase(dynamic repo);
  @override
  Future<Either<Failure, UserProfileEntity>> call(dynamic params) async {
    return Left(ServerFailure('Not implemented'));
  }
}
class UpdateProfileUseCase implements UseCase<UserProfileEntity, dynamic> {
  UpdateProfileUseCase(dynamic repo);
  @override
  Future<Either<Failure, UserProfileEntity>> call(dynamic params) async {
    return Left(ServerFailure('Not implemented'));
  }
}

// Profile Data
abstract class ProfileRemoteDataSource {}
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required dynamic remoteDataSource, required dynamic networkInfo});
}
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required dynamic firestore, required dynamic firebaseStorage});
}

// Profile Provider - REMOVED (implemented)

// Wishlist Provider - REMOVED (implemented)
