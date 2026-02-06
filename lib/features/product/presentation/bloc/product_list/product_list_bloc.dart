import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_products_by_category_usecase.dart';
import '../../../domain/usecases/search_products_usecase.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  ProductListBloc({
    required this.getProductsByCategoryUseCase,
    required this.searchProductsUseCase,
  }) : super(const ProductListInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListLoading());
    
    final result = await getProductsByCategoryUseCase(
      const GetProductsByCategoryParams(categoryId: 'all', page: 1),
    );

    result.fold(
      (failure) => emit(ProductListError(_mapFailureToMessage(failure))),
      (products) => emit(ProductListLoaded(
        products: products,
        hasReachedMax: products.length < 20,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListLoading());
    
    final result = await getProductsByCategoryUseCase(
      GetProductsByCategoryParams(categoryId: event.categoryId, page: 1),
    );

    result.fold(
      (failure) => emit(ProductListError(_mapFailureToMessage(failure))),
      (products) => emit(ProductListLoaded(
        products: products,
        hasReachedMax: products.length < 20,
        currentPage: 1,
        categoryId: event.categoryId,
      )),
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListLoading());
    
    final result = await searchProductsUseCase(
      SearchProductsParams(query: event.query, page: 1),
    );

    result.fold(
      (failure) => emit(ProductListError(_mapFailureToMessage(failure))),
      (products) => emit(ProductListLoaded(
        products: products,
        hasReachedMax: products.length < 20,
        currentPage: 1,
        searchQuery: event.query,
      )),
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductListLoaded || currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    
    if (currentState.searchQuery != null) {
      final result = await searchProductsUseCase(
        SearchProductsParams(query: currentState.searchQuery!, page: nextPage),
      );
      
      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (newProducts) => emit(currentState.copyWith(
          products: [...currentState.products, ...newProducts],
          hasReachedMax: newProducts.length < 20,
          currentPage: nextPage,
          isLoadingMore: false,
        )),
      );
    } else {
      final result = await getProductsByCategoryUseCase(
        GetProductsByCategoryParams(
          categoryId: currentState.categoryId ?? 'all',
          page: nextPage,
        ),
      );
      
      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (newProducts) => emit(currentState.copyWith(
          products: [...currentState.products, ...newProducts],
          hasReachedMax: newProducts.length < 20,
          currentPage: nextPage,
          isLoadingMore: false,
        )),
      );
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      if (currentState.searchQuery != null) {
        add(SearchProducts(currentState.searchQuery!));
      } else if (currentState.categoryId != null) {
        add(LoadProductsByCategory(currentState.categoryId!));
      } else {
        add(const LoadAllProducts());
      }
    }
  }

  void _onFilterProducts(
    FilterProducts event,
    Emitter<ProductListState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      var filteredProducts = List<ProductEntity>.from(currentState.products);

      // Apply price filter
      if (event.minPrice != null) {
        filteredProducts = filteredProducts
            .where((product) => product.price >= event.minPrice!)
            .toList();
      }
      if (event.maxPrice != null) {
        filteredProducts = filteredProducts
            .where((product) => product.price <= event.maxPrice!)
            .toList();
      }

      // Apply rating filter
      if (event.minRating != null) {
        filteredProducts = filteredProducts
            .where((product) => product.rating >= event.minRating!)
            .toList();
      }

      // Apply brand filter
      if (event.brands != null && event.brands!.isNotEmpty) {
        filteredProducts = filteredProducts
            .where((product) => event.brands!.contains(product.brand))
            .toList();
      }

      emit(currentState.copyWith(products: filteredProducts));
    }
  }

  void _onSortProducts(
    SortProducts event,
    Emitter<ProductListState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductListLoaded) {
      var sortedProducts = List<ProductEntity>.from(currentState.products);

      switch (event.sortBy) {
        case ProductSortBy.priceAsc:
          sortedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case ProductSortBy.priceDesc:
          sortedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case ProductSortBy.rating:
          sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case ProductSortBy.newest:
          sortedProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case ProductSortBy.popular:
          sortedProducts.sort((a, b) => b.soldCount.compareTo(a.soldCount));
          break;
        case ProductSortBy.name:
          sortedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
      }

      emit(currentState.copyWith(products: sortedProducts));
    }
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return 'Lỗi máy chủ';
      case const (NetworkFailure):
        return 'Không có kết nối mạng';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }
}

// Failure classes for type checking
class ServerFailure {}
class NetworkFailure {}

enum ProductSortBy {
  priceAsc,
  priceDesc,
  rating,
  newest,
  popular,
  name,
}