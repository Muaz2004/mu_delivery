import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_delivery/globals.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);
    
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final Color subBoxColor = isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
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
            return const Center(child: CircularProgressIndicator(color: brandOrange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState("No orders found.", isDark);
          }

          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          final orders = snapshot.data!.docs
              .where((doc) => doc['userId'] == currentUserId)
              .toList();

          if (orders.isEmpty) {
            return _buildEmptyState("No orders found for you.", isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              final orderTime = (order['orderTime'] as Timestamp?)?.toDate();
              final formattedDate = orderTime != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(orderTime)
                  : 'Unknown date';
              final items = (order['items'] as List<dynamic>?) ?? [];
              final status = order['status'] ?? 'Pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 18), // Slightly more margin
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    unselectedWidgetColor: Colors.grey[500], 
                  ),
                  child: ExpansionTile(
                    // --- INCREASED TILE HEIGHT VIA VERTICAL PADDING ---
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
                    leading: Container(
                      padding: const EdgeInsets.all(12), // Increased from 10
                      decoration: BoxDecoration(
                        color: brandOrange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: brandOrange, size: 24), // Increased from 20
                    ),
                    title: Text(
                      "Order #${orderDoc.id.substring(0, 5).toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900, // Made even bolder
                        fontSize: 17, // Increased from 16
                        color: textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12, // Increased from 11
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    trailing: _buildStatusChip(status),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: isDark ? Colors.white10 : Colors.grey[100], thickness: 1),
                            const SizedBox(height: 8),
                            ...items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(color: brandOrange, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${item['name']}",
                                        style: TextStyle(
                                          color: textPrimary, 
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 14
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "x${item['quantity']}",
                                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: subBoxColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Paid",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                                  ),
                                  Text(
                                    "\$${order['totalPrice'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
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
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'delivered':
        chipColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'on the way':
        chipColor = const Color(0xFF2196F3);
        statusIcon = Icons.local_shipping_rounded;
        break;
      default:
        chipColor = const Color(0xFFFF9800);
        statusIcon = Icons.access_time_filled_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: chipColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: isDark ? Colors.grey[800] : Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}