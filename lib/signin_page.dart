import 'package:flutter/material.dart';
import 'package:mu_delivery/authentication.dart';
import 'package:mu_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            // Email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            // Password input
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
            // Sign in button
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
            // Navigate to Register
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

  // Sign in logic
  Future<void> _signIn() async {
    try {
      // Call provider's signIn method
      await context.read<myProvider>().signIn(
            _emailController.text,
            _passwordController.text,
          );

      // Sign-in is successful, Wrapper handles navigation automatically
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in successful!')),
      );
    } on FirebaseAuthException catch (e) {
      // Email not verified
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
      } else {
        // Handle other FirebaseAuth errors
        String message = '';
        if (e.code == 'invalid-email') {
          message = 'The email address is badly formatted.';
        } else if (e.code == 'user-disabled') {
          message = 'This account has been disabled.';
        } else if (e.code == 'user-not-found') {
          message = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password. Try again.';
        } else if (e.code == 'network-request-failed') {
          message = 'No internet connection. Please try later.';
        } else if (e.code == 'too-many-requests') {
          message = 'Too many attempts. Try again later.';
        } else if (e.code == 'operation-not-allowed') {
          message = 'Email/password accounts are not enabled.';
        } else {
          message = e.message ?? 'Unknown error occurred';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
