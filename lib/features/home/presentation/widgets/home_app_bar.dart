import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                children: [
                  // Top row with logo and icons
                  Row(
                    children: [
                      // Logo and app name
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.textWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Text(
                            'Shopping',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Action icons
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.push('/notifications'),
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.textWhite,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          IconButton(
                            onPressed: () => context.push(RouteNames.cart),
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.textWhite,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: const Text(
                                      '2',
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  // Search bar
                  GestureDetector(
                    onTap: () => context.push(RouteNames.search),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: AppDimensions.paddingM),
                          const Icon(
                            Icons.search,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: Text(
                              'Tìm kiếm sản phẩm...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: AppColors.border,
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Open camera for image search
                            },
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}