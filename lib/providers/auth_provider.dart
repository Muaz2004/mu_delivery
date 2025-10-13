import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class myProvider extends ChangeNotifier {
  User? user;
  String? role;
  bool isLoading = true;

  myProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      role = (data != null && data.containsKey('role')) ? data['role'] as String : null;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (!credential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in.',
        );
      }

      // Update provider state
      user = credential.user;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = userDoc.data();
      role = (data != null && data.containsKey('role')) ? data['role'] as String : null;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    user = null;
    role = null;
    notifyListeners();
  }
}
