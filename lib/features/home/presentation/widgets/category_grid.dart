import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/route_names.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục',
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppDimensions.paddingM,
              mainAxisSpacing: AppDimensions.paddingM,
              childAspectRatio: 0.8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryItem(context, category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryItem category) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.productList}?categoryId=${category.id}'),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: category.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              category.icon,
              size: 30,
              color: category.color,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          Text(
            category.name,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Sample categories - in real app, this would come from API
final List<CategoryItem> _categories = [
  CategoryItem(
    id: '1',
    name: 'Thời trang',
    icon: Icons.checkroom,
    color: const Color(0xFFE91E63),
  ),
  CategoryItem(
    id: '2',
    name: 'Điện tử',
    icon: Icons.phone_android,
    color: const Color(0xFF2196F3),
  ),
  CategoryItem(
    id: '3',
    name: 'Gia dụng',
    icon: Icons.home,
    color: const Color(0xFF4CAF50),
  ),
  CategoryItem(
    id: '4',
    name: 'Làm đẹp',
    icon: Icons.face_retouching_natural,
    color: const Color(0xFFFF9800),
  ),
  CategoryItem(
    id: '5',
    name: 'Thể thao',
    icon: Icons.sports_soccer,
    color: const Color(0xFF9C27B0),
  ),
  CategoryItem(
    id: '6',
    name: 'Sách',
    icon: Icons.menu_book,
    color: const Color(0xFF795548),
  ),
  CategoryItem(
    id: '7',
    name: 'Xe cộ',
    icon: Icons.directions_car,
    color: const Color(0xFF607D8B),
  ),
  CategoryItem(
    id: '8',
    name: 'Khác',
    icon: Icons.more_horiz,
    color: const Color(0xFF9E9E9E),
  ),
];