import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/intro_screen/intro_screen.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/account/log_in_page.dart';
import 'package:later_flutter/views/home%20page/home_page.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If we have a first time user, show the intro screen
    if (Globals.hasSeenIntro == false && !kIsWeb) {
      return AppIntroScreen();
    }

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color.fromARGB(255, 66, 66, 66)
                : const Color.fromARGB(255, 243, 243, 243),
          ),
          child: AnimatedSwitcher(
            // The native apps don't need this fade.
            duration: const Duration(milliseconds: kIsWeb ? 500 : 0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? (kIsWeb
                    ? Scaffold(
                        key: const ValueKey('loading'),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Scaffold())
                : snapshot.data != null
                    ? const HomePage(
                        key: ValueKey('home'),
                      )
                    : const LogInPage(
                        key: ValueKey('login'),
                      ),
          ),
        );
      },
    );
  }
}
