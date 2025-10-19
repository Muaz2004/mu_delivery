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
      appBar: AppBar(
        title: const Text('Food Details', style: TextStyle(color: Colors.white)), // White title for contrast
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.foodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7043))); // Themed loader
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Food item not found.'));
          }

          final foodData = snapshot.data!.data() as Map<String, dynamic>;
          // Safely cast price to double for calculations
          final price = (foodData['price'] as num?)?.toDouble() ?? 0.0;
          final restaurantId = (foodData['restaurantId'] as DocumentReference).id;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with rounded corners and error handler
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          foodData['imageurl'] ?? '',
                          height: 120, // 💡 Reduced image height to 120
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120, // Match new height
                              color: const Color(0xFFFFCCBC),
                              child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF7043))),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120, // Match new height
                              color: const Color(0xFFFFCCBC),
                              child: const Center(child: Icon(Icons.fastfood, size: 40, color: Color(0xFFE64A19))),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Food Name
                      Text(foodData['f_name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242))), // Dark text
                      const SizedBox(height: 8),

                      // Description
                      Text(foodData['description'] ?? 'No description',
                          style: const TextStyle(fontSize: 16, color: Color(0xFF6D4C41))), // Sub-text color
                      const SizedBox(height: 8),

                      // Price
                      Text('\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE64A19))), // Highlight price color
                      const SizedBox(height: 16),

                      // Quantity row
                      Row(
                        children: [
                          // Decrement Button
                          ElevatedButton(
                            onPressed: () {
                              if (quantity > 1) setState(() => quantity--);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCCBC), // Lighter background
                              foregroundColor: const Color(0xFFE64A19), // Darker text
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(40, 40), // Standard size for button
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$quantity',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                          ),

                          // Increment Button
                          ElevatedButton(
                            onPressed: () => setState(() => quantity++),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCCBC), // Lighter background
                              foregroundColor: const Color(0xFFE64A19), // Darker text
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(40, 40), // Standard size for button
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subtotal
                      Text(
                          'Subtotal: \$${(price * quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE64A19))), // Highlight subtotal
                      const SizedBox(height: 16),

                      // Add to cart button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final cartProvider = 
                                Provider.of<CartProvider>(context, listen: false);

                            // Create food map
                            final foodItem = {
                              'foodId': widget.foodId,
                              'name': foodData['f_name'] ?? 'No Name',
                              'price': price,
                              'quantity': quantity,
                              'restaurantId': restaurantId,
                              'imageUrl': foodData['imageurl'] ?? '',
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
                                        '${foodData['f_name']} added (x$quantity)'),
                                    backgroundColor: const Color(0xFFFF7043), // Themed Snackbar
                                ));

                            setState(() => quantity = 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043), // Primary button color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mini cart at bottom
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