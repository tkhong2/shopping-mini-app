import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../data/services/admin_product_service.dart';
import '../../data/services/admin_category_service.dart';
import '../../data/services/admin_order_service.dart';
import '../../data/services/admin_user_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _productService = AdminProductService();
  final _categoryService = AdminCategoryService();
  final _orderService = AdminOrderService();
  final _userService = AdminUserService();

  int _productCount = 0;
  int _categoryCount = 0;
  int _orderCount = 0;
  int _userCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadStatistics();
      }
    });
  }

  Future<void> _loadStatistics() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      await Future.wait([
        _loadProductCount(),
        _loadCategoryCount(),
        _loadOrderCount(),
        _loadUserCount(),
      ]);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error in _loadStatistics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProductCount() async {
    try {
      // Direct count from Firestore - most accurate
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .count()
          .get();
      
      final count = snapshot.count ?? 0;
      print('📦 Product count from Firestore: $count');
      
      if (mounted) {
        setState(() => _productCount = count);
      }
    } catch (e) {
      print('❌ Error loading product count: $e');
      // Fallback: try getting all docs
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .get();
        if (mounted) {
          setState(() => _productCount = snapshot.docs.length);
        }
      } catch (e2) {
        print('❌ Fallback also failed: $e2');
        if (mounted) {
          setState(() => _productCount = 0);
        }
      }
    }
  }

  Future<void> _loadCategoryCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .count()
          .get();
      if (mounted) {
        setState(() => _categoryCount = snapshot.count ?? 0);
      }
    } catch (e) {
      print('❌ Error loading category count: $e');
      if (mounted) {
        setState(() => _categoryCount = 0);
      }
    }
  }

  Future<void> _loadOrderCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .count()
          .get();
      if (mounted) {
        setState(() => _orderCount = snapshot.count ?? 0);
      }
    } catch (e) {
      print('❌ Error loading order count: $e');
      if (mounted) {
        setState(() => _orderCount = 0);
      }
    }
  }

  Future<void> _loadUserCount() async {
    try {
      // Get all users then filter out admin
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      final nonAdminUsers = snapshot.docs.where((doc) {
        final email = (doc.data()['email'] as String?)?.toLowerCase() ?? '';
        return email != 'admin@gomall.com';
      }).toList();
      
      if (mounted) {
        setState(() => _userCount = nonAdminUsers.length);
      }
    } catch (e) {
      print('❌ Error loading user count: $e');
      if (mounted) {
        setState(() => _userCount = 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Quản trị viên',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A94FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Tổng sản phẩm',
                          _productCount.toString(),
                          Icons.inventory_2,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Đơn hàng',
                          _orderCount.toString(),
                          Icons.shopping_bag,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Người dùng',
                          _userCount.toString(),
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Danh mục',
                          _categoryCount.toString(),
                          Icons.category,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Management Sections
                  const Text(
                    'Quản lý',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildManagementCard(
                    context,
                    'Quản lý sản phẩm',
                    'Thêm, sửa, xóa sản phẩm',
                    Icons.inventory_2_outlined,
                    Colors.blue,
                    () => context.push('/admin/products'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildManagementCard(
                    context,
                    'Quản lý danh mục',
                    'Thêm, sửa, xóa danh mục',
                    Icons.category_outlined,
                    Colors.purple,
                    () => context.push('/admin/categories'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildManagementCard(
                    context,
                    'Quản lý đơn hàng',
                    'Xem và cập nhật trạng thái đơn hàng',
                    Icons.shopping_bag_outlined,
                    Colors.orange,
                    () => context.push('/admin/orders'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildManagementCard(
                    context,
                    'Quản lý người dùng',
                    'Xem danh sách người dùng',
                    Icons.people_outline,
                    Colors.green,
                    () => context.push('/admin/users'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A94FF),
                  Color(0xFF0066CC),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: Color(0xFF1A94FF),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GoMall Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF1A94FF)),
            title: const Text('Tổng quan'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.blue),
            title: const Text('Quản lý sản phẩm'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: Colors.purple),
            title: const Text('Quản lý danh mục'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.orange),
            title: const Text('Quản lý đơn hàng'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.green),
            title: const Text('Quản lý người dùng'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/users');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/home');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
