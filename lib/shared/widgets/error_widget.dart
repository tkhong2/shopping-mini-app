import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              CustomButton(
                text: buttonText ?? 'Thử lại',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Không có kết nối mạng',
      message: 'Vui lòng kiểm tra kết nối internet và thử lại.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Lỗi máy chủ',
      message: 'Đã xảy ra lỗi từ phía máy chủ. Vui lòng thử lại sau.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onGoBack;

  const NotFoundWidget({
    super.key,
    this.title,
    this.message,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title ?? 'Không tìm thấy',
      message: message ?? 'Nội dung bạn tìm kiếm không tồn tại.',
      icon: Icons.search_off,
      buttonText: 'Quay lại',
      onRetry: onGoBack ?? () => Navigator.of(context).pop(),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyWidget({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && buttonText != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              CustomButton(
                text: buttonText!,
                onPressed: onAction,
                type: ButtonType.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specialized empty widgets
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyCartWidget({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Giỏ hàng trống',
      message: 'Bạn chưa có sản phẩm nào trong giỏ hàng.\nHãy bắt đầu mua sắm ngay!',
      icon: Icons.shopping_cart_outlined,
      buttonText: 'Mua sắm ngay',
      onAction: onStartShopping,
    );
  }
}

class EmptyWishlistWidget extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyWishlistWidget({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Danh sách yêu thích trống',
      message: 'Bạn chưa có sản phẩm yêu thích nào.\nHãy khám phá và thêm sản phẩm!',
      icon: Icons.favorite_border,
      buttonText: 'Khám phá sản phẩm',
      onAction: onStartShopping,
    );
  }
}

class EmptyOrderWidget extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyOrderWidget({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Chưa có đơn hàng',
      message: 'Bạn chưa có đơn hàng nào.\nHãy bắt đầu mua sắm!',
      icon: Icons.receipt_long_outlined,
      buttonText: 'Mua sắm ngay',
      onAction: onStartShopping,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchWidget({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Không tìm thấy kết quả',
      message: searchQuery != null
          ? 'Không tìm thấy sản phẩm nào cho "$searchQuery".\nHãy thử từ khóa khác.'
          : 'Không tìm thấy sản phẩm nào.\nHãy thử từ khóa khác.',
      icon: Icons.search_off,
      buttonText: 'Xóa tìm kiếm',
      onAction: onClearSearch,
    );
  }
}