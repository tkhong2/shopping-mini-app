import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../features/notifications/presentation/provider/notification_provider.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;

  const MainWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.category);
        break;
      case 2:
        context.go(RouteNames.notifications);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final currentLocation = GoRouterState.of(context).uri.path;
    if (currentLocation == RouteNames.home) {
      _currentIndex = 0;
    } else if (currentLocation == RouteNames.category) {
      _currentIndex = 1;
    } else if (currentLocation == RouteNames.notifications) {
      _currentIndex = 2;
    } else if (currentLocation == RouteNames.profile) {
      _currentIndex = 3;
    }

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF1A94FF),
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: AppColors.surface,
            elevation: 8,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Danh mục',
              ),
              BottomNavigationBarItem(
                icon: _buildNotificationIcon(unreadCount, false),
                activeIcon: _buildNotificationIcon(unreadCount, true),
                label: 'Thông báo',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon(int unreadCount, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isActive ? Icons.notifications : Icons.notifications_outlined,
        ),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
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
    );
  }
}