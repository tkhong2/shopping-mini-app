part of 'product_list_bloc.dart';

abstract class ProductListState extends Equatable {
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final int currentPage;
  final String? categoryId;
  final String? searchQuery;

  const ProductListState({
    this.products = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.categoryId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        products,
        hasReachedMax,
        currentPage,
        categoryId,
        searchQuery,
      ];
}

class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

class ProductListLoading extends ProductListState {
  const ProductListLoading({
    super.products,
    super.hasReachedMax,
    super.currentPage,
    super.categoryId,
    super.searchQuery,
  });
}

class ProductListLoaded extends ProductListState {
  final bool isLoadingMore;

  const ProductListLoaded({
    required super.products,
    super.hasReachedMax = false,
    super.currentPage = 1,
    super.categoryId,
    super.searchQuery,
    this.isLoadingMore = false,
  });

  ProductListLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasReachedMax,
    int? currentPage,
    String? categoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      categoryId: categoryId ?? this.categoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        isLoadingMore,
      ];
}

class ProductListError extends ProductListState {
  final String message;

  const ProductListError(
    this.message, {
    super.products,
    super.hasReachedMax,
    super.currentPage,
    super.categoryId,
    super.searchQuery,
  });

  @override
  List<Object?> get props => [...super.props, message];
}