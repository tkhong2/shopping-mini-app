import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../cart/presentation/provider/simple_cart_provider.dart';
import '../../../notifications/presentation/provider/notification_provider.dart';
import '../provider/order_provider.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_payment_section.dart';
import '../widgets/checkout_items_section.dart';
import '../widgets/checkout_summary_section.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedAddress = 'default';
  String _selectedPayment = 'cod';
  String _deliveryNote = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<SimpleCartProvider>(
        builder: (context, cartProvider, child) {
          final selectedItems = cartProvider.selectedItems;
          
          if (selectedItems.isEmpty) {
            return _buildEmptyCheckout();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CheckoutAddressSection(
                        selectedAddress: _selectedAddress,
                        onAddressChanged: (address) {
                          setState(() {
                            _selectedAddress = address;
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      CheckoutItemsSection(items: selectedItems),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      CheckoutPaymentSection(
                        selectedPayment: _selectedPayment,
                        onPaymentChanged: (payment) {
                          setState(() {
                            _selectedPayment = payment;
                          });
                        },
                        deliveryNote: _deliveryNote,
                        onNoteChanged: (note) {
                          setState(() {
                            _deliveryNote = note;
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      CheckoutSummarySection(
                        items: selectedItems,
                        deliveryFee: _calculateDeliveryFee(cartProvider.totalPrice),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(cartProvider),
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
        'Thanh toán',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyCheckout() {
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
            'Không có sản phẩm để thanh toán',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          CustomButton(
            text: 'Quay lại giỏ hàng',
            onPressed: () => context.pop(),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(SimpleCartProvider cartProvider) {
    final deliveryFee = _calculateDeliveryFee(cartProvider.totalPrice);
    final totalAmount = cartProvider.totalPrice + deliveryFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng thanh toán:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      PriceFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processOrder(cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Mua hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDeliveryFee(double totalPrice) {
    if (totalPrice >= 150000) return 0; // Free shipping over 150k
    return 30000; // Standard delivery fee
  }

  void _processOrder(SimpleCartProvider cartProvider) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 2));

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final deliveryFee = _calculateDeliveryFee(cartProvider.totalPrice);
      final totalAmount = cartProvider.totalPrice + deliveryFee;
      
      // Create order items
      final orderItems = cartProvider.selectedItems.map((item) {
        return OrderItemDetail(
          id: item.id,
          name: item.productName,
          imageUrl: item.productImage,
          quantity: item.quantity,
          price: item.price,
        );
      }).toList();
      
      // Add order to provider
      if (mounted) {
        context.read<OrderProvider>().addOrder(
          id: orderId,
          totalAmount: totalAmount,
          items: orderItems,
          address: '123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
          paymentMethod: _selectedPayment == 'cod' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản',
        );
        
        // Add notification
        context.read<NotificationProvider>().addNotification(
          title: 'Đặt hàng thành công',
          message: 'Đơn hàng $orderId đã được đặt thành công. Chúng tôi sẽ xử lý đơn hàng của bạn sớm nhất.',
          type: 'order',
        );
      }
      
      // Clear selected items from cart
      for (final item in cartProvider.selectedItems) {
        cartProvider.removeItem(item.id);
      }

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 60,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                const Text(
                  'Đặt hàng thành công!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Text(
                  'Mã đơn hàng: $orderId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/home');
                        },
                        child: const Text('Tiếp tục mua'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSmall),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/orders');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Xem đơn hàng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đặt hàng: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}