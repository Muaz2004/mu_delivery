import 'package:flutter/material.dart';
import 'package:mu_delivery/orders_page.dart';
import 'package:mu_delivery/app_drawer.dart';
import 'package:mu_delivery/resfood_page.dart';
import 'package:mu_delivery/watchlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ResfoodPage(),   // Home
    const OrdersPage(),    // Orders
    const WatchlistPage(), // Watchlist
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =====================
      // App Bar
      // =====================
      appBar: AppBar(
        title: const Text(
          'Mu Delivery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFFFAB91),
        elevation: 2,
        centerTitle: true,
      ),

      // =====================
      // Universal Drawer (Profile + Logout)
      // =====================
      drawer: const AppDrawer(),

      // =====================
      // Page Body
      // =====================
      body: _pages[_currentIndex],

      // =====================
      // Bottom Navigation Bar
      // =====================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFF7043),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
