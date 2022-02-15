import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/account_settings.dart';
import 'package:later_flutter/views/folder_list.dart';
import 'package:later_flutter/views/folder_manager.dart';
import 'package:later_flutter/views/general_settings.dart';
import 'package:later_flutter/views/home_page.dart';

class StandardDrawer extends StatelessWidget {
  const StandardDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListView(padding: const EdgeInsets.only(top: 0), children: [
        SizedBox(
            width: 310,
            height: 150,
            child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.orange),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Later", style: TextStyle(fontSize: 24)),
                    Text(FirebaseAuth.instance.currentUser!.email!),
                  ],
                ))),
        ListTile(
          title: const Text("Home"),
          leading: const Icon(Icons.home),
          onTap: () {
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? MaterialPageRoute(builder: (context) => const HomePage())
                    : FadeRoute(page: const HomePage()));
          },
        ),
        ListTile(
          title: const Text("Account"),
          leading: const Icon(Icons.person),
          onTap: () {
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? MaterialPageRoute(
                        builder: (context) => const AccountSettings())
                    : FadeRoute(page: const AccountSettings()));
          },
        ),
        ListTile(
          title: const Text("Settings"),
          leading: const Icon(Icons.settings),
          onTap: () {
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? MaterialPageRoute(
                        builder: (context) => const GeneralSettings())
                    : FadeRoute(page: const GeneralSettings()));
          },
        ),
        ListTile(
          title: const Text("Manage Folders"),
          leading: const Icon(Icons.folder_open),
          onTap: () {
            Navigator.pushReplacement(
                context,
                displayMobileLayout
                    ? MaterialPageRoute(
                        builder: (context) => const FolderManager())
                    : FadeRoute(page: const FolderManager()));
          },
        ),
        const Divider(),
        const FolderList()
      ]),
    );
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
