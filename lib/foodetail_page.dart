import 'package:firebase_auth/firebase_auth.dart';
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
  bool isInWatchlist = false; // New state for watchlist button

  @override
  void initState() {
    super.initState();
    checkWatchlistStatus();
  }

  Future<void> checkWatchlistStatus() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final watchlistRef = FirebaseFirestore.instance.collection('watchlist');

    final existing = await watchlistRef
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: widget.foodId)
        .where('type', isEqualTo: "food")
        .get();

    setState(() {
      isInWatchlist = existing.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.foodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7043)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Food item not found.'));
          }

          final foodData = snapshot.data!.data() as Map<String, dynamic>;
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          foodData['imageurl'] ?? '',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              color: const Color(0xFFFFCCBC),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFFF7043))),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: const Color(0xFFFFCCBC),
                              child: const Center(
                                  child: Icon(Icons.fastfood,
                                      size: 40, color: Color(0xFFE64A19))),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(foodData['f_name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242))),
                      const SizedBox(height: 8),
                      Text(foodData['description'] ?? 'No description',
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF6D4C41))),
                      const SizedBox(height: 8),
                      Text('\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE64A19))),

                      // Watchlist button
                      ElevatedButton(
                        onPressed: () async {
                          await addToWatchlist(widget.foodId, "food");

                          setState(() {
                            isInWatchlist = !isInWatchlist;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInWatchlist
                                    ? 'Added to your watchlist'
                                    : 'Removed from your watchlist',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                        backgroundColor: isInWatchlist ? Colors.red : Colors.green, // red for remove, green for add
                      ),
                        child: Text(isInWatchlist
                            ? "Remove from Watchlist"
                            : "Add to Watchlist"),
                      ),

                      const SizedBox(height: 16),

                      // Quantity row
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (quantity > 1) setState(() => quantity--);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCCBC),
                              foregroundColor: const Color(0xFFE64A19),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('-',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$quantity',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424242))),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => quantity++),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCCBC),
                              foregroundColor: const Color(0xFFE64A19),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('+',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subtotal
                      Text('Subtotal: \$${(price * quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE64A19))),
                      const SizedBox(height: 16),

                      // Add to cart button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final cartProvider =
                                Provider.of<CartProvider>(context, listen: false);

                            final foodItem = {
                              'foodId': widget.foodId,
                              'name': foodData['f_name'] ?? 'No Name',
                              'price': price,
                              'quantity': quantity,
                              'restaurantId': restaurantId,
                              'imageUrl': foodData['imageurl'] ?? '',
                            };

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
                                backgroundColor: const Color(0xFFFF7043),
                              ),
                            );

                            setState(() => quantity = 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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

Future<void> addToWatchlist(String itemId, String type) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final watchlistRef = FirebaseFirestore.instance.collection('watchlist');

  final existing = await watchlistRef
      .where('userId', isEqualTo: userId)
      .where('itemId', isEqualTo: itemId)
      .where('type', isEqualTo: type)
      .get();

  if (existing.docs.isEmpty) {
    await watchlistRef.add({
      'userId': userId,
      'itemId': itemId,
      'type': type,
      'addedAt': FieldValue.serverTimestamp(),
    });
  } else {
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }
  }
}
