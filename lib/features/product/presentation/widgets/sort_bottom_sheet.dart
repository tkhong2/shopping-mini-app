import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/product_list/product_list_bloc.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: Row(
              children: [
                Text(
                  'Sắp xếp theo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Sort Options
          SafeArea(
            child: Column(
              children: [
                _buildSortOption(
                  context,
                  'Giá: Thấp đến cao',
                  Icons.arrow_upward,
                  ProductSortBy.priceAsc,
                ),
                _buildSortOption(
                  context,
                  'Giá: Cao đến thấp',
                  Icons.arrow_downward,
                  ProductSortBy.priceDesc,
                ),
                _buildSortOption(
                  context,
                  'Đánh giá cao nhất',
                  Icons.star,
                  ProductSortBy.rating,
                ),
                _buildSortOption(
                  context,
                  'Mới nhất',
                  Icons.new_releases,
                  ProductSortBy.newest,
                ),
                _buildSortOption(
                  context,
                  'Bán chạy nhất',
                  Icons.trending_up,
                  ProductSortBy.popular,
                ),
                _buildSortOption(
                  context,
                  'Tên A-Z',
                  Icons.sort_by_alpha,
                  ProductSortBy.name,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    IconData icon,
    ProductSortBy sortBy,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: () {
        context.read<ProductListBloc>().add(SortProducts(sortBy));
        Navigator.of(context).pop();
      },
    );
  }
}