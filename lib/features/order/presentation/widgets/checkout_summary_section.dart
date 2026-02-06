import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class CheckoutSummarySection extends StatelessWidget {
  final List<CartItemEntity> items;
  final double deliveryFee;

  const CheckoutSummarySection({
    super.key,
    required this.items,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final discount = items.fold<double>(0, (sum, item) => sum + item.discountAmount);
    final total = subtotal + deliveryFee;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildSummaryRow(
            'Tạm tính (${items.length} sản phẩm)',
            PriceFormatter.format(subtotal + discount),
          ),
          if (discount > 0)
            _buildSummaryRow(
              'Giảm giá',
              '-${PriceFormatter.format(discount)}',
              color: AppColors.success,
            ),
          _buildSummaryRow(
            'Phí vận chuyển',
            deliveryFee > 0 
                ? PriceFormatter.format(deliveryFee)
                : 'Miễn phí',
            color: deliveryFee > 0 ? null : AppColors.success,
          ),
          if (deliveryFee == 0)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Miễn phí vận chuyển cho đơn hàng từ 150.000đ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Tổng thanh toán',
            PriceFormatter.format(total),
            isTotal: true,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bằng việc đặt hàng, bạn đồng ý với Điều khoản sử dụng của chúng tôi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: color ?? (isTotal ? AppColors.primary : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}