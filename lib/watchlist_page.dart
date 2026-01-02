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
    await FirebaseFirestore.instance.collection('watchlist').doc(id).delete();
    _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFF7043);
    const Color textPrimary = Color(0xFF2D2D2D);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: brandOrange)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: brandOrange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No items in your watchlist'))
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
                  // MADE THE CARDS TALLER VIA MARGIN AND PADDING
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: IntrinsicHeight( // Ensures the card stretches to fit content beautifully
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // LARGE IMAGE SECTION
                          SizedBox(
                            width: 120, // Increased width for a "Taller" feel
                            child: image != null && image.isNotEmpty
                                ? Image.network(image, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                          ),
                          // CONTENT SECTION
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0), // Extra padding for height
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  if (type == 'food' && price != null)
                                    Text(
                                      "\$$price",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: brandOrange,
                                      ),
                                    ),
                                  if (type == 'restorant' && address != null)
                                    Text(
                                      address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  const SizedBox(height: 10),
                                  // SMALL PILL FOR TYPE
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ACTIONS SECTION
                          IconButton(
                            padding: const EdgeInsets.only(right: 12),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _removeItem(entry['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}