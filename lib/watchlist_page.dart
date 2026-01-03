import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final watchlistSnap = await FirebaseFirestore.instance.collection('watchlist').get();
    final menuSnap = await FirebaseFirestore.instance.collection('menu').get();
    final restSnap = await FirebaseFirestore.instance.collection('Restorant_table').get();

    final menu = {for (var d in menuSnap.docs) d.id: d.data()};
    final rests = {for (var d in restSnap.docs) d.id: d.data()};

    final userItems = watchlistSnap.docs.where((doc) {
      final data = doc.data();
      return data['userId'] == user.uid;
    });

    List<Map<String, dynamic>> temp = [];
    for (var doc in userItems) {
      final data = doc.data();
      final type = data['type'];
      final id = data['itemId'];
      Map<String, dynamic>? item;

      if (type == 'food') {
        item = menu[id];
      } else if (type == 'restorant') {
        item = rests[id];
      }

      if (item != null) {
        temp.add({
          'id': doc.id,
          'type': type,
          'item': item,
        });
      }
    }

    setState(() {
      _items = temp;
      _loading = false;
    });
  }

  Future<void> _removeItem(String id) async {
    // Optimistic UI update: Remove from list immediately for speed
    setState(() {
      _items.removeWhere((element) => element['id'] == id);
    });
    await FirebaseFirestore.instance.collection('watchlist').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF7043);
    const Color textPrimary = Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w900, 
            fontSize: 22,
            letterSpacing: -0.5
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: brandOrange))
          : _items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final entry = _items[index];
                    final type = entry['type'];
                    final item = entry['item'];
                    final name = type == 'food' ? item['f_name'] : item['name'];
                    final image = type == 'food' ? item['imageurl'] : item['logourl'];
                    final price = type == 'food' ? item['price']?.toString() : null;
                    final address = type == 'restorant' ? item['adress'] : null;

                    return Container(
                      height: 130, // Fixed height for a consistent "Tall" feel
                      margin: const EdgeInsets.only(bottom: 18),
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
                      child: Row(
                        children: [
                          // 1. FLOATING IMAGE SECTION
                          Container(
                            width: 110,
                            margin: const EdgeInsets.all(10), // The "Floating" margin
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[100],
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

                          // 2. TEXT CONTENT
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Category Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: brandOrange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: brandOrange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name ?? 'Unknown',
                                    style: const TextStyle(
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
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: brandOrange,
                                      ),
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
                                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // 3. ACTIONS (DELETE)
                          IconButton(
                            onPressed: () => _removeItem(entry['id']),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}