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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No items in your watchlist',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Container(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final entry = _items[index];
                  final type = entry['type'];
                  final item = entry['item'];
                  final name = type == 'food' ? item['f_name'] : item['name'];
                  final image = type == 'food' ? item['imageurl'] : item['logourl'];
                  final price = type == 'food' ? item['price']?.toString() : null;
                  final address = type == 'restorant' ? item['adress'] : null;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image != null && image.isNotEmpty
                            ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover)
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                      ),
                      title: Text(
                        name ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          if (type == 'food' && price != null)
                            Text("💲 Price: $price",
                                style: TextStyle(color: Colors.grey.shade700)),
                          if (type == 'restorant' && address != null)
                            Text("📍 Address: $address",
                                style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 3),
                          Text("Type: ${type.toUpperCase()}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeItem(entry['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
