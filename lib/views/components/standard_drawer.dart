import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/account_settings.dart';
import 'package:later_flutter/views/folders/folder_list.dart';
import 'package:later_flutter/views/folders/folder_manager.dart';
import 'package:later_flutter/views/settings/general_settings.dart';
import 'package:later_flutter/views/home_page.dart';
import 'package:later_flutter/views/styles/fade_route.dart';

class StandardDrawer extends StatefulWidget {
  const StandardDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<StandardDrawer> createState() => _StandardDrawerState();
}

class _StandardDrawerState extends State<StandardDrawer> {
  late Image headerImage;

  @override
  void initState() {
    super.initState();
    headerImage = Image.asset('assets/HeaderImage.jpg');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(headerImage.image, context);
  }

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
        displayMobileLayout
            ? SizedBox(
                width: 310,
                height: 150,
                child: DrawerHeader(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: headerImage.image, fit: BoxFit.cover),
                        color: Color.fromARGB(255, 196, 173, 138)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        const Text("Later", style: TextStyle(fontSize: 24)),
                        Text(FirebaseAuth.instance.currentUser!.email!),
                      ],
                    )))
            : const SizedBox(height: 30),
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
