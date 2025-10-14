import 'package:flutter/material.dart';
import 'package:mu_delivery/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MiniScreen extends StatelessWidget {
  final String restaurantId; // Pass this from FoodDetailPage

  const MiniScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.totalItems == 0) return const SizedBox.shrink();

        return Container(
          height: 120,
          color: Colors.grey[200],
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Horizontal list of cart items
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cartProvider.totalItems,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Qty: ${item['quantity']}'),
                            Text(
                                '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Total price + Place Order button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .add(data);

                        cartProvider.clearCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Order submitted!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Failed to submit order: $e")),
                        );
                      }
                    },
                    child: const Text("Place Order"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
