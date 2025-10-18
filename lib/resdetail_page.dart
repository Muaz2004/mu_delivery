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
          final menuRefs = data['menuRef'] as List<dynamic>?;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant info
                  Card(
                    color: const Color(0xFFFFAB91), // Updated card color
                    child: ListTile(
                      title: Text(name, style: const TextStyle(fontSize: 20)),
                      subtitle: Text('$address\nRating: $rating'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Menu items
                  if (menuRefs != null && menuRefs.isNotEmpty)
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: Future.wait(
                        menuRefs.map((ref) => (ref as DocumentReference).get()),
                      ),
                      builder: (context, menuSnapshot) {
                        if (menuSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!menuSnapshot.hasData ||
                            menuSnapshot.data!.isEmpty) {
                          return const Text('No menu data found');
                        }

                        final menuDocs = menuSnapshot.data!;

                        return Column(
                          children: menuDocs.map((menuDoc) {
                            final menuData =
                                menuDoc.data() as Map<String, dynamic>;
                            final foodName = menuData['f_name'] ?? 'No Name';
                            final price = menuData['price'] ?? 0;
                            final imageUrl = menuData['imageurl'] ?? '';

                            return Card(
                              color: const Color(0xFFFFAB91), // Updated card color
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: imageUrl != ''
                                    ? Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: const Color(0xFFFFF3E0),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: const Color(0xFFFFAB91),
                                      ),
                                title: Text(foodName),
                                subtitle: Text('\$${price.toString()}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodetailPage(
                                        foodId: menuDoc.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  else
                    const Text('No menu available'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
