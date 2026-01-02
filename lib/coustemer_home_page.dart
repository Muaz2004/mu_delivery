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
    const ResfoodPage(),   
    const OrdersPage(),    
    const WatchlistPage(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2025 Food App Theme Colors
    const Color activeColor = Color(0xFFFF7043); // Your signature orange
    const Color inactiveColor = Color(0xFF9E9E9E); // Clean medium grey

    return Scaffold(
      // The drawer can be opened by swiping or a menu button on sub-pages
      drawer: const AppDrawer(),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // =====================
      // Modern Food App Style Bottom Bar
      // =====================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1), // Subtle top line
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // Very soft shadow
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              selectedItemColor: activeColor,
              unselectedItemColor: inactiveColor,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              items: [
                _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Home', 0),
                _buildNavItem(Icons.shopping_bag, Icons.shopping_bag_outlined, 'Orders', 1),
                _buildNavItem(Icons.favorite, Icons.favorite_outline_rounded, 'Watchlist', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to switch between solid and outlined icons based on selection
  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _currentIndex == index ? activeIcon : inactiveIcon,
        size: 26,
      ),
      label: label,
    );
  }
}