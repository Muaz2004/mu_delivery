import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class myProvider extends ChangeNotifier {
  User? user;
  String? role;
  bool isLoading = true;

  myProvider() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      user = firebaseUser;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        final data = doc.data();
        role = (data != null && data.containsKey('role'))
            ? data['role'] as String
            : null;
      } else {
        role = null;
      }

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (!credential.user!.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before signing in.',
      );
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
