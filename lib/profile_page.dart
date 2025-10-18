import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/signin_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFFFFF3E0),
      appBar: AppBar(title: const Text('Profile Page'),
      backgroundColor:  const Color(0xFFFFF3E0),),
      body: Column(
        children: [
          // --- Main page content ---
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<myProvider>().signOut(); // Log out the user
                },
                child: const Text('Logout'),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
