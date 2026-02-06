import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../product/domain/entities/product_entity.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gợi ý cho bạn',
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all products
                },
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.paddingM,
              mainAxisSpacing: AppDimensions.paddingM,
              childAspectRatio: 0.7,
            ),
            itemCount: _sampleProducts.length,
            itemBuilder: (context, index) {
              final productData = _sampleProducts[index];
              final product = ProductEntity(
                id: productData['id'],
                name: productData['name'],
                description: productData['description'] ?? '',
                price: productData['price'],
                originalPrice: productData['originalPrice'],
                images: [productData['imageUrl']],
                categoryId: productData['categoryId'] ?? '1',
                categoryName: productData['categoryName'] ?? 'Electronics',
                brand: productData['brand'] ?? 'Unknown',
                rating: productData['rating'],
                reviewCount: productData['reviewCount'],
                soldCount: productData['soldCount'] ?? 0,
                stock: productData['stock'] ?? 10,
                isActive: true,
                createdAt: DateTime.now(),
              );
              
              return ProductCard(
                product: product,
                onTap: () {
                  // TODO: Navigate to product detail
                },
                onFavoriteToggle: () {
                  // TODO: Toggle favorite
                },
                onAddToCart: () {
                  // TODO: Add to cart
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Sample products - in real app, this would come from API
final List<Map<String, dynamic>> _sampleProducts = [
  {
    'id': '1',
    'name': 'iPhone 15 Pro Max 256GB',
    'description': 'Latest iPhone with advanced features',
    'imageUrl': 'https://via.placeholder.com/300x300?text=iPhone+15',
    'price': 29990000.0,
    'originalPrice': 32990000.0,
    'rating': 4.8,
    'reviewCount': 1250,
    'soldCount': 850,
    'stock': 5,
    'categoryId': '1',
    'categoryName': 'Smartphones',
    'brand': 'Apple',
  },
  {
    'id': '2',
    'name': 'Samsung Galaxy S24 Ultra',
    'description': 'Premium Android smartphone',
    'imageUrl': 'https://via.placeholder.com/300x300?text=Galaxy+S24',
    'price': 26990000.0,
    'originalPrice': null,
    'rating': 4.7,
    'reviewCount': 890,
    'soldCount': 650,
    'stock': 8,
    'categoryId': '1',
    'categoryName': 'Smartphones',
    'brand': 'Samsung',
  },
  {
    'id': '3',
    'name': 'MacBook Air M2 13 inch',
    'description': 'Lightweight laptop with M2 chip',
    'imageUrl': 'https://via.placeholder.com/300x300?text=MacBook+Air',
    'price': 24990000.0,
    'originalPrice': 27990000.0,
    'rating': 4.9,
    'reviewCount': 567,
    'soldCount': 320,
    'stock': 3,
    'categoryId': '2',
    'categoryName': 'Laptops',
    'brand': 'Apple',
  },
  {
    'id': '4',
    'name': 'AirPods Pro 2nd Gen',
    'description': 'Wireless earbuds with noise cancellation',
    'imageUrl': 'https://via.placeholder.com/300x300?text=AirPods+Pro',
    'price': 5990000.0,
    'originalPrice': 6990000.0,
    'rating': 4.6,
    'reviewCount': 2340,
    'soldCount': 1850,
    'stock': 15,
    'categoryId': '3',
    'categoryName': 'Audio',
    'brand': 'Apple',
  },
  {
    'id': '5',
    'name': 'iPad Pro 11 inch M4',
    'description': 'Professional tablet with M4 chip',
    'imageUrl': 'https://via.placeholder.com/300x300?text=iPad+Pro',
    'price': 21990000.0,
    'originalPrice': null,
    'rating': 4.8,
    'reviewCount': 445,
    'soldCount': 280,
    'stock': 7,
    'categoryId': '4',
    'categoryName': 'Tablets',
    'brand': 'Apple',
  },
  {
    'id': '6',
    'name': 'Apple Watch Series 9',
    'description': 'Smart watch with health monitoring',
    'imageUrl': 'https://via.placeholder.com/300x300?text=Apple+Watch',
    'price': 8990000.0,
    'originalPrice': 9990000.0,
    'rating': 4.7,
    'reviewCount': 1120,
    'soldCount': 920,
    'stock': 12,
    'categoryId': '5',
    'categoryName': 'Wearables',
    'brand': 'Apple',
  },
];