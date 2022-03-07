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
  late Image headerImageDark;
  late Image headerImageLight;

  @override
  void initState() {
    super.initState();
    headerImageDark = Image.asset('assets/HeaderImage.jpg');
    headerImageLight = Image.asset('assets/HeaderImageLight.jpg');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(headerImageDark.image, context);
    precacheImage(headerImageLight.image, context);
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
        SizedBox(
            width: 310,
            height: 150,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? headerImageDark.image
                          : headerImageLight.image,
                      fit: BoxFit.cover),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const Text("Later",
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                    Text(FirebaseAuth.instance.currentUser!.email!,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ))),
        // : const SizedBox(height: 30),
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
