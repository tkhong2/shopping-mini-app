part of 'product_list_bloc.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProducts extends ProductListEvent {
  const LoadAllProducts();
}

class LoadProductsByCategory extends ProductListEvent {
  final String categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class SearchProducts extends ProductListEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreProducts extends ProductListEvent {
  const LoadMoreProducts();
}

class RefreshProducts extends ProductListEvent {
  const RefreshProducts();
}

class FilterProducts extends ProductListEvent {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<String>? brands;

  const FilterProducts({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.brands,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, minRating, brands];
}

class SortProducts extends ProductListEvent {
  final ProductSortBy sortBy;

  const SortProducts(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}