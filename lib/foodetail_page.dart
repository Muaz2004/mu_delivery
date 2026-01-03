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
  int quantity = 1;
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    checkWatchlistStatus();
  }

  Future<void> checkWatchlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final watchlistRef = FirebaseFirestore.instance.collection('watchlist');
    final existing = await watchlistRef
        .where('userId', isEqualTo: user.uid)
        .where('itemId', isEqualTo: widget.foodId)
        .where('type', isEqualTo: "food")
        .get();

    if (mounted) {
      setState(() {
        isInWatchlist = existing.docs.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF7043);

    return Scaffold(
      backgroundColor: Colors.white,
      // Transparent AppBar to show image behind it
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: BackButton(color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWatchlist ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  await addToWatchlist(widget.foodId, "food");
                  setState(() => isInWatchlist = !isInWatchlist);
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('menu').doc(widget.foodId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: brandOrange));
          
          final foodData = snapshot.data!.data() as Map<String, dynamic>;
          final price = (foodData['price'] as num?)?.toDouble() ?? 0.0;
          final restaurantId = (foodData['restaurantId'] as DocumentReference).id;

          return Stack(
            children: [
              Column(
                children: [
                  // 1. RESIZED HERO IMAGE
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                    width: double.infinity,
                    child: Image.network(
                      foodData['imageurl'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // 2. CONTENT SHEET
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      transform: Matrix4.translationValues(0, -30, 0), // Overlap effect
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    foodData['f_name'] ?? 'Food Name',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                ),
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: brandOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              foodData['description'] ?? 'Delicious food prepared with fresh ingredients.',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                            ),
                            const SizedBox(height: 32),
                            
                            // 3. QUANTITY SELECTOR
                            const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildQtyBtn(Icons.remove, () {
                                  if (quantity > 1) setState(() => quantity--);
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('$quantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                _buildQtyBtn(Icons.add, () => setState(() => quantity++)),
                                const Spacer(),
                                Text(
                                  'Total: \$${(price * quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 4. FLOATING BOTTOM BAR (Add to Cart)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => _handleAddToCart(context, foodData, price, restaurantId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: const Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        // Show MiniScreen if cart not empty
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            if (cart.cartItems.isEmpty) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: MiniScreen(restaurantId: restaurantId),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Map<String, dynamic> foodData, double price, String restaurantId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final foodItem = {
      'foodId': widget.foodId,
      'name': foodData['f_name'] ?? 'No Name',
      'price': price,
      'quantity': quantity,
      'restaurantId': restaurantId,
      'imageUrl': foodData['imageurl'] ?? '',
    };

    final index = cartProvider.cartItems.indexWhere((item) => item['foodId'] == widget.foodId);
    if (index >= 0) {
      cartProvider.cartItems[index]['quantity'] += quantity;
      cartProvider.notifyListeners();
    } else {
      cartProvider.addToCart(foodItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $quantity x ${foodData['f_name']}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    setState(() => quantity = 1);
  }
}

// Keep the logic-only addToWatchlist exactly as you had it
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