// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:later_flutter/intro_screen/intro_pages.dart';

class AppIntroScreen extends StatelessWidget {
  AppIntroScreen({Key? key, this.isAReplay = false}) : super(key: key);
  bool isAReplay;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: IntroPages,
      showBackButton: true,
      done: const Text("Start"),
      next: const Text("Next"),
      back: const Text("Back"),
      onDone: () async {
        // When replaying from settings, we can just pop at the end instead of
        // pushing to the login/home screen.
        if (isAReplay) {
          Navigator.pop(context);
          return;
        }

        // Otherwise, we mark the intro as seen and push login/home screen.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenIntro', true);
        Globals.hasSeenIntro = true;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AuthenticationWrapper()));
      },
    );
  }
}

