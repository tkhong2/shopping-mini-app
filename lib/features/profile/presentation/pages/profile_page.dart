import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../order/presentation/provider/order_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<OrderProvider>().loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          _buildAppBar(context),
          
          // User Info Section
          SliverToBoxAdapter(
            child: _buildUserInfo(user, context, isLoggedIn),
          ),
          
          // Order Status Section
          SliverToBoxAdapter(
            child: _buildOrderStatusSection(context, isLoggedIn),
          ),
          
          // Account Menu (if logged in)
          if (isLoggedIn) ...[
            SliverToBoxAdapter(
              child: _buildAccountMenu(context),
            ),
          ],
          
          // Settings Menu
          SliverToBoxAdapter(
            child: _buildSettingsMenu(context),
          ),
          
          // Logout Button (if logged in)
          if (isLoggedIn)
            SliverToBoxAdapter(
              child: _buildLogoutButton(context),
            ),
          
          SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A94FF),
      title: const Text(
        'Tài khoản',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(RouteNames.settings),
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildUserInfo(User? user, BuildContext context, bool isLoggedIn) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A94FF), Color(0xFF4DA8FF)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: isLoggedIn && user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: !isLoggedIn || user?.photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Color(0xFF1A94FF))
                    : null,
              ),
              if (isLoggedIn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => context.push(RouteNames.editProfile),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF1A94FF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoggedIn) ...[
                  Text(
                    user?.displayName ?? 'Người dùng',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'Thành viên',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Chưa đăng nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A94FF),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập / Đăng ký',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection(BuildContext context, bool isLoggedIn) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Count orders by status
        final pendingCount = orderProvider.orders.where((o) => o.status == 'Chờ xác nhận').length;
        final processingCount = orderProvider.orders.where((o) => o.status == 'Đang xử lý').length;
        final shippingCount = orderProvider.orders.where((o) => o.status == 'Đang giao').length;
        final completedCount = orderProvider.orders.where((o) => o.status == 'Hoàn thành').length;
        final cancelledCount = orderProvider.orders.where((o) => o.status == 'Đã hủy').length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn hàng của tôi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                    child: const Row(
                      children: [
                        Text('Xem tất cả', style: TextStyle(fontSize: 14)),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderStatusItem(
                    Icons.schedule,
                    'Chờ xác\nnhận',
                    pendingCount,
                    () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                  _buildOrderStatusItem(
                    Icons.inventory_2_outlined,
                    'Đang xử lý',
                    processingCount,
                    () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                  _buildOrderStatusItem(
                    Icons.local_shipping_outlined,
                    'Đang giao',
                    shippingCount,
                    () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                  _buildOrderStatusItem(
                    Icons.check_circle_outline,
                    'Hoàn thành',
                    completedCount,
                    () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                  _buildOrderStatusItem(
                    Icons.cancel_outlined,
                    'Đã hủy',
                    cancelledCount,
                    () {
                      if (isLoggedIn) {
                        context.push(RouteNames.orderHistory);
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusItem(
    IconData icon,
    String label,
    int count,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28, color: const Color(0xFF1A94FF)),
              if (count > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () => context.push(RouteNames.editProfile),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ giao hàng',
            onTap: () => context.push(RouteNames.addresses),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Sản phẩm yêu thích',
            onTap: () => context.push(RouteNames.wishlist),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email == 'admin@gomall.com'; // Simple admin check
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Admin access (only for admin users)
          if (isAdmin) ...[
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              title: 'Quản trị viên',
              onTap: () => context.push('/admin'),
              iconColor: Colors.red,
            ),
            Divider(height: 1, color: Colors.grey[200]),
          ],
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Trung tâm trợ giúp',
            onTap: () => context.push(RouteNames.help),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildMenuItem(
            icon: Icons.chat_outlined,
            title: 'Liên hệ hỗ trợ',
            onTap: () => context.push(RouteNames.contact),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF1A94FF)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: iconColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go(RouteNames.home);
              }
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}