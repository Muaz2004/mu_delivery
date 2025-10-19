import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/resdetail_page.dart';

class RestorantList extends StatefulWidget {
  const RestorantList({super.key});

  @override
  State<RestorantList> createState() => _RestorantListState();
}

class _RestorantListState extends State<RestorantList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Restorant_table').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No restaurants found.'));
        }

        final restaurants = snapshot.data!.docs;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: restaurants.length,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Three cards per row
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7, // Taller, portrait-style card (similar to menu)
          ),
          itemBuilder: (context, index) {
            final doc = restaurants[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final imageUrl = data['imageurl'] ?? ''; 
            final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
            // final address is now unused here, as requested.

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResdetailPage(
                      restaurantId: doc.id,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 6, // Slightly higher elevation for a prominent look
                shadowColor: Colors.black38,
                color: const Color(0xFFFFCCBC), // Lighter background for the list item
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded edges
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Section
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: const Color(0xFFFFAB91),
                                    child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFFFAB91),
                                    child: const Center(
                                      child: Icon(Icons.restaurant_menu, size: 30, color: Colors.white70), // Placeholder icon
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: const Color(0xFFFFAB91),
                                child: const Center(
                                  child: Icon(Icons.restaurant_menu, size: 30, color: Colors.white70),
                                ),
                              ),
                      ),
                    ),

                    // Text & Rating Section (Location text removed here)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly to distribute remaining space
                          children: [
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900, // Extra bold for name
                                color: Color(0xFF424242), // Dark text for contrast
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            // Rating Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                            
                            // ❌ The Address Text widget has been removed from this section.
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