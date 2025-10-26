import 'package:flutter/material.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mu_delivery/signin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<myProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // =========================
          // User Header with Firestore name
          // =========================
          StreamBuilder<DocumentSnapshot>(
            stream: userId != null
                ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
                : null,
            builder: (context, snapshot) {
              String displayName = 'Guest User';
              if (snapshot.hasData && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                displayName = data['name'] ?? 'Guest User';
              }

              return UserAccountsDrawerHeader(
                accountName: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(
                  authProvider.user?.email ?? 'No email',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7043),
                ),
              );
            },
          ),

          // =========================
          // Dark Mode toggle
          // =========================
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.black87),
            title: const Text('Dark Mode'),
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (val) {
              context.read<ThemeProvider>().toggleDarkMode(val);
            },
          ),

          const Divider(height: 1),

          // =========================
          // About App
          // =========================
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.green),
            title: const Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About App'),
                  content: const Text(
                      'This is a demo food delivery app created with Flutter and Firebase.\n\n'
                      'Developed by Muaz Indris.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // =========================
          // Contact Us
          // =========================
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.purple),
            title: const Text('Contact Us'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Contact Us'),
                  content: const Text('You can reach out via Telegram:\n@Albatross3749'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // =========================
          // Logout button
          // =========================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SigninPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
