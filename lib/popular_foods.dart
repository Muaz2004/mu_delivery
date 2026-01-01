import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/foodetail_page.dart';

class PopularFoods extends StatelessWidget {
  const PopularFoods({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('menu').limit(6).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.black87));
        }

        final foods = snapshot.data!.docs;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodetailPage(foodId: foods[index].id)),
              ),
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: food['imageurl'] != null && food['imageurl'] != ""
                          ? Image.network(food['imageurl'], height: 110, width: 160, fit: BoxFit.cover)
                          : Container(height: 110, color: Colors.grey[200]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['f_name'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            food['restorant'] ?? 'Restaurant',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${food['price'] ?? 0}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.orangeAccent),
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
    );
  }
}