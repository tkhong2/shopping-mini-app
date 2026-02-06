import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';

class VariantSelector extends StatelessWidget {
  final List<ProductVariantEntity> variants;
  final String? selectedVariantId;
  final Function(String) onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    this.selectedVariantId,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox.shrink();

    // Group variants by type
    final variantsByType = <String, List<ProductVariantEntity>>{};
    for (final variant in variants) {
      if (!variantsByType.containsKey(variant.type)) {
        variantsByType[variant.type] = [];
      }
      variantsByType[variant.type]!.add(variant);
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn phiên bản',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          ...variantsByType.entries.map((entry) {
            return _buildVariantTypeSection(
              entry.key,
              entry.value,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVariantTypeSection(
    String type,
    List<ProductVariantEntity> variants,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getVariantTypeLabel(type),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingS),
        
        Wrap(
          spacing: AppDimensions.paddingS,
          runSpacing: AppDimensions.paddingS,
          children: variants.map((variant) {
            final isSelected = selectedVariantId == variant.id;
            final isAvailable = variant.stock > 0;
            
            return GestureDetector(
              onTap: isAvailable 
                  ? () => onVariantSelected(variant.id)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary
                      : isAvailable
                          ? AppColors.surface
                          : AppColors.background,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isAvailable
                            ? AppColors.border
                            : AppColors.textHint,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == 'color' && variant.image != null)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: AppDimensions.paddingS),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          image: DecorationImage(
                            image: NetworkImage(variant.image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    Text(
                      variant.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.textWhite
                            : isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    
                    if (variant.priceAdjustment != null && variant.priceAdjustment! != 0)
                      Text(
                        ' (+${variant.priceAdjustment! > 0 ? '+' : ''}${variant.priceAdjustment!.toStringAsFixed(0)}₫)',
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: AppDimensions.paddingM),
      ],
    );
  }

  String _getVariantTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'color':
        return 'Màu sắc';
      case 'size':
        return 'Kích thước';
      case 'storage':
        return 'Dung lượng';
      case 'memory':
        return 'Bộ nhớ';
      case 'material':
        return 'Chất liệu';
      default:
        return type;
    }
  }
}