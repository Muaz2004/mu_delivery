import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/foodetail_page.dart';

class ResdetailPage extends StatelessWidget {
  final String restaurantId;

  const ResdetailPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        backgroundColor: const Color(0xFFFF7043),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Restorant_table')
            .doc(restaurantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No Name';
          final address = data['adress'] ?? 'No Address';
          final rating = data['rating'] ?? 0;
          final imageUrl = data['imageurl'] ?? '';
          final menuRefs = data['menuRef'] as List<dynamic>?;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant header card
                  Card(
                    color: const Color(0xFFFFAB91),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(16)),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: const Color(0xFFFFAB91),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 180,
                                  color: const Color(0xFFFFAB91),
                                  child: const Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 14, 13, 13),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Color.fromARGB(255, 218, 3, 3)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: const TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 20, color:Color.fromARGB(255, 255, 255, 0)),
                                  const SizedBox(width: 6),
                                  Text(
                                    rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 6, 6, 6),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu items as a grid - 3 per row
                  if (menuRefs != null && menuRefs.isNotEmpty)
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: Future.wait(
                        menuRefs.map((ref) => (ref as DocumentReference).get()),
                      ),
                      builder: (context, menuSnapshot) {
                        if (menuSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!menuSnapshot.hasData || menuSnapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No menu items available',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        final menuDocs = menuSnapshot.data!;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: menuDocs.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Changed to 3 per row
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.7, // Adjusted for better proportions
                          ),
                          itemBuilder: (context, index) {
                            final menuData =
                                menuDocs[index].data() as Map<String, dynamic>;
                            final foodName = menuData['f_name'] ?? 'No Name';
                            final price = menuData['price'] ?? 0;
                            final imageUrl = menuData['imageurl'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FoodetailPage(foodId: menuDocs[index].id),
                                  ),
                                );
                              },
                              child: Card(
                                color: const Color(0xFFFFAB91),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Food image with placeholder
                                    Container(
                                      height: 90, // Adjusted height for 3-column layout
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFCCBC),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: const Color(0xFFFFCCBC),
                                                    child: const Icon(
                                                      Icons.fastfood,
                                                      size: 40,
                                                      color: Color(0xFF5D4037),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: const Color(0xFFFFCCBC),
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 40,
                                                  color: Color(0xFF5D4037),
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Food details
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            foodName,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color.fromARGB(255, 8, 8, 8),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '\$${price.toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color.fromARGB(255, 12, 12, 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No menu available',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}