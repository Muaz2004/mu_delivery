import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  Future<void> removeFromWatchlist(String docId) async {
    await FirebaseFirestore.instance.collection('watchlist').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF7043),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('watchlist')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in your watchlist.'));
          }

          // Filter **locally** for the current user
          final allItems = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['userId'] == userId;
          }).toList();

          if (allItems.isEmpty) {
            return const Center(child: Text('No items in your watchlist.'));
          }

          return ListView.builder(
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final doc = allItems[index];
              final data = doc.data() as Map<String, dynamic>;
              final itemId = data['itemId'] ?? 'Unknown';
              final type = data['type'] ?? 'unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    type == 'food' ? Icons.fastfood : Icons.store,
                    color: type == 'food' ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    type == 'food' ? 'Food Item: $itemId' : 'Restaurant: $itemId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Type: $type'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await removeFromWatchlist(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            type == 'food'
                                ? 'Food removed from watchlist'
                                : 'Restaurant removed from watchlist',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Remove', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
