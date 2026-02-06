import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';

class ReviewsSection extends StatelessWidget {
  final ProductEntity product;
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final VoidCallback onLoadMoreReviews;

  const ReviewsSection({
    super.key,
    required this.product,
    required this.reviews,
    required this.isLoading,
    required this.onLoadMoreReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          _buildReviewsHeader(context),
          
          const Divider(height: 1),
          
          // Rating Summary
          _buildRatingSummary(),
          
          const Divider(height: 1),
          
          // Reviews List
          if (reviews.isNotEmpty) ...[
            _buildReviewsList(),
            
            // Load More Button
            if (reviews.length >= 5)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: CustomButton(
                  text: 'Xem thêm đánh giá',
                  onPressed: isLoading ? null : onLoadMoreReviews,
                  isLoading: isLoading,
                  type: ButtonType.outline,
                  isFullWidth: true,
                ),
              ),
          ] else ...[
            _buildEmptyReviews(),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Text(
            'Đánh giá sản phẩm',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          TextButton(
            onPressed: () {
              // TODO: Navigate to all reviews page
            },
            child: Text(
              'Xem tất cả',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          // Overall Rating
          Column(
            children: [
              Text(
                Formatters.formatRating(product.rating),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
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
              
              const SizedBox(height: 4),
              
              Text(
                '${Formatters.formatNumber(product.reviewCount)} đánh giá',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppDimensions.paddingL),
          
          // Rating Breakdown
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final percentage = _calculateRatingPercentage(star);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: AppTextStyles.caption,
                      ),
                      
                      const SizedBox(width: 4),
                      
                      const Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 12,
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.rating,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Text(
                        '${percentage.round()}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: reviews.take(3).map((review) {
        return _buildReviewItem(review);
      }).toList(),
    );
  }

  Widget _buildReviewItem(ReviewEntity review) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.background,
                backgroundImage: review.userAvatar != null
                    ? CachedNetworkImageProvider(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty 
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: AppDimensions.paddingS),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    Text(
                      Formatters.formatRelativeTime(review.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (review.isVerifiedPurchase)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Đã mua',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          // Rating
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: AppColors.rating,
                    size: 14,
                  );
                }),
              ),
              
              if (review.variantInfo != null) ...[
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  review.variantInfo!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          // Comment
          Text(
            review.comment,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.4,
            ),
          ),
          
          // Review Images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingS),
            
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: AppDimensions.paddingS),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      child: CachedNetworkImage(
                        imageUrl: review.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Helpful Button
          const SizedBox(height: AppDimensions.paddingS),
          
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Mark review as helpful
                },
                icon: const Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                ),
                label: Text(
                  'Hữu ích (${review.helpfulCount})',
                  style: AppTextStyles.caption,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          Text(
            'Chưa có đánh giá nào',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          Text(
            'Hãy là người đầu tiên đánh giá sản phẩm này',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateRatingPercentage(int star) {
    // This is a simplified calculation
    // In a real app, you would get this data from the backend
    if (product.reviewCount == 0) return 0;
    
    switch (star) {
      case 5:
        return 60;
      case 4:
        return 25;
      case 3:
        return 10;
      case 2:
        return 3;
      case 1:
        return 2;
      default:
        return 0;
    }
  }
}