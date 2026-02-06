import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'core/data/mock_products.dart';
import 'core/utils/formatters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize formatters
  await Formatters.initialize();
  
  // Load mock data from JSON
  await MockProducts.loadData();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const ShoppingApp());
}