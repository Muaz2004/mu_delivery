import 'package:flutter/material.dart';
import 'package:mu_delivery/orders_page.dart';
import 'package:mu_delivery/popular_foods.dart';
import 'package:mu_delivery/profile_page.dart';
import 'package:mu_delivery/resfood_page.dart';
import 'package:mu_delivery/restorant_list.dart';

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
    const ProfilePage(),
    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Delivery',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: true,
      ),
      body:_pages[_currentIndex],
    bottomNavigationBar:BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,

          items:const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),

        ],)
    );
  }
}
