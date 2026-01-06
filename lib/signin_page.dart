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
    // 1. DETECT THEME & DEFINE COLORS (Consistent with FoodDetail/Orders)
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
            // 2. HEADER SECTION (Modern Welcome)
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

            // 3. FORM SECTION
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Email Input
                  _buildTextField(
                    controller: _emailController,
                    hint: "Email Address",
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 20),
                  // Password Input
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline_rounded,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    cardColor: cardColor,
                    isPassword: true,
                  ),
                  
                  // Forgot Password alignment
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () { /* Logic later */ },
                      child: const Text("Forgot Password?", style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. SIGN IN BUTTON (Consistent with "Add to Cart")
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: _signIn,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. REGISTER NAVIGATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: textSecondary)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Authentication()),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(color: brandOrange, fontWeight: FontWeight.w900, fontSize: 15),
                        ),
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

  // REUSABLE TEXT FIELD STYLING
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textPrimary,
    required Color cardColor,
    bool isPassword = false,
  }) {
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
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFFFF7043)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  // Logic remains untouched as requested
  Future<void> _signIn() async {
    try {
      await context.read<myProvider>().signIn(
            _emailController.text,
            _passwordController.text,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in successful!')),
      );
    } on FirebaseAuthException catch (e) {
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
        } else {
          message = e.message ?? 'Unknown error occurred';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF2D2D2D),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}