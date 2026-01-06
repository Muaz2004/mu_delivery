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
    // Styling Variables
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color brandOrange = Color(0xFFFF7043);
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final Color textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Styled Header
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: brandOrange,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delivery_dining_rounded, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Sign in to continue your delivery",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Styled Email input
                  _buildFieldContainer(
                    isDark, cardColor,
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Email", Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Styled Password input
                  _buildFieldContainer(
                    isDark, cardColor,
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Password", Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: _signIn,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Navigate to Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: textSecondary)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Authentication()),
                          );
                        },
                        child: const Text("Register here", 
                          style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---
  Widget _buildFieldContainer(bool isDark, Color cardColor, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFFFF7043)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  // --- YOUR LOGIC (100% UNTOUCHED) ---
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