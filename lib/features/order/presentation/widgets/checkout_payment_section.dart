import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final String selectedPayment;
  final Function(String) onPaymentChanged;
  final String deliveryNote;
  final Function(String) onNoteChanged;

  const CheckoutPaymentSection({
    super.key,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.deliveryNote,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildPaymentOption(
            'cod',
            'Thanh toán khi nhận hàng (COD)',
            Icons.money,
            'Thanh toán bằng tiền mặt khi nhận hàng',
          ),
          _buildPaymentOption(
            'momo',
            'Ví MoMo',
            Icons.account_balance_wallet,
            'Thanh toán qua ví điện tử MoMo',
          ),
          _buildPaymentOption(
            'banking',
            'Chuyển khoản ngân hàng',
            Icons.account_balance,
            'Chuyển khoản qua Internet Banking',
          ),
          _buildPaymentOption(
            'card',
            'Thẻ tín dụng/ghi nợ',
            Icons.credit_card,
            'Visa, Mastercard, JCB',
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          TextField(
            onChanged: onNoteChanged,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ghi chú cho người giao hàng (tùy chọn)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = selectedPayment == value;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedPayment,
        onChanged: (value) => onPaymentChanged(value!),
        title: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
        ),
      ),
    );
  }
}