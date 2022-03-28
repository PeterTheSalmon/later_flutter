import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/services/share_service.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/home%20page/components/greeting.dart';
import 'package:later_flutter/views/home%20page/components/keyboard_bindings.dart';
import 'package:later_flutter/views/home%20page/components/random_link.dart';
import 'package:later_flutter/views/home%20page/components/tips_box.dart';
import 'package:later_flutter/views/home%20page/functions/show_web_warning.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_folder_sheet.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_link_sheet.dart';
import 'package:later_flutter/views/settings/general_settings.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _sharedText;
  DocumentSnapshot? randomLink;

  final int currentTime = DateTime.now().hour;

  final morningIndex = Random().nextInt(Globals.morningGreetings.length);
  final afternoonIndex = Random().nextInt(Globals.afternoonGreetings.length);
  final eveningIndex = Random().nextInt(Globals.eveningGreetings.length);

  @override
  void initState() {
    super.initState();
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
    countFolders();
    setRandomLink();
  }

  void countFolders() async {
    final QuerySnapshot folders = await FirebaseFirestore.instance
        .collection('folders')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List<DocumentSnapshot> folderList = folders.docs;
    final int folderCount = folderList.length;
    if (folderCount == 0) {
      FirebaseFirestore.instance.collection('folders').add({
        'name': 'Uncategorized',
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'dateCreated': DateTime.now(),
        'iconName': 'folder',
      });
    }
  }

  void setRandomLink() async {
    final QuerySnapshot linkDocs = await FirebaseFirestore.instance
        .collection('links')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List<DocumentSnapshot> links = linkDocs.docs;
    setState(() {
      randomLink = links[Random().nextInt(links.length)];
    });
  }

  void _handleSharedData(String sharedData) async {
    /// Due to the nature of sharing, the shared data is shown as though it is
    /// new every time the homepage is loaded. As such, we need to confirm that
    /// it truly is new before showing the new link dialog.
    if (Globals.sharedUrl != sharedData) {
      SharedPreferences.getInstance()
          .then((prefs) => prefs.setString('previousShared', sharedData));
      Globals.sharedUrl = sharedData;
      setState(() {
        _sharedText = sharedData;
      });
      if (_sharedText != null && _sharedText?.isNotEmpty == true) {
        await Clipboard.setData(ClipboardData(text: _sharedText));
        await showNewLinkSheet(
          context,
          fromClipboard: true,
          useDialog: true,
          parentFolderId: '',
        );
        setState(() {
          _sharedText = null;
        });
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;
    return CallbackShortcuts(
      bindings: kIsWeb
          ? {} // * No bindings for web as it is impossible (?) to determine platform
          : homeBindings(context),
      child: Focus(
        autofocus: true,
        child: Row(
          children: [
            if (!displayMobileLayout) const DesktopDrawer(),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Later'),
                ),
                floatingActionButton: SpeedDial(
                  animatedIcon: AnimatedIcons.menu_close,
                  backgroundColor: Globals.appColour,
                  children: [
                    SpeedDialChild(
                      child: const Icon(Icons.copy),
                      label: 'Add from Clipboard',
                      onTap: () async {
                        showNewLinkSheet(
                          context,
                          parentFolderId: '',
                          fromClipboard: true,
                          useDialog: true,
                        );
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.add_link),
                      label: 'Save Link',
                      onTap: () {
                        showNewLinkSheet(
                          context,
                          useDialog: true,
                          parentFolderId: '',
                        );
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.folder),
                      label: 'Create Folder',
                      onTap: () {
                        showNewFolderSheet(context, useDialog: true);
                      },
                    ),
                  ],
                ),
                drawer: displayMobileLayout
                    ? const Drawer(child: StandardDrawer())
                    : null,
                body: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          children: <Widget>[
                            GreetingMessage(
                              afternoonIndex: afternoonIndex,
                              eveningIndex: eveningIndex,
                              morningIndex: morningIndex,
                              currentTime: currentTime,
                            ),
                            const TipsBox(),
                            if (kIsWeb)
                              Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    const ListTile(
                                      leading: SizedBox(
                                        height: 48,
                                        child: Icon(Icons.announcement),
                                      ),
                                      title: Text('Web App Limitations'),
                                      subtitle: Text(
                                        "Some features aren't available on the web",
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 2,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(18.0),
                                      child: Text(
                                        "Some features, including editing and sharing links, aren't available on the web. You can still use the desktop or mobile app to access these features.",
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    ButtonBar(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            showWebWarning(context);
                                          },
                                          child: const Text('Learn more'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              FadeRoute(
                                                page: const GeneralSettings(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Download native apps',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            RandomLink(
                              randomLink: randomLink,
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
