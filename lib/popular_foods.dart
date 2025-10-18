import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/foodetail_page.dart';

class PopularFoods extends StatefulWidget {
  const PopularFoods({super.key});

  @override
  State<PopularFoods> createState() => _PoupularFoodsState();
}

class _PoupularFoodsState extends State<PopularFoods> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('menu').limit(6).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final foods = snapshot.data!.docs;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index].data() as Map<String, dynamic>;
            return GestureDetector(
              child: Card(
                color:Color(0xFFFFAB91),
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Food image
                      food['imageurl'] != null && food['imageurl'] != ""
                          ? Image.network(food['imageurl'],
                              height: 100, width: 120, fit: BoxFit.cover)
              
                          : Container(height: 100, width: 120, color: const Color.fromARGB(255, 213, 173, 41)),
                      const SizedBox(height: 8),
                      // Food name
                      Text(food['f_name'] ?? 'No Name', textAlign: TextAlign.center),
                      Text(food['restorant'] ?? 'No restorant name', textAlign: TextAlign.center),
                      // Food price
                      Text('\$${food['price'] ?? 0}'),
                    ],
                  ),
                ),
              ),

              onTap: () {
                   Navigator.push(context,
                   MaterialPageRoute(
                   builder: (context) => FoodetailPage(foodId: foods[index].id),
               ),
  );
},

            );
          },
        );
      },
    );
  }
}
