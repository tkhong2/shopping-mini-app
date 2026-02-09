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
        
        // Remove duplicates based on id first, then by content
        final seenIds = <String>{};
        final seenContent = <String>{};
        _addresses.removeWhere((addr) {
          // Check duplicate by ID
          if (seenIds.contains(addr.id)) {
            debugPrint('Removing duplicate address with ID: ${addr.id}');
            return true;
          }
          
          // Check duplicate by content
          final contentKey = '${addr.name}_${addr.phone}_${addr.address}';
          if (seenContent.contains(contentKey)) {
            debugPrint('Removing duplicate address with same content: $contentKey');
            return true;
          }
          
          seenIds.add(addr.id);
          seenContent.add(contentKey);
          return false;
        });
        
        // Ensure only one default address
        final defaultAddresses = _addresses.where((addr) => addr.isDefault).toList();
        if (defaultAddresses.length > 1) {
          debugPrint('Found ${defaultAddresses.length} default addresses, fixing...');
          // Keep only the first default, set others to false
          for (int i = 1; i < defaultAddresses.length; i++) {
            defaultAddresses[i].isDefault = false;
          }
          await _saveAddresses();
        } else if (defaultAddresses.isEmpty && _addresses.isNotEmpty) {
          // If no default, set first as default
          debugPrint('No default address found, setting first as default');
          _addresses.first.isDefault = true;
          await _saveAddresses();
        }
        
        debugPrint('Loaded ${_addresses.length} addresses after cleanup');
      } else {
        // Add default address if none exist
        debugPrint('No addresses found, creating default');
        _addresses.add(
          AddressItem(
            id: '1',
            name: 'Nguyễn Văn A',
            phone: '0123456789',
            address: '123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
            isDefault: true,
          ),
        );
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
    // Check for duplicate content
    final contentKey = '${name}_${phone}_$address';
    final isDuplicate = _addresses.any((addr) {
      final existingKey = '${addr.name}_${addr.phone}_${addr.address}';
      return existingKey == contentKey;
    });
    
    if (isDuplicate) {
      debugPrint('Address already exists, skipping add');
      return;
    }
    
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
    } else if (_addresses.isEmpty) {
      // If this is the first address, make it default
      newAddress.isDefault = true;
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
  
  // Force cleanup duplicates and fix default addresses
  Future<void> cleanupAddresses() async {
    debugPrint('Running cleanup on ${_addresses.length} addresses');
    
    // Remove duplicates by ID
    final seenIds = <String>{};
    final seenContent = <String>{};
    _addresses.removeWhere((addr) {
      if (seenIds.contains(addr.id)) {
        debugPrint('Cleanup: Removing duplicate ID ${addr.id}');
        return true;
      }
      
      final contentKey = '${addr.name}_${addr.phone}_${addr.address}';
      if (seenContent.contains(contentKey)) {
        debugPrint('Cleanup: Removing duplicate content');
        return true;
      }
      
      seenIds.add(addr.id);
      seenContent.add(contentKey);
      return false;
    });
    
    // Fix default addresses
    final defaultAddresses = _addresses.where((addr) => addr.isDefault).toList();
    if (defaultAddresses.length > 1) {
      debugPrint('Cleanup: Found ${defaultAddresses.length} defaults, keeping only first');
      for (int i = 1; i < defaultAddresses.length; i++) {
        defaultAddresses[i].isDefault = false;
      }
    } else if (defaultAddresses.isEmpty && _addresses.isNotEmpty) {
      debugPrint('Cleanup: No default found, setting first as default');
      _addresses.first.isDefault = true;
    }
    
    await _saveAddresses();
    notifyListeners();
    debugPrint('Cleanup complete: ${_addresses.length} addresses remaining');
  }
}
