import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class AddressItem {
  final String id;
  final String name;
  final String phone;
  final String address;
  bool isDefault;

  AddressItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'isDefault': isDefault,
    };
  }

  // Create from JSON
  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class AddressProvider extends ChangeNotifier {
  static const String _storageKeyPrefix = 'user_addresses_';
  final List<AddressItem> _addresses = [];
  bool _isLoaded = false;
  String? _currentUserId;

  List<AddressItem> get addresses => _addresses;
  bool get isLoaded => _isLoaded;

  AddressItem? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  String _getStorageKey() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    return '$_storageKeyPrefix$userId';
  }

  // Load addresses from local storage
  Future<void> loadAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest';
      
      // If user changed, reload
      if (_currentUserId != userId) {
        _currentUserId = userId;
        _isLoaded = false;
        _addresses.clear();
      }

      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey();
      final addressesJson = prefs.getString(storageKey);

      debugPrint('Loading addresses for user: $userId');
      debugPrint('Storage key: $storageKey');
      debugPrint('Addresses JSON: $addressesJson');

      if (addressesJson != null && addressesJson.isNotEmpty) {
        final List<dynamic> addressesList = json.decode(addressesJson);
        _addresses.clear();
        _addresses.addAll(
          addressesList.map((addrJson) => AddressItem.fromJson(addrJson as Map<String, dynamic>)),
        );
        debugPrint('Loaded ${_addresses.length} addresses');
      } else {
        // Add default addresses if none exist
        debugPrint('No addresses found, creating defaults');
        _addresses.addAll([
          AddressItem(
            id: '1',
            name: 'Nguyễn Văn A',
            phone: '0123456789',
            address: '123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
            isDefault: true,
          ),
          AddressItem(
            id: '2',
            name: 'Nguyễn Văn A',
            phone: '0123456789',
            address: '456 Đường DEF, Phường UVW, Quận 2, TP.HCM',
            isDefault: false,
          ),
        ]);
        await _saveAddresses();
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      _isLoaded = true;
    }
  }

  // Save addresses to local storage
  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey();
      final addressesJson = json.encode(_addresses.map((addr) => addr.toJson()).toList());
      await prefs.setString(storageKey, addressesJson);
      debugPrint('Saved ${_addresses.length} addresses to storage with key: $storageKey');
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  Future<void> addAddress({
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
  }) async {
    final newAddress = AddressItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      address: address,
      isDefault: isDefault,
    );

    if (isDefault) {
      // Set all other addresses to non-default
      for (var addr in _addresses) {
        addr.isDefault = false;
      }
    }

    _addresses.add(newAddress);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String address,
  }) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      _addresses[index] = AddressItem(
        id: id,
        name: name,
        phone: phone,
        address: address,
        isDefault: _addresses[index].isDefault,
      );
      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      final wasDefault = _addresses[index].isDefault;
      _addresses.removeAt(index);

      // If deleted address was default, set first address as default
      if (wasDefault && _addresses.isNotEmpty) {
        _addresses.first.isDefault = true;
      }

      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    // Set all addresses to non-default
    for (var addr in _addresses) {
      addr.isDefault = false;
    }

    // Set selected address as default
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      _addresses[index].isDefault = true;
      await _saveAddresses();
      notifyListeners();
    }
  }

  // Clear all addresses (for testing or logout)
  Future<void> clearAddresses() async {
    _addresses.clear();
    await _saveAddresses();
    notifyListeners();
  }
}
