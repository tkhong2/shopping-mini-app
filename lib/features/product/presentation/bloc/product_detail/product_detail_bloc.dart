import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/usecases/get_product_detail_usecase.dart';
import '../../../domain/usecases/get_product_reviews_usecase.dart';

// Events
abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadProductDetail extends ProductDetailEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object> get props => [productId];
}

class LoadProductReviews extends ProductDetailEvent {
  final String productId;
  final int page;
  final String? sortBy;

  const LoadProductReviews({
    required this.productId,
    this.page = 1,
    this.sortBy,
  });

  @override
  List<Object> get props => [productId, page];
}

class SelectVariant extends ProductDetailEvent {
  final String variantType;
  final String variantValue;

  const SelectVariant({
    required this.variantType,
    required this.variantValue,
  });

  @override
  List<Object> get props => [variantType, variantValue];
}

class UpdateQuantity extends ProductDetailEvent {
  final int quantity;

  const UpdateQuantity(this.quantity);

  @override
  List<Object> get props => [quantity];
}

class ToggleFavorite extends ProductDetailEvent {}

// States
abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductEntity product;
  final List<ReviewEntity> reviews;
  final Map<String, String> selectedVariants;
  final String? selectedVariantId;
  final int quantity;
  final bool isFavorite;
  final bool isLoadingReviews;
  final bool reviewsLoading;

  const ProductDetailLoaded({
    required this.product,
    this.reviews = const [],
    this.selectedVariants = const {},
    this.selectedVariantId,
    this.quantity = 1,
    this.isFavorite = false,
    this.isLoadingReviews = false,
    this.reviewsLoading = false,
  });

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    List<ReviewEntity>? reviews,
    Map<String, String>? selectedVariants,
    String? selectedVariantId,
    int? quantity,
    bool? isFavorite,
    bool? isLoadingReviews,
    bool? reviewsLoading,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      reviews: reviews ?? this.reviews,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      quantity: quantity ?? this.quantity,
      isFavorite: isFavorite ?? this.isFavorite,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      reviewsLoading: reviewsLoading ?? this.reviewsLoading,
    );
  }

  @override
  List<Object?> get props => [
        product,
        reviews,
        selectedVariants,
        selectedVariantId,
        quantity,
        isFavorite,
        isLoadingReviews,
        reviewsLoading,
      ];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;
  final GetProductReviewsUseCase getProductReviewsUseCase;

  ProductDetailBloc({
    required this.getProductDetailUseCase,
    required this.getProductReviewsUseCase,
  }) : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
    on<LoadProductReviews>(_onLoadProductReviews);
    on<SelectVariant>(_onSelectVariant);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    final result = await getProductDetailUseCase(event.productId);

    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) {
        emit(ProductDetailLoaded(product: product));
        
        // Load reviews after product is loaded
        add(LoadProductReviews(productId: event.productId));
      },
    );
  }

  Future<void> _onLoadProductReviews(
    LoadProductReviews event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(isLoadingReviews: true));

      final result = await getProductReviewsUseCase(
        productId: event.productId,
        page: event.page,
        sortBy: event.sortBy,
      );

      result.fold(
        (failure) {
          // Don't emit error for reviews, just stop loading
          emit(currentState.copyWith(isLoadingReviews: false));
        },
        (reviews) {
          final updatedReviews = event.page == 1 
              ? reviews 
              : [...currentState.reviews, ...reviews];
          
          emit(currentState.copyWith(
            reviews: updatedReviews,
            isLoadingReviews: false,
          ));
        },
      );
    }
  }

  void _onSelectVariant(
    SelectVariant event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      final updatedVariants = Map<String, String>.from(currentState.selectedVariants);
      updatedVariants[event.variantType] = event.variantValue;

      emit(currentState.copyWith(selectedVariants: updatedVariants));
    }
  }

  void _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      final newQuantity = event.quantity.clamp(1, currentState.product.stock);
      
      emit(currentState.copyWith(quantity: newQuantity));
    }
  }

  void _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
      
      // TODO: Call wishlist use case to add/remove from favorites
    }
  }
}