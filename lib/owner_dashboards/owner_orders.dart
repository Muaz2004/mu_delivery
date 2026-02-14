import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OwnerOrders extends StatelessWidget {
  const OwnerOrders({super.key});

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color brandOrange = Color(0xFFFF7043);
    const Color bgLight = Color(0xFFF8F9FA);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final String ownerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
      
        future: FirebaseFirestore.instance
            .collection('Restorant_table')
            .where('owner_id', isEqualTo: ownerId)
            .get(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brandOrange));
          }

          if (!restaurantSnapshot.hasData || restaurantSnapshot.data!.docs.isEmpty) {
            return _buildEmptyState("You don't have any registered restaurants.");
          }

          
          final ownerRestaurantIds = restaurantSnapshot.data!.docs.map((doc) => doc.id).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('orderTime', descending: true)
                .snapshots(),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandOrange));
              }

              if (!ordersSnapshot.hasData || ordersSnapshot.data!.docs.isEmpty) {
                return _buildEmptyState("No orders found.");
              }

             
              final filteredOrders = ordersSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ownerRestaurantIds.contains(data['restaurantId']);
              }).toList();

              if (filteredOrders.isEmpty) {
                return _buildEmptyState("No orders found for your restaurants.");
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final orderDoc = filteredOrders[index];
                  final order = orderDoc.data() as Map<String, dynamic>;
                  final orderTime = (order['orderTime'] as Timestamp?)?.toDate();
                  final formattedDate = orderTime != null
                      ? DateFormat('MMM dd, hh:mm a').format(orderTime)
                      : 'Unknown date';
                  final items = (order['items'] as List<dynamic>?) ?? [];
                  final userId = order['userId'] as String?;
                  final String currentStatus = order['status'] ?? 'pending';

                  
                  return FutureBuilder<DocumentSnapshot>(
                    future: userId != null
                        ? FirebaseFirestore.instance.collection('users').doc(userId).get()
                        : null,
                    builder: (context, userSnapshot) {
                      String userName = 'Customer';
                      String userMobile = 'N/A';

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        userName = userData['name'] ?? 'Unknown';
                        userMobile = userData['mobile'] ?? 'N/A';
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: brandOrange.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: brandOrange),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(formattedDate,
                                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(currentStatus),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    _infoRow(Icons.phone, "Contact", userMobile),
                                    const SizedBox(height: 12),
                                    const Text("ORDER ITEMS",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brandOrange)),
                                    const SizedBox(height: 8),
                                    ...items.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${item['name']} x${item['quantity']}",
                                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                                              Text("\$${(item['price'] ?? 0) * (item['quantity'] ?? 1)}"),
                                            ],
                                          ),
                                        )),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("\$${order['totalPrice'] ?? 0}",
                                            style: const TextStyle(fontWeight: FontWeight.w900, color: brandOrange, fontSize: 18)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Text("UPDATE STATUS",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    // RE-STYLED DROPDOWN (LOGIC UNTOUCHED)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: currentStatus,
                                          items: ['pending', 'preparing', 'out_for_delivery', 'delivered']
                                              .map((status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Text(status.toUpperCase().replaceAll('_', ' ')),
                                                  ))
                                              .toList(),
                                          onChanged: (value) async {
                                            if (value != null) {
                                              await FirebaseFirestore.instance
                                                  .collection('orders')
                                                  .doc(orderDoc.id)
                                                  .update({'status': value});
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
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

  // --- UI COMPONENTS ---

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'preparing': color = Colors.blue; break;
      case 'out_for_delivery': color = Colors.purple; break;
      case 'delivered': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase().replaceAll('_', ' '),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}