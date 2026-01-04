import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/foodetail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResdetailPage extends StatefulWidget {
  final String restaurantId;
  const ResdetailPage({super.key, required this.restaurantId});

  @override
  State<ResdetailPage> createState() => _ResdetailPageState();
}

class _ResdetailPageState extends State<ResdetailPage> {
  double? userRating;
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    checkWatchlistStatus();
  }

  Future<void> _rateRestaurant(double rating) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final ratingRef = FirebaseFirestore.instance
        .collection('Restorant_table')
        .doc(widget.restaurantId)
        .collection('ratings')
        .doc(userId);

    await ratingRef.set({'rating': rating});

    final allRatings = await FirebaseFirestore.instance
        .collection('Restorant_table')
        .doc(widget.restaurantId)
        .collection('ratings')
        .get();

    if (allRatings.docs.isNotEmpty) {
      double total = 0;
      for (var doc in allRatings.docs) {
        total += (doc['rating'] as num).toDouble();
      }
      double avg = total / allRatings.docs.length;

      await FirebaseFirestore.instance
          .collection('Restorant_table')
          .doc(widget.restaurantId)
          .update({'rating': avg});
    }

    setState(() => userRating = rating);
  }

  Future<void> checkWatchlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final watchlistRef = FirebaseFirestore.instance.collection('watchlist');

    final existing = await watchlistRef
        .where('userId', isEqualTo: user.uid)
        .where('itemId', isEqualTo: widget.restaurantId)
        .where('type', isEqualTo: "restorant")
        .get();

  if (mounted) {
      setState(() => isInWatchlist = existing.docs.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);
    
    final Color sheetColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final Color textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color cardBg = isDark ? Colors.grey[900]! : Colors.white;
    final Color iconBtnBg = isDark ? Colors.grey[850]! : Colors.white.withOpacity(0.9);

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
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Restorant_table')
            .doc(widget.restaurantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: brandOrange));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No Name';
          final address = data['adress'] ?? 'No Address';
          final rating = (data['rating'] ?? 0).toDouble();
          final imageUrl = data['imageurl'] ?? '';
          final menuRefs = data['menuRef'] as List<dynamic>?;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Restaurant Image
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty 
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(color: brandOrange, child: const Icon(Icons.restaurant, size: 50, color: Colors.white)),
                ),
                
                // Content Sheet
                Container(
                  width: double.infinity,
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: BoxDecoration(
                    color: sheetColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Name + Heart Button (No Background)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name, 
                                style: TextStyle(
                                  fontSize: 28, 
                                  fontWeight: FontWeight.w900, 
                                  color: textPrimary
                                )
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await addToWatchlist(widget.restaurantId, "restorant");
                                setState(() => isInWatchlist = !isInWatchlist);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isInWatchlist ? 'Added to favorites' : 'Removed from favorites',
                                      style: TextStyle(color: isDark ? Colors.black : Colors.white),
                                    ),
                                    backgroundColor: isDark ? Colors.white : const Color(0xFF2D2D2D),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                isInWatchlist ? Icons.favorite : Icons.favorite_border,
                                color: isInWatchlist ? Colors.red : (isDark ? Colors.white54 : Colors.grey),
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: brandOrange, size: 18),
                            const SizedBox(width: 4),
                            Expanded(child: Text(address, style: TextStyle(color: textSecondary, fontSize: 16))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Rating Interface Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rate your experience", style: TextStyle(color: textSecondary, fontSize: 12)),
                                  Row(
                                    children: List.generate(5, (index) {
                                      double starValue = index + 1;
                                      return GestureDetector(
                                        onTap: () => _rateRestaurant(starValue),
                                        child: Icon(
                                          Icons.star,
                                          size: 28,
                                          color: (userRating ?? rating) >= starValue ? Colors.amber : Colors.grey[300],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
                                  const Text("Avg Rating", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text('Menu Highlights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary)),
                        const SizedBox(height: 16),

                        // Menu Grid with Fallback Icons
                        if (menuRefs != null && menuRefs.isNotEmpty)
                          _buildMenuGrid(menuRefs, isDark, textPrimary, brandOrange)
                        else
                          const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No menu items available yet."),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid(List<dynamic> menuRefs, bool isDark, Color textPrimary, Color brandOrange) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait(menuRefs.map((ref) => (ref as DocumentReference).get())),
      builder: (context, menuSnapshot) {
        if (!menuSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final menuDocs = menuSnapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuDocs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final menuData = menuDocs[index].data() as Map<String, dynamic>;
            final String imgUrl = menuData['imageurl'] ?? '';

            return GestureDetector(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => FoodetailPage(foodId: menuDocs[index].id))
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: imgUrl.isNotEmpty 
                          ? Image.network(imgUrl, fit: BoxFit.cover)
                          : Center(child: Icon(Icons.fastfood_outlined, color: isDark ? Colors.white24 : Colors.grey[400], size: 30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menuData['f_name'] ?? '', 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)
                  ),
                  Text(
                    '\$${menuData['price']}', 
                    style: TextStyle(color: brandOrange, fontWeight: FontWeight.w800, fontSize: 14)
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Global function for watchlist logic
Future<void> addToWatchlist(String itemId, String type) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final userId = user.uid;
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