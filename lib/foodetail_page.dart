import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/mini_screen.dart';
//import 'package:mu_delivery/cart_item.dart';
import 'global_cart.dart'; // Global cart list
import 'cart_item.dart';

class FoodetailPage extends StatefulWidget {
  final String foodId;
  const FoodetailPage({super.key, required this.foodId});

  @override
  State<FoodetailPage> createState() => _FoodetailPageState();
}

class _FoodetailPageState extends State<FoodetailPage> {
  int quantity = 1; // Local quantity for this food item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.foodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final foodData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        foodData['imageurl'] ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        foodData['f_name'] ?? 'No Name',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(foodData['description'] ?? 'No description'),
                      const SizedBox(height: 8),
                      Text('\$${foodData['price'] ?? 0}',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),

                      // Quantity selector
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) quantity--;
                              });
                            },
                            child: const Text('-'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            child: const Text('+'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Subtotal: \$${((foodData['price'] ?? 0) * quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Add to Cart button
                      ElevatedButton(
                        onPressed: () {
                          final String foodName =
                              foodData['f_name'] ?? 'No Name';
                          final double price =
                              (foodData['price'] ?? 0).toDouble();
                          final String foodId = widget.foodId;

                          // Check if this food is already in globalCart
                          final index = globalCart
                              .indexWhere((item) => item.foodId == foodId);

                          if (index >= 0) {
                            setState(() {
                              globalCart[index].quantity += quantity;
                            });
                          } else {
                            setState(() {
                              globalCart.add(
                                CartItem(
                                  foodId: foodId,
                                  name: foodName,
                                  price: price,
                                  quantity: quantity,
                                ),
                              );
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '$foodName added to cart ($quantity)'),
                              duration: const Duration(seconds: 1),
                            ),
                          );

                          setState(() {
                            quantity = 1;
                          });
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Mini Cart at bottom ---
              const MiniScreen()

            ],
          );
        },
      ),
    );
  }
}
