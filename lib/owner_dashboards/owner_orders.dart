import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerOrders extends StatelessWidget {
  const OwnerOrders({super.key});

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFFFF7043); // AppBar orange
    const cardColor = Color(0xFFFFAB91); // Slightly lighter matching warm color
    final String ownerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // soft warm background
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        // Step 1: Get all restaurants that belong to this owner
        future: FirebaseFirestore.instance
            .collection('Restorant_table')
            .where('owner_id', isEqualTo: ownerId)
            .get(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appBarColor));
          }

          if (!restaurantSnapshot.hasData || restaurantSnapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              "You don't have any registered restaurants.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ));
          }

          // Step 2: Extract restaurant IDs
          final restaurantIds = restaurantSnapshot.data!.docs.map((doc) => doc.id).toList();

          // Step 3: Query orders that belong to these restaurant IDs
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('restaurantId', whereIn: restaurantIds)
                .orderBy('orderTime', descending: true)
                .snapshots(),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: appBarColor));
              }

              if (!ordersSnapshot.hasData || ordersSnapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text(
                  "No orders found for your restaurants.",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ));
              }

              final orders = ordersSnapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final orderTime = (order['orderTime'] as Timestamp?)?.toDate();
                  final formattedDate = orderTime != null
                      ? DateFormat('MMM dd, yyyy – hh:mm a').format(orderTime)
                      : 'Unknown date';
                  final items = (order['items'] as List<dynamic>?) ?? [];
                  final userId = order['userId'] as String?;

                  return FutureBuilder<DocumentSnapshot>(
                    // Fetch user info for each order
                    future: userId != null
                        ? FirebaseFirestore.instance.collection('users').doc(userId).get()
                        : null,
                    builder: (context, userSnapshot) {
                      String userName = 'Unknown';
                      String userMobile = 'N/A';

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        userName = userData['name'] ?? 'Unknown';
                        userMobile = userData['mobile'] ?? 'N/A';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer: $userName",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87),
                              ),
                              Text(
                                "Phone: $userMobile",
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Items Ordered:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                    child: Text("- ${item['name']} x${item['quantity']}",
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.black87)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total: \$${order['totalPrice'] ?? 0}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: appBarColor, borderRadius: BorderRadius.circular(12)),
                                    child: Text(order['status'] ?? 'Pending',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("Ordered on: $formattedDate",
                                  style: const TextStyle(color: Colors.black87, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
