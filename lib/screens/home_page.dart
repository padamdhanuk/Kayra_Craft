import 'package:flutter/material.dart';
import 'interior_design_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [
    _HomeContent(),
    _FurnitureContent(),
    InteriorDesignPage(),
    _CartContent(),
    _ProfileContent(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.weekend_outlined), label: 'Furniture'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Interior'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Welcome to Kayra Craft',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
class _FurnitureContent extends StatelessWidget {
  const _FurnitureContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Furniture'));
  }
}
class _CartContent extends StatelessWidget {
  const _CartContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Your Cart'));
  }
}
class _ProfileContent extends StatelessWidget {
  const _ProfileContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('My Profile'));
  }
}