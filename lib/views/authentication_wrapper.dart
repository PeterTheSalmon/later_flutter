import 'package:flutter/material.dart';
import 'package:later_flutter/views/home_page.dart';
import 'package:later_flutter/views/account/log_in_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomePage();
    } else {
      return LogInPage();
    }
  }
}
