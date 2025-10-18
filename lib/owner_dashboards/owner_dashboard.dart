import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'owner_orders.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _selectedIndex = 0;

  final Color appBarColor = const Color(0xFFFF7043);
  final Color cardColor = const Color(0xFFFFAB91);
  final Color backgroundColor = const Color(0xFFFFF3E0);

  @override
  Widget build(BuildContext context) {
    final String ownerId = FirebaseAuth.instance.currentUser!.uid;
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Owner Dashboard' : 'My Orders'),
        backgroundColor: appBarColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _showProfile(context),
                child: const Icon(Icons.person, color: Colors.black87, size: 28),
              ),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Restorant_table')
                  .where('owner_id', isEqualTo: ownerId)
                  .get(),
              builder: (context, restaurantSnapshot) {
                if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!restaurantSnapshot.hasData || restaurantSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "You don't have any registered restaurants.",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  );
                }

                final restaurantIds = restaurantSnapshot.data!.docs.map((doc) => doc.id).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('restaurantId', whereIn: restaurantIds)
                      .snapshots(),
                  builder: (context, orderSnapshot) {
                    if (orderSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final orders = orderSnapshot.data?.docs ?? [];
                    final total = orders.length;
                    final pending = orders.where((o) => (o['status'] ?? '') == 'pending').length;
                    final delivered = orders.where((o) => (o['status'] ?? '') == 'delivered').length;

                    return _buildDashboardUI(
                      formattedDate,
                      total: total,
                      pending: pending,
                      delivered: delivered,
                      restaurants: restaurantIds.length,
                    );
                  },
                );
              },
            )
          : const OwnerOrders(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: appBarColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
        ],
      ),
    );
  }

  // Profile modal with vertical details (compact & scrollable)
  void _showProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: user!.uid)
        .get();

    final userData = userSnapshot.docs.isNotEmpty ? userSnapshot.docs.first.data() : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allow scrolling if content is large
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.account_circle, size: 80, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text('Name: ${userData?['name'] ?? 'Unknown'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Email: ${userData?['email'] ?? 'Unknown'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Mobile: ${userData?['mobile'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Role: ${userData?['role'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appBarColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout', style: TextStyle(fontSize: 16)),
                  onPressed:() async {
                  await context.read<myProvider>().signOut();
                  Navigator.of(context).pop(); // Log out the user
                },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardUI(String formattedDate,
      {required int total,
      required int pending,
      required int delivered,
      required int restaurants}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Greeting
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '👋 Welcome back, Owner!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(formattedDate, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 24),

        // Summary Cards (horizontal rows)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryCard('Total Orders', total.toString(), Icons.shopping_bag),
            const SizedBox(width: 12),
            _buildSummaryCard('Pending', pending.toString(), Icons.timelapse),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryCard('Delivered', delivered.toString(), Icons.check_circle),
            const SizedBox(width: 12),
            _buildSummaryCard('Restaurants', restaurants.toString(), Icons.restaurant),
          ],
        ),

        const SizedBox(height: 32),
        const Divider(thickness: 1.5),
        const SizedBox(height: 12),
        const Text('📅 Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.white),
            title: Text(
              pending > 0 ? "You have $pending pending orders." : "All orders are up to date!",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            subtitle: Text('Total $total orders processed.'),
          ),
        ),
      ]),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
