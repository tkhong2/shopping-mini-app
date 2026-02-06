import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/flash_sale_entity.dart';

class FlashSaleSection extends StatefulWidget {
  final List<FlashSaleEntity> flashSales;

  const FlashSaleSection({
    super.key,
    required this.flashSales,
  });

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashSales.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingM),
          _buildFlashSaleList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flash_on,
            color: AppColors.textWhite,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            'Flash Sale',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          StreamBuilder<DateTime>(
            stream: _timeStream,
            builder: (context, snapshot) {
              return _buildCountdown();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    // Get the nearest flash sale end time
    final now = DateTime.now();
    final activeFlashSale = widget.flashSales
        .where((sale) => sale.isActive && sale.endTime.isAfter(now))
        .isNotEmpty
        ? widget.flashSales
            .where((sale) => sale.isActive && sale.endTime.isAfter(now))
            .reduce((a, b) => a.endTime.isBefore(b.endTime) ? a : b)
        : null;

    if (activeFlashSale == null) {
      return Text(
        'Đã kết thúc',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final duration = activeFlashSale.endTime.difference(now);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        _buildTimeBox(hours),
        const Text(':', style: TextStyle(color: AppColors.textWhite)),
        _buildTimeBox(minutes),
        const Text(':', style: TextStyle(color: AppColors.textWhite)),
        _buildTimeBox(seconds),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFlashSaleList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.flashSales.length,
        itemBuilder: (context, index) {
          final flashSale = widget.flashSales[index];
          return _buildFlashSaleItem(flashSale);
        },
      ),
    );
  }

  Widget _buildFlashSaleItem(FlashSaleEntity flashSale) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusM),
                ),
                child: CachedNetworkImage(
                  imageUrl: flashSale.productImage,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 100,
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    color: AppColors.background,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              
              // Discount badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${flashSale.discountPercentage}%',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    flashSale.productName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(flashSale.salePrice),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  Text(
                    Formatters.formatCurrency(flashSale.originalPrice),
                    style: AppTextStyles.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã bán ${flashSale.soldQuantity}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      LinearProgressIndicator(
                        value: flashSale.soldPercentage / 100,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}