import 'package:flutter/material.dart';
import 'package:mu_delivery/popular_foods.dart';
import 'package:mu_delivery/restorant_list.dart';
import 'package:mu_delivery/globals.dart';

class ResfoodPage extends StatefulWidget {
  const ResfoodPage({super.key});

  @override
  State<ResfoodPage> createState() => _ResfoodPageState();
}

class _ResfoodPageState extends State<ResfoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Subtle grey background for contrast
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7043),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {
            // This uses the remote control to open the drawer
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "Discover",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 28),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionHeader("Popular Foods", "View all"),
            const SizedBox(height: 12),
            const SizedBox(
              height: 210, // Adjusted height for new card style
              child: PopularFoods(),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader("Nearby Restaurants", ""),
            const SizedBox(height: 12),
            const RestorantList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        if (actionText.isNotEmpty)
          Text(
            actionText,
            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}