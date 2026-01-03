import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/resdetail_page.dart';

class RestorantList extends StatelessWidget {
  const RestorantList({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF7043);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Restorant_table').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: brandOrange));
        }

        final restaurants = snapshot.data?.docs ?? [];

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: restaurants.length,
          padding: const EdgeInsets.symmetric(vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 25, 
            crossAxisSpacing: 18,
            childAspectRatio: 0.82, // Slightly adjusted for better balance
          ),
          itemBuilder: (context, index) {
            final doc = restaurants[index];
            final data = doc.data() as Map<String, dynamic>;
            final imageUrl = data['imageurl'] ?? '';

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResdetailPage(restaurantId: doc.id)),
              ),
              child: Container(
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
                    // TOP IMAGE SECTION
                    Expanded(
                      flex: 4,
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl), 
                                      fit: BoxFit.cover
                                    )
                                  : null,
                              color: Colors.grey[100],
                            ),
                          ),
                          // FIXED RATING BADGE: Using ClipRRect + BackdropFilter
                          Positioned(
                            top: 15,
                            right: 15,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  color: Colors.black.withOpacity(0.4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${(data['rating'] ?? 0).toDouble()}",
                                        style: const TextStyle(
                                          fontSize: 11, 
                                          fontWeight: FontWeight.w900, 
                                          color: Colors.white
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // CONTENT SECTION
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              data['name'] ?? 'Restaurant',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16,
                                color: Color(0xFF2D2D2D),
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time_filled_rounded, size: 14, color: brandOrange.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                const Text(
                                  "25 min",
                                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                // Arrow icon to indicate it's clickable
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
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