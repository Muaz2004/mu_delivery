import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestorantList extends StatefulWidget {
  const RestorantList({super.key});

  @override
  State<RestorantList> createState() => _RestorantListState();
}

class _RestorantListState extends State<RestorantList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Restorant_table').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final restaurants = snapshot.data!.docs;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final data = restaurants[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final address = data['adress'] ?? 'No Address';
            final rating = data['rating'] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(name),
                subtitle: Text('$address\nRating: $rating'),
              ),
            );
          },
        );
      },
    );
  }
}
