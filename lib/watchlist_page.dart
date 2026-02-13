import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/globals.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "Please login to view your watchlist",
            style: TextStyle(color: textPrimary),
          ),
        ),
      );
    }

    // --- STREAM OF WATCHLIST ---
    final watchlistStream = FirebaseFirestore.instance
        .collection('watchlist')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: watchlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: brandOrange),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 80, color: isDark ? Colors.white10 : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final watchlistDocs = snapshot.data!.docs;

          // --- LIVE FETCH OF MENU & RESTAURANT DATA ---
          return StreamBuilder<List<QuerySnapshot>>(
            stream: Stream.fromFuture(
              Future.wait([
                FirebaseFirestore.instance.collection('menu').get(),
                FirebaseFirestore.instance.collection('Restorant_table').get(),
              ]),
            ),
            builder: (context, futureSnapshot) {
              if (!futureSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: brandOrange),
                );
              }

              final menuSnap = futureSnapshot.data![0];
              final restSnap = futureSnapshot.data![1];

              // CAST doc.data() to Map<String, dynamic>
              final menu = {
                for (var d in menuSnap.docs) d.id: d.data() as Map<String, dynamic>
              };
              final rests = {
                for (var d in restSnap.docs) d.id: d.data() as Map<String, dynamic>
              };

              // MAP WATCHLIST DOCS TO ITEMS
              final items = watchlistDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final type = data['type'];
                final id = data['itemId'];
                Map<String, dynamic>? item;
                if (type == 'food') item = menu[id];
                else if (type == 'restorant') item = rests[id];
                if (item != null) {
                  return {'id': doc.id, 'type': type, 'item': item};
                }
                return null;
              }).where((e) => e != null).toList();

              if (items.isEmpty) {
                return Center(
                  child: Text("No items available", style: TextStyle(color: textPrimary)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final entry = items[index]!;
                  final type = entry['type'];
                  final item = entry['item'];
                  final name = type == 'food' ? item['f_name'] : item['name'];
                  final image = type == 'food' ? item['imageurl'] : item['logourl'];
                  final price = type == 'food' ? item['price']?.toString() : null;
                  final address = type == 'restorant' ? item['adress'] : null;

                  return Container(
                    height: 130,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // IMAGE
                        Container(
                          width: 110,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark ? Colors.black26 : Colors.grey[100],
                            image: image != null && image.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(image),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: image == null || image.isEmpty
                              ? const Icon(Icons.image_not_supported, color: Colors.grey)
                              : null,
                        ),

                        // TEXT CONTENT
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // CATEGORY TAG
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: brandOrange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.w900, color: brandOrange),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (type == 'food' && price != null)
                                  Text(
                                    "\$$price",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800, fontSize: 15, color: brandOrange),
                                  ),
                                if (type == 'restorant' && address != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // DELETE BUTTON
                        IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('watchlist')
                                .doc(entry['id'])
                                .delete();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
