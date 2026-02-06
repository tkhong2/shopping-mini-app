import 'package:flutter/material.dart';

class GoMallCategoryGrid extends StatelessWidget {
  const GoMallCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First row
          Row(
            children: [
              _buildCategoryItem(
                'Chơi Game\nCào LIXI',
                'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=100&h=100&fit=crop',
                Icons.gamepad,
                Colors.orange,
              ),
              _buildCategoryItem(
                'GoMallVIP\nGiảm 50%',
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
                Icons.workspace_premium,
                Colors.amber,
              ),
              _buildCategoryItem(
                'Đại Siêu Thị\nOnline',
                'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=100&h=100&fit=crop',
                Icons.shopping_cart,
                Colors.green,
              ),
              _buildCategoryItem(
                'Hot Coupon\nMỗi Ngày',
                'https://images.unsplash.com/photo-1607083206325-caf1edba7a0f?w=100&h=100&fit=crop',
                Icons.local_fire_department,
                Colors.purple,
              ),
              _buildCategoryItem(
                'GoMall Trading',
                'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=100&h=100&fit=crop',
                Icons.trending_up,
                Colors.blue,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Second row
          Row(
            children: [
              _buildCategoryItem(
                '2/2 Săm Tết\nVui',
                'https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?w=100&h=100&fit=crop',
                Icons.celebration,
                Colors.red,
              ),
              _buildCategoryItem(
                'Quà Tặng Tết',
                'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?w=100&h=100&fit=crop',
                Icons.card_giftcard,
                Colors.orange,
              ),
              _buildCategoryItem(
                'Tết Xinh Hết\nNấc',
                'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=100&h=100&fit=crop',
                Icons.face_retouching_natural,
                Colors.pink,
              ),
              _buildCategoryItem(
                'Tết Tri Thức',
                'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=100&h=100&fit=crop',
                Icons.menu_book,
                Colors.brown,
              ),
              _buildCategoryItem(
                'Xả Kho\nNgày Tết',
                'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?w=100&h=100&fit=crop',
                Icons.local_offer,
                Colors.blueGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imageUrl, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Handle category tap
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Background image with overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: color.withOpacity(0.1),
                          );
                        },
                      ),
                    ),
                  ),
                  // Color overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
