import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/account%20settings/account_settings.dart';
import 'package:later_flutter/views/folders/folder_manager.dart';
import 'package:later_flutter/views/home%20page/home_page.dart';
import 'package:later_flutter/views/settings/general_settings.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

class StaticListItems extends StatelessWidget {
  const StaticListItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text("Home"),
          leading: const Icon(Icons.home),
          onTap: () async {
            if (displayMobileLayout) {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 30));
            }
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? fadeThrough((context, animation, secondaryAnimation) =>
                        const HomePage())
                    : FadeRoute(page: const HomePage()));
          },
        ),
        ExpansionTile(
          leading: Icon(Icons.settings,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white
                      : const Color.fromARGB(255, 126, 126, 126)),
          title: const Text("Settings"),
          children: [
            ListTile(
              title: const Text("General"),
              leading: const Icon(Icons.tune),
              onTap: () async {
                if (displayMobileLayout) {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 30));
                }
                Navigator.pushReplacement(
                    context,
                    displayMobileLayout
                        ? fadeThrough(
                            (context, animation, secondaryAnimation) =>
                                const GeneralSettings())
                        : FadeRoute(page: const GeneralSettings()));
              },
            ),
            ListTile(
              title: const Text("Account"),
              leading: const Icon(Icons.person),
              onTap: () async {
                if (displayMobileLayout) {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 30));
                }
                Navigator.pushReplacement(
                    context,
                    displayMobileLayout
                        ? fadeThrough(
                            (context, animation, secondaryAnimation) =>
                                const AccountSettings())
                        : FadeRoute(page: const AccountSettings()));
              },
            ),
          ],
        ),
        ListTile(
          title: const Text("Manage Folders"),
          leading: const Icon(Icons.folder_open),
          onTap: () async {
            if (displayMobileLayout) {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 50));
            }
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? fadeThrough((context, animation, secondaryAnimation) =>
                        const FolderManager())
                    : FadeRoute(page: const FolderManager()));
          },
        ),
        const Divider(),
      ],
    );
  }
}
