import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mu_delivery/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MiniScreen extends StatelessWidget {
  final String restaurantId;

  const MiniScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          // We removed the calculated 'height' property to let it fit content
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withOpacity(0.7) 
                : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Crucial: Shrinks column to fit content
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined, 
                          size: 16, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 8),
                        Text("Cart Preview", 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87
                          )),
                        const Spacer(),
                        Text("${cartProvider.cartItems.length} items", 
                          style: const TextStyle(color: brandOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const Divider(height: 24),

                    // --- HORIZONTAL LIST ---
                    // We wrap the ListView in a SizedBox to prevent vertical overflow
                    SizedBox(
                      height: 100, 
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cartItems[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(top: 5, right: 5),
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87)),
                                        Text('Qty: ${item['quantity']}', 
                                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                                        Text(
                                            '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 12, color: brandOrange, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => cartProvider.removeItem(index),
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.red.withOpacity(0.9),
                                      child: const Icon(Icons.close, size: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- FOOTER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Price', 
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)),
                            Text(
                              '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w900, 
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final data = {
                              "items": cartProvider.cartItems,
                              "totalPrice": cartProvider.totalPrice,
                              "restaurantId": restaurantId,
                              "status": "pending",
                              "orderTime": Timestamp.now(),
                              "userId": FirebaseAuth.instance.currentUser!.uid,
                            };

                            try {
                              await FirebaseFirestore.instance.collection('orders').add(data);
                              cartProvider.clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order submitted!"),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to submit order: $e")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text("Place Order", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}