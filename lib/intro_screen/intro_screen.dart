import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:later_flutter/services/authentication_wrapper.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIntroScreen extends StatelessWidget {
  AppIntroScreen({Key? key, this.isAReplay = false}) : super(key: key);
  bool isAReplay;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: introPages,
      showDoneButton: true,
      done: const Text("Start"),
      onDone: () async {
        if (isAReplay) {
          Navigator.pop(context);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenIntro', true);
        Globals.hasSeenIntro = true;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AuthenticationWrapper()));
      },
      showNextButton: true,
      next: const Text("Next"),
      showBackButton: true,
      back: const Text("Back"),
    );
  }
}

TextStyle iconTextStyle =
    const TextStyle(fontSize: 18, fontWeight: FontWeight.w300);

List<PageViewModel> introPages = [
  PageViewModel(
      title: "Welcome to Later!",
      body: "Let's get started",
      image: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Image.asset("assets/Icon256x256@2x.png")),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 18.0),
        bodyPadding:
            EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
      )),
  PageViewModel(
      title: "Save Links",
      bodyWidget: Column(
        children: <Widget>[
          const Text(
            "Save links to your favourite websites",
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 50.0),
          Image.asset("assets/folder_preview.png")
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        titlePadding:
            EdgeInsets.only(left: 16.0, top: 150.0, right: 16.0, bottom: 26.0),
        bodyTextStyle: TextStyle(fontSize: 18.0),
      )),
  PageViewModel(
      title: "Access Anywhere",
      bodyWidget: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                "Later is available on the following platforms:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.android,
                        size: 60,
                        color: Colors.green,
                      ),
                      Text(
                        "Android",
                        style: iconTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      const Icon(Icons.desktop_mac,
                          size: 60, color: Colors.orange),
                      Text(
                        "macOS",
                        style: iconTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      const Icon(
                        Icons.web,
                        size: 60,
                        color: Colors.cyan,
                      ),
                      Text(
                        "Web",
                        style: iconTextStyle,
                      ),
                    ],
                  ),
                ]),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                "and coming soon too:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.phone_iphone,
                      size: 60,
                      color: Colors.red,
                    ),
                    Text(
                      "iOS",
                      style: iconTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.laptop_windows,
                      size: 60,
                      color: Colors.blue,
                    ),
                    Text(
                      "Windows",
                      style: iconTextStyle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        titlePadding:
            EdgeInsets.only(left: 16.0, top: 150.0, right: 16.0, bottom: 26.0),
        bodyTextStyle: TextStyle(fontSize: 18.0),
      ))
];
