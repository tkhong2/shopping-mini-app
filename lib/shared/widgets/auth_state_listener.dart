import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../features/order/presentation/provider/order_provider.dart';
import '../../features/profile/presentation/provider/address_provider.dart';

class AuthStateListener extends StatefulWidget {
  final Widget child;

  const AuthStateListener({
    super.key,
    required this.child,
  });

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid ?? 'guest';
      
      // If user changed, reload data
      if (_currentUserId != newUserId) {
        debugPrint('User changed from $_currentUserId to $newUserId');
        _currentUserId = newUserId;
        
        // Reload orders and addresses for new user
        if (mounted) {
          context.read<OrderProvider>().loadOrders();
          context.read<AddressProvider>().loadAddresses();
        }
      }
    });
    
    // Initial load
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
