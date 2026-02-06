import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../product/presentation/bloc/product_list/product_list_bloc.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  
  const CategoryPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductListBloc>().add(
      LoadProductsByCategory(widget.categoryId),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              onRetry: () => context.read<ProductListBloc>().add(
                LoadProductsByCategory(widget.categoryId),
              ),
            );
          }

          if (state.products.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildCategoryHeader(),
              _buildFilterBar(state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductListBloc>().add(
                      LoadProductsByCategory(widget.categoryId),
                    );
                  },
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
        _getCategoryName(widget.categoryId),
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

  Widget _buildCategoryHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.categoryId).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: _getCategoryColor(widget.categoryId).withOpacity(0.2),
              ),
            ),
            child: Icon(
              _getCategoryIcon(widget.categoryId),
              size: 30,
              color: _getCategoryColor(widget.categoryId),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryName(widget.categoryId),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryDescription(widget.categoryId),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show filter bottom sheet
            },
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Lọc'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show sort bottom sheet
            },
            icon: const Icon(Icons.sort, size: 18),
            label: const Text('Sắp xếp'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
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
            _getCategoryIcon(widget.categoryId),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'Chưa có sản phẩm',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Sản phẩm sẽ được cập nhật sớm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case '1':
        return 'Thời trang';
      case '2':
        return 'Điện tử';
      case '3':
        return 'Gia dụng';
      case '4':
        return 'Làm đẹp';
      case '5':
        return 'Thể thao';
      case '6':
        return 'Sách';
      case '7':
        return 'Xe cộ';
      case '8':
        return 'Khác';
      default:
        return 'Danh mục sản phẩm';
    }
  }

  String _getCategoryDescription(String categoryId) {
    switch (categoryId) {
      case '1':
        return 'Quần áo, giày dép, phụ kiện thời trang';
      case '2':
        return 'Điện thoại, laptop, thiết bị điện tử';
      case '3':
        return 'Đồ gia dụng, nội thất, trang trí';
      case '4':
        return 'Mỹ phẩm, chăm sóc da, làm đẹp';
      case '5':
        return 'Dụng cụ thể thao, trang phục thể thao';
      case '6':
        return 'Sách, truyện, tài liệu học tập';
      case '7':
        return 'Phụ tùng xe, phụ kiện ô tô, xe máy';
      case '8':
        return 'Các sản phẩm khác';
      default:
        return 'Khám phá các sản phẩm trong danh mục';
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case '1':
        return Icons.checkroom;
      case '2':
        return Icons.phone_android;
      case '3':
        return Icons.home;
      case '4':
        return Icons.face_retouching_natural;
      case '5':
        return Icons.sports_soccer;
      case '6':
        return Icons.menu_book;
      case '7':
        return Icons.directions_car;
      case '8':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case '1':
        return const Color(0xFFE91E63);
      case '2':
        return const Color(0xFF2196F3);
      case '3':
        return const Color(0xFF4CAF50);
      case '4':
        return const Color(0xFFFF9800);
      case '5':
        return const Color(0xFF9C27B0);
      case '6':
        return const Color(0xFF795548);
      case '7':
        return const Color(0xFF607D8B);
      case '8':
        return const Color(0xFF9E9E9E);
      default:
        return AppColors.primary;
    }
  }
}