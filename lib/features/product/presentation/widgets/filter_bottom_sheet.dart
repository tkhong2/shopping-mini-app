import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/product_list/product_list_bloc.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000000);
  double _minRating = 0;
  final Set<String> _selectedBrands = {};

  final List<String> _brands = [
    'Apple',
    'Samsung',
    'Xiaomi',
    'Oppo',
    'Vivo',
    'Huawei',
    'Realme',
    'OnePlus',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceFilter(),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  _buildRatingFilter(),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  _buildBrandFilter(),
                ],
              ),
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: CustomButton(
                      text: 'Áp dụng',
                      onPressed: _applyFilters,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khoảng giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000000,
          divisions: 100,
          activeColor: AppColors.primary,
          labels: RangeLabels(
            PriceFormatter.format(_priceRange.start),
            PriceFormatter.format(_priceRange.end),
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              PriceFormatter.format(_priceRange.start),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              PriceFormatter.format(_priceRange.end),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá tối thiểu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 5,
          activeColor: AppColors.primary,
          label: '${_minRating.toInt()} sao',
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < _minRating ? Icons.star : Icons.star_border,
                color: AppColors.warning,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
            Text('${_minRating.toInt()} sao trở lên'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thương hiệu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _brands.map((brand) {
            final isSelected = _selectedBrands.contains(brand);
            return FilterChip(
              label: Text(brand),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBrands.add(brand);
                  } else {
                    _selectedBrands.remove(brand);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 10000000);
      _minRating = 0;
      _selectedBrands.clear();
    });
  }

  void _applyFilters() {
    context.read<ProductListBloc>().add(
      FilterProducts(
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minRating: _minRating > 0 ? _minRating : null,
        brands: _selectedBrands.isNotEmpty ? _selectedBrands.toList() : null,
      ),
    );
    Navigator.of(context).pop();
  }
}