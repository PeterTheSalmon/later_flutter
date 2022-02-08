import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth; 

  AuthenticationService(this._firebaseAuth, this.errorMessage);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String? errorMessage;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }
}
