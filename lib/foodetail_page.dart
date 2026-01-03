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
      setState(() => isInWatchlist = existing.docs.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. THEME DETECTION
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);

    // 2. DYNAMIC COLORS
    final Color sheetColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final Color textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color iconBtnBg = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: sheetColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: iconBtnBg,
            child: BackButton(color: isDark ? Colors.white : Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: iconBtnBg,
              child: IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWatchlist
                      ? Colors.red
                      : (isDark ? Colors.white54 : Colors.grey),
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
        stream: FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.foodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: brandOrange));
          }

          final foodData = snapshot.data!.data() as Map<String, dynamic>;
          final price = (foodData['price'] as num?)?.toDouble() ?? 0.0;
          final restaurantId =
              (foodData['restaurantId'] as DocumentReference).id;

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    child: Image.network(
                      foodData['imageurl'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // CONTENT SHEET
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      transform: Matrix4.translationValues(0, -30, 0),
                      decoration: BoxDecoration(
                        color: sheetColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32)),
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
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: brandOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              foodData['description'] ??
                                  'Delicious food prepared with fresh ingredients.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: textSecondary,
                                  height: 1.5),
                            ),
                            const SizedBox(height: 32),
                            // QUANTITY SELECTOR
                            Text("Quantity",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: textPrimary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildQtyBtn(Icons.remove, isDark, () {
                                  if (quantity > 1) setState(() => quantity--);
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text('$quantity',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary)),
                                ),
                                _buildQtyBtn(Icons.add, isDark,
                                    () => setState(() => quantity++)),
                                const Spacer(),
                                Text(
                                  'Total: \$${(price * quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary),
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
              // FLOATING BOTTOM BAR
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: sheetColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black45
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
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
                            onPressed: () => _handleAddToCart(
                                context, foodData, price, restaurantId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: const Text('Add to Cart',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
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

  Widget _buildQtyBtn(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Map<String, dynamic> foodData,
      double price, String restaurantId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final foodItem = {
      'foodId': widget.foodId,
      'name': foodData['f_name'] ?? 'No Name',
      'price': price,
      'quantity': quantity,
      'restaurantId': restaurantId,
      'imageUrl': foodData['imageurl'] ?? '',
    };

    final index = cartProvider.cartItems
        .indexWhere((item) => item['foodId'] == widget.foodId);
    if (index >= 0) {
      cartProvider.cartItems[index]['quantity'] += quantity;
      cartProvider.notifyListeners();
    } else {
      cartProvider.addToCart(foodItem);
    }

    // FIX: Dynamic SnackBar colors for Dark Mode visibility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $quantity x ${foodData['f_name']}',
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Colors.white : const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() => quantity = 1);
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