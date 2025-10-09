import 'package:flutter/material.dart';
import 'package:mu_delivery/popular_foods.dart';
import 'package:mu_delivery/restorant_list.dart';

class ResfoodPage extends StatefulWidget {
  const ResfoodPage({super.key});

  @override
  State<ResfoodPage> createState() => _HomePageState();
}

class _HomePageState extends State<ResfoodPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Popular Foods",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200, // give space for image + text
              child: PopularFoods(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Restaurants",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RestorantList(),
          ],
        ),
      ),

    );
  }
}
