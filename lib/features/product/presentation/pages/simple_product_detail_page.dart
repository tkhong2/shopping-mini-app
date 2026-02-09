import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../../core/utils/formatters.dart';
import '../../data/services/firebase_product_service.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/provider/simple_cart_provider.dart';

class SimpleProductDetailPage extends StatefulWidget {
  final String productId;
  
  const SimpleProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<SimpleProductDetailPage> createState() => _SimpleProductDetailPageState();
}

class _SimpleProductDetailPageState extends State<SimpleProductDetailPage> {
  final _productService = FirebaseProductService();
  int _currentImageIndex = 0;
  int _quantity = 1;
  Map<String, dynamic>? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    // Clear any snackbars when leaving the page
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (e) {
      // Ignore if context is not available
    }
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await _productService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading product: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Check if user is logged in
  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Show login dialog
  Future<void> _showLoginDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text(
          'Bạn cần đăng nhập để thêm sản phẩm vào giỏ hàng hoặc mua hàng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A94FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      context.push('/login');
    }
  }

  // Add to cart with login check
  Future<void> _addToCart() async {
    if (!_isUserLoggedIn()) {
      await _showLoginDialog();
      return;
    }

    if (_product == null) return;

    try {
      final images = _product!['images'] as List<dynamic>? ?? [];
      final imageUrl = images.isNotEmpty ? images.first as String : '';

      // Use SimpleCartProvider instead of FirebaseCartService
      final cartItem = CartItemEntity(
        id: '${widget.productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.productId,
        productName: _product!['name'] as String? ?? '',
        productImage: imageUrl,
        price: (_product!['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (_product!['originalPrice'] as num?)?.toDouble(),
        quantity: _quantity,
        selectedVariantId: null,
        selectedVariants: {},
        maxQuantity: (_product!['stock'] as num?)?.toInt() ?? 999,
        addedAt: DateTime.now(),
      );

      if (mounted) {
        context.read<SimpleCartProvider>().addToCart(cartItem);
        
        // Use ScaffoldMessenger with simpler config
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Đã thêm $_quantity sản phẩm vào giỏ hàng'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      context.push('/cart');
                    },
                    child: const Text(
                      'XEM',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Buy now with login check
  Future<void> _buyNow() async {
    if (!_isUserLoggedIn()) {
      await _showLoginDialog();
      return;
    }

    if (_product == null) return;

    try {
      final images = _product!['images'] as List<dynamic>? ?? [];
      final imageUrl = images.isNotEmpty ? images.first as String : '';

      // Add to cart silently (without showing snackbar)
      final cartItem = CartItemEntity(
        id: '${widget.productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.productId,
        productName: _product!['name'] as String? ?? '',
        productImage: imageUrl,
        price: (_product!['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (_product!['originalPrice'] as num?)?.toDouble(),
        quantity: _quantity,
        selectedVariantId: null,
        selectedVariants: {},
        maxQuantity: (_product!['stock'] as num?)?.toInt() ?? 999,
        addedAt: DateTime.now(),
      );

      if (mounted) {
        context.read<SimpleCartProvider>().addToCart(cartItem);
        
        // Navigate directly to checkout without showing snackbar
        await Future.delayed(const Duration(milliseconds: 100));
        context.push('/checkout');
      }
    } catch (e) {
      print('Error in buy now: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sản phẩm'),
          backgroundColor: const Color(0xFF1A94FF),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sản phẩm'),
          backgroundColor: const Color(0xFF1A94FF),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Không tìm thấy sản phẩm'),
        ),
      );
    }

    final images = _product!['images'] as List<dynamic>? ?? [];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Consumer<SimpleCartProvider>(
                            builder: (context, cart, child) {
                              final itemCount = cart.items.length;
                              if (itemCount == 0) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  itemCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => context.push('/cart'),
                  ),
                ],
              ),

              // Product Images
              SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 100),
                              );
                            },
                          );
                        },
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            return Container(
                              width: index == _currentImageIndex ? 20 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: index == _currentImageIndex
                                    ? const Color(0xFF1A94FF)
                                    : Colors.grey.shade300,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'TOP DEAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A94FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'CHÍNH HÃNG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Product Name
                      Text(
                        _product!['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating & Sold
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_product!['rating']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Đã bán ${_product!['soldCount']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Price
                      Row(
                        children: [
                          Text(
                            Formatters.formatCurrency(_product!['price'] as double),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '-${((1 - (_product!['price'] as double) / (_product!['originalPrice'] as double)) * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          Formatters.formatCurrency(_product!['originalPrice'] as double),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Shipping Info
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin vận chuyển',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF1A94FF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giao hàng tiêu chuẩn',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Miễn phí vận chuyển cho đơn hàng từ 300.000đ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Product Description
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _product!['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Bottom Action Bar
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < (_product!['stock'] as int)
                          ? () {
                              setState(() {
                                _quantity++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.add, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A94FF),
                    side: const BorderSide(color: Color(0xFF1A94FF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_cart_outlined, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Thêm vào giỏ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Buy Now Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A94FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
