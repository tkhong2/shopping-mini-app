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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _recentSearches = [];
  final List<String> _popularSearches = [
    'iPhone',
    'Samsung Galaxy',
    'Laptop',
    'Tai nghe',
    'Điện thoại',
    'Máy tính bảng',
    'Đồng hồ thông minh',
    'Camera',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (_searchController.text.isEmpty) {
            return _buildSearchSuggestions();
          }

          if (state is ProductListLoading && state.products.isEmpty) {
            return const LoadingWidget(message: 'Đang tìm kiếm...');
          }

          if (state is ProductListError && state.products.isEmpty) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => _performSearch(_searchController.text),
            );
          }

          if (state.products.isEmpty) {
            return _buildNoResults();
          }

          return _buildSearchResults(state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty) {
              _performSearch(value);
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addToRecentSearches(value);
              _performSearch(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Tìm kiếm gần đây', onClear: _clearRecentSearches),
            const SizedBox(height: AppDimensions.spacingMedium),
            _buildSearchChips(_recentSearches, isRecent: true),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],
          
          _buildSectionHeader('Tìm kiếm phổ biến'),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildSearchChips(_popularSearches),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: const Text('Xóa tất cả'),
          ),
      ],
    );
  }

  Widget _buildSearchChips(List<String> searches, {bool isRecent = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: searches.map((search) {
        return ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecent)
                const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              if (isRecent) const SizedBox(width: 4),
              Text(search),
            ],
          ),
          onPressed: () {
            _searchController.text = search;
            _addToRecentSearches(search);
            _performSearch(search);
          },
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults(ProductListState state) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              Text(
                'Tìm thấy ${state.products.length} sản phẩm',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  context.push(
                    '${RouteNames.productList}?query=${_searchController.text}',
                  );
                },
                icon: const Icon(Icons.view_list, size: 16),
                label: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppDimensions.spacingMedium,
              mainAxisSpacing: AppDimensions.spacingMedium,
            ),
            itemCount: state.products.length > 10 ? 10 : state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                onTap: () => context.push(
                  RouteNames.productDetail.replaceAll(':id', product.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
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
            'Không tìm thấy sản phẩm',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.take(4).map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _addToRecentSearches(search);
                  _performSearch(search);
                },
                backgroundColor: AppColors.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    context.read<ProductListBloc>().add(SearchProducts(query.trim()));
  }

  void _addToRecentSearches(String search) {
    setState(() {
      _recentSearches.remove(search);
      _recentSearches.insert(0, search);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    });
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }
}