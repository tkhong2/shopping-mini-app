import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../provider/simple_cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // No need to load cart items - using in-memory storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<SimpleCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              _buildSelectAllSection(cartProvider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return CartItemWidget(
                      item: item,
                      onQuantityChanged: (quantity) {
                        cartProvider.updateQuantity(item.id, quantity);
                      },
                      onRemove: () {
                        cartProvider.removeItem(item.id);
                      },
                      onToggleSelection: () {
                        cartProvider.toggleItemSelection(item.id);
                      },
                    );
                  },
                ),
              ),
              if (cartProvider.hasSelectedItems)
                CartSummaryWidget(
                  totalItems: cartProvider.selectedItems.length,
                  totalPrice: cartProvider.totalPrice,
                  originalPrice: cartProvider.originalTotalPrice,
                  onCheckout: () => _handleCheckout(context),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Check if can pop, otherwise go to home
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: Consumer<SimpleCartProvider>(
        builder: (context, cartProvider, child) {
          return Text(
            'Giỏ hàng (${cartProvider.totalItems})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to wishlist or favorites
          },
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildSelectAllSection(SimpleCartProvider cartProvider) {
    final allSelected = cartProvider.items.isNotEmpty &&
        cartProvider.items.every((item) => item.isSelected);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: (value) {
              cartProvider.selectAllItems(value ?? false);
            },
            activeColor: AppColors.primary,
          ),
          const Text(
            'Tất cả',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: cartProvider.items.isEmpty
                ? null
                : () => _showDeleteConfirmation(context, cartProvider),
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          CustomButton(
            text: 'Mua sắm ngay',
            onPressed: () {
              Navigator.of(context).pop();
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SimpleCartProvider cartProvider) {
    final selectedItems = cartProvider.selectedItems;
    if (selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${selectedItems.length} sản phẩm đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              for (final item in selectedItems) {
                cartProvider.removeItem(item.id);
              }
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    final cartProvider = context.read<SimpleCartProvider>();
    if (!cartProvider.hasSelectedItems) return;

    // Navigate to checkout page
    context.push('/checkout');
  }
}