import 'dart:ui'; // Required for Glassmorphism
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/foodetail_page.dart';

class PopularFoods extends StatelessWidget {
  const PopularFoods({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF7043);

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('menu').limit(6).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: brandOrange));
        }

        final foods = snapshot.data!.docs;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final foodDoc = foods[index];
            final food = foodDoc.data() as Map<String, dynamic>;
            final imageUrl = food['imageurl'] ?? '';

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodetailPage(foodId: foodDoc.id)),
              ),
              child: Container(
                width: 170, // Slightly wider for better text fit
                margin: const EdgeInsets.only(right: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. FLOATING IMAGE SECTION
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8), // Inner margin for "floating" effect
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              image: imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl), 
                                      fit: BoxFit.cover
                                    )
                                  : null,
                              color: Colors.grey[100],
                            ),
                          ),
                          // Glassmorphic Price Tag
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  color: Colors.black.withOpacity(0.3),
                                  child: Text(
                                    '\$${food['price'] ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 2. TEXT CONTENT SECTION
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              food['f_name'] ?? 'No Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 15,
                                color: Color(0xFF2D2D2D),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.storefront_rounded, size: 13, color: brandOrange.withOpacity(0.6)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    food['restorant'] ?? 'Restaurant',
                                    style: TextStyle(
                                      color: Colors.grey[500], 
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}