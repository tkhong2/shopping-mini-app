import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product_entity.dart';

class ProductInfo extends StatelessWidget {
  final ProductEntity product;

  const ProductInfo({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.name,
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          // Rating and Reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : index < product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: AppColors.rating,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                Formatters.formatRating(product.rating),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                '(${Formatters.formatNumber(product.reviewCount)} đánh giá)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Đã bán ${Formatters.formatNumber(product.reviewCount * 3)}', // Estimate sold count
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Price Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(product.price),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (product.hasDiscount) ...[
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  Formatters.formatCurrency(product.originalPrice!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  child: Text(
                    '-${product.discountPercentage.round()}%',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Brand and Category
          Row(
            children: [
              _buildInfoChip('Thương hiệu', product.brand),
              const SizedBox(width: AppDimensions.paddingM),
              _buildInfoChip('Danh mục', product.categoryName),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Stock Status
          Row(
            children: [
              Icon(
                product.isInStock ? Icons.check_circle : Icons.cancel,
                color: product.isInStock ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                product.isInStock 
                    ? 'Còn hàng (${product.stock} sản phẩm)'
                    : 'Hết hàng',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: product.isInStock ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Tags
          if (product.tags.isNotEmpty)
            Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children: product.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Description
          Text(
            'Mô tả sản phẩm',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          Text(
            product.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}