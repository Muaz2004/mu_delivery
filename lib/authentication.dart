import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mu_delivery/signin_page.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  Widget build(BuildContext context) {
    // 1. DETECT THEME & DEFINE COLORS (Consistency is Key)
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
            // 2. HEADER SECTION
            Container(
              height: MediaQuery.of(context).size.height * 0.28,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: brandOrange,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add_alt_1_rounded, size: 60, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Join the MU Delivery family",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            // 3. FORM SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
              child: Column(
                children: [
                  // Full Name
                  _buildFieldContainer(isDark, cardColor, 
                    TextField(
                      controller: _fullNameController,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Full Name", Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  _buildFieldContainer(isDark, cardColor, 
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Mobile Number", Icons.phone_android_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildFieldContainer(isDark, cardColor, 
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Email", Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildFieldContainer(isDark, cardColor, 
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      decoration: _buildInputDeco("Password", Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown (Styled to match inputs)
                  _buildFieldContainer(isDark, cardColor,
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      dropdownColor: cardColor,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                      decoration: _buildInputDeco("Select Role", Icons.admin_panel_settings_outlined),
                      items: ['customer', 'owner']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role[0].toUpperCase() + role.substring(1)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Button
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
                      onPressed: _signUp,
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer: Navigate to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: textSecondary)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SigninPage()),
                          );
                        },
                        child: const Text(
                          "Sign In",
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

  // --- UI HELPER METHODS (Same as Signin for consistency) ---
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
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFFF7043), size: 22),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  // --- YOUR LOGIC (UNTOUCHED) ---
  Future<void> _signUp() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user!.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'userId': credential.user!.uid,
        'name': _fullNameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'restaurantRef': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup successful! We have sent you a verification email, check it out!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF2D2D2D),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}