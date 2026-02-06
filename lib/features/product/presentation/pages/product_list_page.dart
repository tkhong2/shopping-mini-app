import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
import '../bloc/product_list/product_list_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_bottom_sheet.dart';

class ProductListPage extends StatefulWidget {
  final String? categoryId;
  final String? searchQuery;
  
  const ProductListPage({
    super.key,
    this.categoryId,
    this.searchQuery,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    if (widget.searchQuery != null) {
      context.read<ProductListBloc>().add(
        SearchProducts(widget.searchQuery!),
      );
    } else if (widget.categoryId != null) {
      context.read<ProductListBloc>().add(
        LoadProductsByCategory(widget.categoryId!),
      );
    } else {
      context.read<ProductListBloc>().add(
        const LoadAllProducts(),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductListBloc>().add(const LoadMoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading && state.products.isEmpty) {
            return const LoadingWidget(message: 'Đang tải sản phẩm...');
          }

          if (state is ProductListError && state.products.isEmpty) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: _loadProducts,
            );
          }

          if (state.products.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildFilterBar(state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  child: _isGridView 
                      ? _buildGridView(state)
                      : _buildListView(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Text(
        widget.searchQuery != null 
            ? 'Kết quả tìm kiếm'
            : widget.categoryId != null 
                ? 'Danh mục sản phẩm'
                : 'Tất cả sản phẩm',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(RouteNames.search),
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
        ),
      ],
    );
  }

  Widget _buildFilterBar(ProductListState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${state.products.length} sản phẩm',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildFilterButton(),
          const SizedBox(width: AppDimensions.spacingSmall),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return OutlinedButton.icon(
      onPressed: () => _showFilterBottomSheet(),
      icon: const Icon(Icons.filter_list, size: 18),
      label: const Text('Lọc'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSortButton() {
    return OutlinedButton.icon(
      onPressed: () => _showSortBottomSheet(),
      icon: const Icon(Icons.sort, size: 18),
      label: const Text('Sắp xếp'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildGridView(ProductListState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppDimensions.spacingMedium,
        mainAxisSpacing: AppDimensions.spacingMedium,
      ),
      itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= state.products.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = state.products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push(
            RouteNames.productDetail.replaceAll(':id', product.id),
          ),
        );
      },
    );
  }

  Widget _buildListView(ProductListState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= state.products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = state.products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
          child: ProductCard(
            product: product,
            isHorizontal: true,
            onTap: () => context.push(
              RouteNames.productDetail.replaceAll(':id', product.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            widget.searchQuery != null 
                ? 'Không tìm thấy sản phẩm'
                : 'Chưa có sản phẩm',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            widget.searchQuery != null 
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Sản phẩm sẽ được cập nhật sớm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SortBottomSheet(),
    );
  }
}