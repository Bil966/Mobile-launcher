import 'package:flutter/material.dart';
import 'package:geode_mod_manager/screens/home_screen.dart';
import 'package:geode_mod_manager/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeodeModManagerApp());
}

class GeodeModManagerApp extends StatelessWidget {
  const GeodeModManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geode Mod Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
