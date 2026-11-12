import 'package:flutter/material.dart';
import 'screens/login_page.dart';
void main() {
  runApp(const KayraCraftApp());
}
class KayraCraftApp extends StatelessWidget {
  const KayraCraftApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kayra Craft',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B7653),
        ),
        fontFamily: 'sans',
      ),
      home: const LoginPage(),
    );
  }
}