import 'package:flutter/foundation.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/flash_sale_entity.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    dynamic getBannersUseCase,
    dynamic getFlashSalesUseCase,
  }) {
    // Auto load data when provider is created
    loadHomeData();
  }

  List<BannerEntity> _banners = [];
  List<FlashSaleEntity> _flashSales = [];
  bool _isLoading = false;
  String? _error;

  List<BannerEntity> get banners => _banners;
  List<FlashSaleEntity> get flashSales => _flashSales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Compatibility properties
  bool get hasError => _error != null;
  String get errorMessage => _error ?? '';

  Future<void> loadHomeData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load sample data for demo
      await _loadSampleBanners();
      await _loadSampleFlashSales();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> _loadSampleBanners() async {
    // Sample banners for demo
    _banners = [
      BannerEntity(
        id: '1',
        title: 'Flash Sale 12.12',
        description: 'Giảm giá lên đến 50%',
        imageUrl: 'https://via.placeholder.com/400x200?text=Flash+Sale+12.12',
        actionType: 'category',
        actionValue: 'flash-sale',
        isActive: true,
        priority: 1,
        startDate: DateTime.now().subtract(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 7)),
        createdAt: DateTime.now(),
      ),
      BannerEntity(
        id: '2',
        title: 'Siêu Sale Điện Thoại',
        description: 'iPhone, Samsung giá sốc',
        imageUrl: 'https://via.placeholder.com/400x200?text=Dien+Thoai+Sale',
        actionType: 'category',
        actionValue: 'smartphones',
        isActive: true,
        priority: 2,
        startDate: DateTime.now().subtract(Duration(days: 2)),
        endDate: DateTime.now().add(Duration(days: 5)),
        createdAt: DateTime.now(),
      ),
      BannerEntity(
        id: '3',
        title: 'Laptop Gaming Hot',
        description: 'Laptop gaming giá tốt nhất',
        imageUrl: 'https://via.placeholder.com/400x200?text=Laptop+Gaming',
        actionType: 'category',
        actionValue: 'laptops',
        isActive: true,
        priority: 3,
        startDate: DateTime.now().subtract(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 10)),
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _loadSampleFlashSales() async {
    // Sample flash sales for demo
    _flashSales = [
      FlashSaleEntity(
        id: '1',
        productId: '1',
        productName: 'iPhone 15 Pro Max',
        productImage: 'https://via.placeholder.com/200x200?text=iPhone+15',
        originalPrice: 32990000,
        salePrice: 29990000,
        discountPercentage: 9,
        quantity: 100,
        sold: 45,
        startTime: DateTime.now().subtract(Duration(hours: 2)),
        endTime: DateTime.now().add(Duration(hours: 22)),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      FlashSaleEntity(
        id: '2',
        productId: '2',
        productName: 'Samsung Galaxy S24 Ultra',
        productImage: 'https://via.placeholder.com/200x200?text=Galaxy+S24',
        originalPrice: 28990000,
        salePrice: 24990000,
        discountPercentage: 14,
        quantity: 50,
        sold: 23,
        startTime: DateTime.now().subtract(Duration(hours: 1)),
        endTime: DateTime.now().add(Duration(hours: 23)),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      FlashSaleEntity(
        id: '3',
        productId: '3',
        productName: 'MacBook Air M2',
        productImage: 'https://via.placeholder.com/200x200?text=MacBook+Air',
        originalPrice: 27990000,
        salePrice: 24990000,
        discountPercentage: 11,
        quantity: 30,
        sold: 12,
        startTime: DateTime.now().subtract(Duration(minutes: 30)),
        endTime: DateTime.now().add(Duration(hours: 23, minutes: 30)),
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    loadHomeData();
  }
}