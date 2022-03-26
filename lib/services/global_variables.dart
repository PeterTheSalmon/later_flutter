import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Convenience class for values that rarely change and are used throughout the app
class Globals {
  /// Whether the user has seen the intro already
  static bool hasSeenIntro = false;

  /// The previously shared url. This is used to prevent showing the share dialog again
  static String? sharedUrl;

  static const List<String> morningGreetings = [
    'Good morning, ',
    'Morning, ',
    'Goodmorrow, ',
  ];

  static const List<String> afternoonGreetings = [
    'Good afternoon, ',
    'Afternoon, ',
    'Howdy, ',
  ];

  static const List<String> eveningGreetings = [
    'Good evening, ',
    'Evening, ',
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

  static List<Tip> tips = [
    Tip(
      title: 'Quick Actions',
      content: 'Click the menu in the bottom right for quick actions!',
    ),
    Tip(
      title: 'Open Source',
      content: 'Later is completely open source and free to use!',
      buttonTitle: 'View Source',
      buttonAction: () {
        launch('https://github.com/PeterTheSalmon/later_flutter');
      },
    ),
    Tip(
      title: 'Love Later?',
      content: 'You can also share the app with your friends!',
      buttonTitle: 'Share',
      buttonAction: () {
        Share.share(
          'https://www.petersalmon.dev/later',
          subject: 'Check out Later!',
        );
      },
    ),
    Tip(
      title: 'Mac App',
      content: 'Check out the Mac app for a Mac version!',
      buttonTitle: 'Download',
      buttonAction: () {
        launch('https://github.com/PeterTheSalmon/Later');
      },
    ),
    Tip(
      title: 'Access Anywhere',
      content: 'You can use Later on the web, on desktop, or on mobile!',
    ),
    Tip(
      title: 'Keyboard Shortcuts',
      content:
          'Later supports keyboard shortcuts! Try ctrl/cmd + n to save a link.',
    ),
    Tip(
      title: 'Keyboard Shortcuts',
      content: 'Try ctrl/cmd + shift + n to create a folder.',
    ),
    Tip(
      title: 'Keyboard Shortcuts',
      content: 'Try ctrl/cmd + alt + n to save a link from your clipboard.',
    ),
    Tip(
      title: 'Quick Add Links',
      content:
          'Later will automatically add the title of a  page from your clipboard!',
    ),
    Tip(
      title: 'Swipe Links',
      content: 'Swipe links to access quick options on mobile!',
    ),
    Tip(
      title: 'Random Link',
      content: 'Check out the random link, right below these tips!',
    ),
    Tip(
      title: 'Access Anywhere',
      content: 'Access your links anytime at later.petersalmon.dev',
      buttonTitle: 'Open Now',
      buttonAction: () {
        launch('https://later.petersalmon.dev');
      },
    ),
  ];
}

class Tip {
  Tip({
    required this.title,
    required this.content,
    this.buttonTitle,
    this.buttonAction,
  });

  final String title;
  final String content;
  final String? buttonTitle;
  final Function? buttonAction;
}
