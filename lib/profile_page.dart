import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:mu_delivery/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    snapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return const Center(child: Text('User data not found'));
                }

                final name = userData['name'] ?? 'No Name';
                final email = userData['email'] ?? 'No Email';
                final mobile = userData['mobile'] ?? 'No Mobile';

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // ====================
                        // Profile Header
                        // ====================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFAB91),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white70,
                                child: Text(
                                  name.isNotEmpty ? name[0] : 'U',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mobile,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ====================
                        // Options Card
                        // ====================
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline,
                                    color: Colors.green),
                                title: const Text('About'),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios, size: 16),
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
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.contact_mail,
                                    color: Colors.purple),
                                title: const Text('Contact Us'),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Contact Us'),
                                      content: const Text(
                                          'You can reach out via Telegram:\n@Albatross3749'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.settings,
                                    color: Colors.blue),
                                title: const Text('Settings'),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =======================
// Settings Page
// =======================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        
        elevation: 2,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink to fit content
            children: [
              // Dark Mode toggle (placeholder)
             SwitchListTile(
             secondary: const Icon(Icons.dark_mode, color: Colors.black87),
             title: const Text('Dark Mode'),
             value: context.watch<ThemeProvider>().isDarkMode,
             onChanged: (val) {
             context.read<ThemeProvider>().toggleDarkMode(val);
             
              },
                  ),

              const Divider(height: 1),

              // Logout button
              ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
              showDialog(
              context: context,
              builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
             TextButton(
             onPressed: () {
              Navigator.pop(context); // close dialog
              },
            child: const Text('No'),
            ),
             TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog first
              await context.read<myProvider>().signOut();
              Navigator.of(context).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Yes'),
          ),
           ],
        ),
        );
      },
    ),

             
            ],
          ),
        ),
      ),
    );
  }
}
