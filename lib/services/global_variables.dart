import 'package:flutter/material.dart';

/// Convenience class for values that rarely change and are used throughout the app
class Globals {
  /// Whether the user has seen the intro already
  static bool hasSeenIntro = false;

  /// The previously shared url. This is used to prevent showing the share dialog again
  static String? sharedUrl;

  static const List<String> morningGreetings = [
    "Good morning, ",
    "Morning, ",
    "Goodmorrow, ",
  ];

  static const List<String> afternoonGreetings = [
    "Good afternoon, ",
    "Afternoon, ",
    "Howdy, ",
  ];

  static const List<String> eveningGreetings = [
    "Good evening, ",
    "Evening, ",
  ];


  Map<int, Color> customColour = {
    50: const Color.fromRGBO(243, 168, 59, .1),
    100: const Color.fromRGBO(243, 168, 59, .2),
    200: const Color.fromRGBO(243, 168, 59, .3),
    300: const Color.fromRGBO(243, 168, 59, .4),
    400: const Color.fromRGBO(243, 168, 59, .5),
    500: const Color.fromRGBO(243, 168, 59, .6),
    600: const Color.fromRGBO(243, 168, 59, .7),
    700: const Color.fromRGBO(243, 168, 59, .8),
    800: const Color.fromRGBO(243, 168, 59, .9),
    900: const Color.fromRGBO(243, 168, 59, 1),
  };

  MaterialColor appSwatch() => MaterialColor(0xFFF3A839, customColour);
  static Color appColour = const Color.fromARGB(255, 243, 168, 59);

  /// A list of tips for use on the home page.
  /// The tips are displayed in a random order.
  static List<String> tipList = [
    "Click the menu in the bottom right for quick actions!",
    "Later is completely open source and free to use!",
    "You can also share the app with your friends!",
    "Check out the Mac app for a Mac version!",
    "You can use Later on the web, on desktop, or on mobile!",
    "Mmm tips",
    "Later supports keyboard shortcuts! Try ctrl/cmd + n to save a link.",
    "Later supports keyboard shortcuts! Try ctrl/cmd + shift + n to create a folder.",
    "Later supports keyboard shortcuts! Try ctrl/cmd + alt + n to save a link on your clipboard.",
    "When sharing a link or adding from your clipboard, Later will automatically add the title of the page!",
    "Swipe links to access quick options on mobile!",
  ];
}
