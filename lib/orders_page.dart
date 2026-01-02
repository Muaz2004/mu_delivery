import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF2D2D2D);
    const Color accentColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: textPrimary, 
            fontWeight: FontWeight.w900, 
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('orderTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          final orders = snapshot.data!.docs
              .where((doc) => doc['userId'] == currentUserId)
              .toList();

          if (orders.isEmpty) {
            return const Center(child: Text("No orders found for you."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderTime = (order['orderTime'] as Timestamp?)?.toDate();
              final formattedDate = orderTime != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(orderTime)
                  : 'Unknown date';
              final items = (order['items'] as List<dynamic>?) ?? [];
              final status = order['status'] ?? 'Pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    // THIS SECTION MAKES THE INITIAL CARD TALLER
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25), 
                    title: Text(
                      "Order #${orders[index].id.substring(0, 5).toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: textPrimary
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    trailing: _buildStatusChip(status),
                    
                    // THIS SECTION IS THE EXPANDED PART (KEEPS IT COMPACT)
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            ...items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${item['name']} x${item['quantity']}",
                                        style: const TextStyle(color: textPrimary, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                                ),
                                Text(
                                  "\$${order['totalPrice'] ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900, 
                                    fontSize: 18, 
                                    color: accentColor
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'delivered': chipColor = Colors.green; break;
      case 'on the way': chipColor = Colors.blue; break;
      default: chipColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}