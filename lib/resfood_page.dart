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
    // 1. DETECT THEME MODE
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);

    return Scaffold(
      // 2. ADAPTIVE BACKGROUND COLOR
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          "Discover",
          style: TextStyle(
            // Use white text on the orange AppBar for better contrast in both modes
            color: Colors.white, 
            fontWeight: FontWeight.w900, 
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
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
            const SizedBox(height: 20),
            _buildSectionHeader("Popular Foods", "View all", isDark),
            const SizedBox(height: 12),
            const SizedBox(
              height: 210, 
              child: PopularFoods(),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader("Nearby Restaurants", "", isDark),
            const SizedBox(height: 12),
            const RestorantList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 3. PASS isDark TO THE HEADER HELPER
  Widget _buildSectionHeader(String title, String actionText, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            letterSpacing: -0.5,
            // ADAPTIVE TITLE COLOR
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (actionText.isNotEmpty)
          Text(
            actionText,
            style: const TextStyle(
              color: Color(0xFFFF7043), // Use brand color instead of yellow-orange
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}