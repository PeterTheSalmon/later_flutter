// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:later_flutter/views/styles/fade_route.dart';

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
    Navigator.pushReplacement(context,
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

  Future<void> signUp(String email, String confirmEmail, String password,
      String confirmPassword, String displayName, BuildContext context) async {
    if (email != confirmEmail) {
      errorMessage = 'Emails do not match';
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      errorMessage = null;
      notifyListeners();
      Navigator.pop(context);
      Navigator.push(context, FadeRoute(page: const AuthenticationWrapper()));
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return;
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

  /// Delete the current user account, including any and all data owned by the user
  /// Only call this method once delete confirmation is received,
  /// as it is irreversible.
  /// * Pushing the authentication wrapper is handled from `delete_account_view.dart`
  Future<void> deleteAccount() async {
    // first we delete the users folders and links from the database
    var folders = FirebaseFirestore.instance
        .collection('folders')
        .where("userId", isEqualTo: _firebaseAuth.currentUser!.uid);
    await folders.get().then((value) => value.docs.forEach((element) {
          FirebaseFirestore.instance
              .collection('folders')
              .doc(element.id)
              .delete();
        }));

    // links
    var links = FirebaseFirestore.instance
        .collection('links')
        .where("userId", isEqualTo: _firebaseAuth.currentUser!.uid);
    await links.get().then((value) => value.docs.forEach((element) {
          FirebaseFirestore.instance
              .collection('links')
              .doc(element.id)
              .delete();
        }));

    try {
      await _firebaseAuth.currentUser!.delete();
      errorMessage = null;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }
}
