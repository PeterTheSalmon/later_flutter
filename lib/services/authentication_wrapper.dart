import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/intro_screen/intro_screen.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/account/log_in_page.dart';
import 'package:later_flutter/views/home%20page/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    // If we have a first time user, show the intro screen
    if (Globals.hasSeenIntro == false && !kIsWeb) {
      return AppIntroScreen();
    }

    // Otherwise, check firebase status and react accordingly
    if (firebaseUser != null) {
      return const HomePage();
    } else {
      return const LogInPage();
    }
  }
}
