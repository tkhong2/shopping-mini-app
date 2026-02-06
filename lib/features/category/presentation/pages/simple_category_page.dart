import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_products.dart';
import 'category_products_page.dart';

class SimpleCategoryPage extends StatefulWidget {
  const SimpleCategoryPage({super.key});

  @override
  State<SimpleCategoryPage> createState() => _SimpleCategoryPageState();
}

class _SimpleCategoryPageState extends State<SimpleCategoryPage> {
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategoryId = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categories = MockProducts.categories;
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first['id'] as String;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm danh mục...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.push('/search');
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar
          Container(
            width: 90,
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isActive = category['id'] == _selectedCategoryId;
                return _buildSidebarItem(
                  category['name'] as String,
                  category['icon'] as String,
                  isActive,
                  () {
                    setState(() {
                      _selectedCategoryId = category['id'] as String;
                    });
                  },
                );
              },
            ),
          ),
          
          // Right content
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildCategoryContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent() {
    final selectedCategory = _categories.firstWhere(
      (c) => c['id'] == _selectedCategoryId,
      orElse: () => _categories.first,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Category header
        Row(
          children: [
            Text(
              selectedCategory['icon'] as String,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${selectedCategory['productCount']} sản phẩm',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsPage(
                      categoryId: selectedCategory['id'] as String,
                      categoryName: selectedCategory['name'] as String,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // All categories grid
        const Text(
          'Tất cả danh mục:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(
              category['name'] as String,
              category['icon'] as String,
              category['id'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSidebarItem(String title, String emoji, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0F8FF) : Colors.white,
          border: Border(
            left: BorderSide(
              color: isActive ? const Color(0xFF1A94FF) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF1A94FF) : Colors.grey.shade700,
                height: 1.2,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String emoji, String categoryId) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              categoryId: categoryId,
              categoryName: title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
