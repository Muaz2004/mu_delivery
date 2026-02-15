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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Premium Color Palette
  final Color brandOrange = const Color(0xFFFF7043);
  final Color bgLight = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String ownerId = FirebaseAuth.instance.currentUser!.uid;
    final String formattedDate = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      key: _scaffoldKey, // Key for the drawer leading icon
      backgroundColor: isDark ? const Color(0xFF121212) : bgLight,
      // --- UPDATED CONSISTENT APPBAR ---
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _selectedIndex == 0 ? 'Dashboard' : 'Orders',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
              onPressed: () => _showProfile(context),
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
                  return Center(child: CircularProgressIndicator(color: brandOrange));
                }

                if (!restaurantSnapshot.hasData || restaurantSnapshot.data!.docs.isEmpty) {
                  return _buildEmptyDashboard();
                }

                final restaurantIds = restaurantSnapshot.data!.docs.map((doc) => doc.id).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('restaurantId', whereIn: restaurantIds)
                      .snapshots(),
                  builder: (context, orderSnapshot) {
                    if (orderSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: brandOrange));
                    }

                    final orders = orderSnapshot.data?.docs ?? [];
                    final total = orders.length;
                    final pending = orders.where((o) => (o['status'] ?? '') == 'pending').length;
                    final delivered = orders.where((o) => (o['status'] ?? '') == 'delivered').length;

                    return _buildDashboardUI(
                      formattedDate,
                      isDark,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: brandOrange,
          unselectedItemColor: Colors.grey,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Status'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Orders'),
          ],
        ),
      ),
    );
  }

  // --- REST OF THE UI ELEMENTS YOU LOVED ---

  void _showProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: user!.uid)
        .get();

    final userData = userSnapshot.docs.isNotEmpty ? userSnapshot.docs.first.data() : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              CircleAvatar(radius: 40, backgroundColor: brandOrange.withOpacity(0.1), child: Icon(Icons.person, size: 50, color: brandOrange)),
              const SizedBox(height: 16),
              Text(userData?['name'] ?? 'Owner', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(userData?['role']?.toString().toUpperCase() ?? 'RESTAURANT OWNER', style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
              const SizedBox(height: 24),
              _profileTile(Icons.email_outlined, "Email", userData?['email'] ?? 'Unknown'),
              _profileTile(Icons.phone_android_outlined, "Mobile", userData?['mobile'] ?? 'N/A'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout Session', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await context.read<myProvider>().signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardUI(String date, bool isDark, {required int total, required int pending, required int delivered, required int restaurants}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello,', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const Text('Your Business Today', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(color: brandOrange, fontWeight: FontWeight.w600)),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatCard('Total Orders', total.toString(), Icons.analytics, [brandOrange, const Color(0xFFFF8A65)]),
              const SizedBox(width: 15),
              _buildStatCard('Active Pending', pending.toString(), Icons.pending_actions, [const Color(0xFF42A5F5), const Color(0xFF2196F3)]),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard('Delivered', delivered.toString(), Icons.verified_rounded, [const Color(0xFF66BB6A), const Color(0xFF43A047)]),
              const SizedBox(width: 15),
              _buildStatCard('Restaurants', restaurants.toString(), Icons.storefront_rounded, [const Color(0xFFAB47BC), const Color(0xFF8E24AA)]),
            ],
          ),
          const SizedBox(height: 35),
          const Text('Recent Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: brandOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brandOrange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.notification_important_rounded, color: brandOrange),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    pending > 0 ? "Action Required: You have $pending orders waiting to be processed." : "Everything looks great! No pending actions.",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: brandOrange, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No Restaurants Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}