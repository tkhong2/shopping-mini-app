import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final Function(int) onChanged;
  final bool enabled;
  final double size;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
    this.enabled = true,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease Button
        _buildButton(
          icon: Icons.remove,
          onPressed: quantity > 1 && enabled
              ? () => onChanged(quantity - 1)
              : null,
        ),
        
        // Quantity Display
        Container(
          width: size + 8,
          height: size,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
              ),
            ),
          ),
          child: Center(
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.black : Colors.grey[400],
              ),
            ),
          ),
        ),
        
        // Increase Button
        _buildButton(
          icon: Icons.add,
          onPressed: quantity < maxQuantity && enabled
              ? () => onChanged(quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed != null ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null ? AppColors.primary : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}