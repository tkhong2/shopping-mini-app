import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../provider/home_provider.dart';
import '../widgets/gomall_app_bar.dart';
import '../widgets/gomall_banner_slider.dart';
import '../widgets/gomall_category_grid.dart';
import '../widgets/gomall_flash_sale.dart';
import '../widgets/gomall_product_grid.dart';
import '../widgets/gomall_features_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          return RefreshIndicator(
            onRefresh: () => homeProvider.loadHomeData(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // GoMall App Bar
                const GoMallAppBar(),
                
                // Main Banner
                const SliverToBoxAdapter(
                  child: GoMallBannerSlider(),
                ),
                
                // Category Icons
                const SliverToBoxAdapter(
                  child: GoMallCategoryGrid(),
                ),
                
                // Features Section (GoMall cam kết, etc.)
                const SliverToBoxAdapter(
                  child: GoMallFeaturesSection(),
                ),
                
                // Flash Sale Section
                const SliverToBoxAdapter(
                  child: GoMallFlashSale(),
                ),
                
                // Product Grid
                const SliverToBoxAdapter(
                  child: GoMallProductGrid(),
                ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}