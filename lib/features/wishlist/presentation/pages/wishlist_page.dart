import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../provider/wishlist_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistProvider.wishlistItems.isEmpty) {
            return _buildEmptyWishlist();
          }

          return Column(
            children: [
              _buildHeader(wishlistProvider),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppDimensions.spacingMedium,
                    mainAxisSpacing: AppDimensions.spacingMedium,
                  ),
                  itemCount: wishlistProvider.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final product = wishlistProvider.wishlistItems[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push(
                        RouteNames.productDetail.replaceAll(':id', product.id),
                      ),
                      onFavoriteToggle: () {
                        wishlistProvider.removeFromWishlist(product.id);
                      },
                    );
                  },
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
      title: const Text(
        'Yêu thích',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, child) {
            if (wishlistProvider.wishlistItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'clear_all':
                    _showClearAllDialog();
                    break;
                  case 'share':
                    // TODO: Share wishlist
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('Chia sẻ'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(WishlistProvider wishlistProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${wishlistProvider.wishlistItems.length} sản phẩm yêu thích',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'Chưa có sản phẩm yêu thích',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Hãy thêm sản phẩm vào danh sách yêu thích',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          CustomButton(
            text: 'Khám phá sản phẩm',
            onPressed: () {
              context.go(RouteNames.home);
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả sản phẩm khỏi danh sách yêu thích?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WishlistProvider>().clearWishlist();
            },
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}