import 'package:flutter/material.dart';

class AdminWrapper extends StatelessWidget {
  final Widget child;

  const AdminWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Admin pages don't need bottom navigation
    // Just return the child directly
    return child;
  }
}
