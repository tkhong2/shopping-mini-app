import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> setObject(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> setList(String key, List<String> value);
  Future<List<String>?> getList(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

class StorageServiceImpl implements StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> setString(String key, String value) async {
    final preferences = await prefs;
    await preferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final preferences = await prefs;
    return preferences.getString(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final preferences = await prefs;
    await preferences.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final preferences = await prefs;
    return preferences.getInt(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final preferences = await prefs;
    await preferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final preferences = await prefs;
    return preferences.getBool(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    final preferences = await prefs;
    await preferences.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    final preferences = await prefs;
    return preferences.getDouble(key);
  }

  @override
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    final preferences = await prefs;
    final jsonString = jsonEncode(value);
    await preferences.setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    final preferences = await prefs;
    final jsonString = preferences.getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setList(String key, List<String> value) async {
    final preferences = await prefs;
    await preferences.setStringList(key, value);
  }

  @override
  Future<List<String>?> getList(String key) async {
    final preferences = await prefs;
    return preferences.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    final preferences = await prefs;
    await preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    final preferences = await prefs;
    await preferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    final preferences = await prefs;
    return preferences.containsKey(key);
  }
}

// Extension methods for common operations
extension StorageServiceExtensions on StorageService {
  // User token operations
  Future<void> saveUserToken(String token) async {
    await setString('user_token', token);
  }

  Future<String?> getUserToken() async {
    return await getString('user_token');
  }

  Future<void> removeUserToken() async {
    await remove('user_token');
  }

  // User data operations
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setObject('user_data', userData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await getObject('user_data');
  }

  Future<void> removeUserData() async {
    await remove('user_data');
  }

  // Cart operations
  Future<void> saveCartData(List<Map<String, dynamic>> cartItems) async {
    final cartData = {'items': cartItems, 'updatedAt': DateTime.now().toIso8601String()};
    await setObject('cart_data', cartData);
  }

  Future<List<Map<String, dynamic>>?> getCartData() async {
    final cartData = await getObject('cart_data');
    if (cartData == null) return null;
    
    final items = cartData['items'] as List?;
    return items?.cast<Map<String, dynamic>>();
  }

  Future<void> removeCartData() async {
    await remove('cart_data');
  }

  // Wishlist operations
  Future<void> saveWishlistData(List<String> productIds) async {
    await setList('wishlist_data', productIds);
  }

  Future<List<String>?> getWishlistData() async {
    return await getList('wishlist_data');
  }

  Future<void> removeWishlistData() async {
    await remove('wishlist_data');
  }

  // Theme operations
  Future<void> saveThemeMode(String themeMode) async {
    await setString('theme_mode', themeMode);
  }

  Future<String?> getThemeMode() async {
    return await getString('theme_mode');
  }

  // Language operations
  Future<void> saveLanguage(String languageCode) async {
    await setString('language', languageCode);
  }

  Future<String?> getLanguage() async {
    return await getString('language');
  }

  // First time user
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await setBool('is_first_time', isFirstTime);
  }

  Future<bool> isFirstTimeUser() async {
    return await getBool('is_first_time') ?? true;
  }

  // Search history
  Future<void> saveSearchHistory(List<String> searchHistory) async {
    await setList('search_history', searchHistory);
  }

  Future<List<String>?> getSearchHistory() async {
    return await getList('search_history');
  }

  Future<void> addToSearchHistory(String query) async {
    final history = await getSearchHistory() ?? [];
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    await saveSearchHistory(history);
  }

  Future<void> clearSearchHistory() async {
    await remove('search_history');
  }
}