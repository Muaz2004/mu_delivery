import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mu_delivery/authentication.dart';
import 'package:mu_delivery/coustemer_home_page.dart';
import 'package:mu_delivery/owner_dashboard.dart';
import 'package:provider/provider.dart'; // 🔹 Needed to access myProvider
import 'package:mu_delivery/providers/auth_provider.dart'; // 🔹 import your provider

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            // 🔹 Password input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            // 🔹 Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _signIn,
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 🔹 Navigation to Sign Up page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Authentication()),
                    );
                  },
                  child: const Text("Register here"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Sign in logic now fully handled via myProvider
  Future<void> _signIn() async {
    try {
      // 🔹 Step 1: Call provider's signIn method
      await context.read<myProvider>().signIn(
        _emailController.text,
        _passwordController.text,
      );

      // 🔹 Step 2: Get role from provider
      final role = context.read<myProvider>().role;

      // 🔹 Step 3: Navigate according to role
      if (role == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }

      // 🔹 Step 4: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in successful!')),
      );
    } on FirebaseAuthException catch (e) {
      // 🔹 Handle email not verified
      if (e.code == 'email-not-verified') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email not verified'),
            content: const Text('Would you like to resend the verification email?'),
            actions: [
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent!')),
                  );
                },
                child: const Text('Resend Email'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        if (e.code == 'invalid-email') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The email address is badly formatted.')),
    );
  } else if (e.code == 'user-disabled') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This account has been disabled.')),
    );
  } else if (e.code == 'user-not-found') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user found with this email.')),
    );
  } else if (e.code == 'wrong-password') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect password. Try again.')),
    );
  } else if (e.code == 'network-request-failed') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No internet connection. Please try later.')),
    );
  } else if (e.code == 'too-many-requests') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Too many attempts. Try again later.')),
    );
  } else if (e.code == 'operation-not-allowed') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email/password accounts are not enabled.')),
    );}
      
      } else {
        // 🔹 Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      // 🔹 Generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
