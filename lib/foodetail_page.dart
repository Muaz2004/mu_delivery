import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mu_delivery/providers/cart_provider.dart';
import 'package:mu_delivery/mini_screen.dart';

class FoodetailPage extends StatefulWidget {
  final String foodId;
  const FoodetailPage({super.key, required this.foodId});

  @override
  State<FoodetailPage> createState() => _FoodetailPageState();
}

class _FoodetailPageState extends State<FoodetailPage> {
  int quantity = 1; // Local quantity

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
          final restaurantId = (foodData['restaurantId'] as DocumentReference).id;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
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
                      Text(foodData['f_name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(foodData['description'] ?? 'No description'),
                      const SizedBox(height: 8),
                      Text('\$${foodData['price'] ?? 0}',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),

                      // Quantity row
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              child: const Text('-')),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$quantity',
                                style: const TextStyle(fontSize: 18)),
                          ),
                          ElevatedButton(
                              onPressed: () => setState(() => quantity++),
                              child: const Text('+')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                          'Subtotal: \$${((foodData['price'] ?? 0) * quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Add to cart button
                      ElevatedButton(
                        onPressed: () {
                          final cartProvider = 
                              Provider.of<CartProvider>(context, listen: false);

                          // Create food map
                          final foodItem = {
                            'foodId': widget.foodId,
                            'name': foodData['f_name'] ?? 'No Name',
                            'price': (foodData['price'] ?? 0).toDouble(),
                            'quantity': quantity,
                            'restaurantId': restaurantId,
                          };

                          // Check if food exists in cart
                          final index = cartProvider.cartItems.indexWhere(
                              (item) => item['foodId'] == widget.foodId);

                          if (index >= 0) {
                            cartProvider.cartItems[index]['quantity'] += quantity;
                            cartProvider.notifyListeners();
                          } else {
                            cartProvider.addToCart(foodItem);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${foodData['f_name']} added ($quantity)')));

                          setState(() => quantity = 1);
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ),

              // Mini cart at bottom  doesnt need to use consumer her since i used it in my miniscreen page
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.cartItems.isEmpty) return const SizedBox();
                  return MiniScreen(restaurantId: restaurantId);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
