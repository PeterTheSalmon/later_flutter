import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/account/account%20settings/account_settings.dart';
import 'package:later_flutter/views/drawer/components/header.dart';
import 'package:later_flutter/views/drawer/components/static_items.dart';
import 'package:later_flutter/views/folders/folder_list.dart';
import 'package:later_flutter/views/folders/folder_manager.dart';
import 'package:later_flutter/views/settings/general_settings.dart';
import 'package:later_flutter/views/home%20page/home_page.dart';
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
      child: Column(children: [
        StandardDrawerHeader(
            headerImageDark: headerImageDark,
            headerImageLight: headerImageLight),

        // Scrollable List Section
        Expanded(
          child: ListView(
              padding: const EdgeInsets.only(top: 0),
              children: const [StaticListItems(), FolderList()]),
        ),
      ]),
    );
  }
}
