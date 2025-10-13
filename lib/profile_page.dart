import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mu_delivery/mini_screen.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/signin_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
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

          // --- Mini cart widget at the bottom ---
          const MiniScreen(), // 👈 This will show the cart info at bottom
        ],
      ),
    );
  }
}
