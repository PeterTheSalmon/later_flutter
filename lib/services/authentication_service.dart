import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/authentication_wrapper.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth, this.errorMessage);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String? errorMessage;

  Future<void> resetPassword(BuildContext context) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
          email: FirebaseAuth.instance.currentUser!.email!);
    } catch (error) {
      return;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _firebaseAuth.signOut();
    notifyListeners();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AuthenticationWrapper()));
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

  Future<void> signUp(
      String email, String password, BuildContext context) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      errorMessage = null;
      notifyListeners();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> reauthenticate(String password) async {
    try {
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: _firebaseAuth.currentUser!.email!, password: password));
      errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser!.delete();
      errorMessage = null;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }
}
