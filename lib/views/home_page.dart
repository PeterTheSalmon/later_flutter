import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/services/share_service.dart';
import 'package:later_flutter/views/folders/new_folder_sheet.dart';
import 'package:later_flutter/views/components/standard_drawer.dart';
import 'package:later_flutter/views/links/link_detail_view.dart';
import 'package:later_flutter/views/links/new_link_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _sharedText;
  int _tipIndex = 0;
  double _containerHeight = 100;
  double _containerWidth = 200;
  List<DocumentSnapshot> _links = [];

  void countFolders() async {
    QuerySnapshot _myDocs = await FirebaseFirestore.instance
        .collection('folders')
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<DocumentSnapshot> _myDocCount = _myDocs.docs;
    int folderCount = _myDocCount.length;
    if (folderCount == 0) {
      FirebaseFirestore.instance.collection("folders").add({
        "name": "Uncategorized",
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "dateCreated": DateTime.now(),
        "iconName": "folder",
      });
    }
  }

  void getLinks() async {
    QuerySnapshot _myDocs = await FirebaseFirestore.instance
        .collection('links')
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      _links = _myDocs.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _tipIndex = Random().nextInt(Globals.tipList.length);
    });
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
    countFolders();
    getLinks();
  }

  void _handleSharedData(String sharedData) async {
    /// Due to the nature of sharing, the shared data is shown as though it is
    /// new every time the homepage is loaded. As such, we need to confirm that
    /// it truly is new before showing the new link dialog.
    if (Globals.sharedUrl != sharedData) {
      Globals.sharedUrl = sharedData;
      setState(() {
        _sharedText = sharedData;
      });
      if (_sharedText != null && _sharedText?.isNotEmpty == true) {
        await Clipboard.setData(ClipboardData(text: _sharedText));
        await showNewLinkSheet(context,
            fromClipboard: true, useDialog: true, parentFolderId: "");
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
          : {
              SingleActivator(LogicalKeyboardKey.keyN,
                  meta: Platform.isMacOS ? true : false,
                  control: Platform.isMacOS ? false : true,
                  alt: true): () {
                showNewLinkSheet(context,
                    parentFolderId: "", fromClipboard: true, useDialog: true);
              },
              SingleActivator(
                LogicalKeyboardKey.keyN,
                meta: Platform.isMacOS ? true : false,
                control: Platform.isMacOS ? false : true,
              ): () {
                showNewLinkSheet(context, parentFolderId: "", useDialog: true);
              },
              SingleActivator(LogicalKeyboardKey.keyN,
                  meta: Platform.isMacOS ? true : false,
                  control: Platform.isMacOS ? false : true,
                  shift: true): () {
                showNewFolderSheet(context, useDialog: true);
              },
            },
      child: Focus(
        autofocus: true,
        child: Row(children: [
          if (!displayMobileLayout)
            const Drawer(
              child: StandardDrawer(),
            ),
          Expanded(
              child: Scaffold(
            appBar: AppBar(
              title: const Text("Later"),
            ),
            floatingActionButton: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Globals.appColour,
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: "Add from Clipboard",
                    onTap: () async {
                      showNewLinkSheet(context,
                          parentFolderId: "",
                          fromClipboard: true,
                          useDialog: true);
                    }),
                SpeedDialChild(
                  child: const Icon(Icons.add_link),
                  label: "Save Link",
                  onTap: () {
                    showNewLinkSheet(context,
                        useDialog: true, parentFolderId: "");
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.folder),
                  label: "Create Folder",
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 500
                        : 270,
                    child: Column(
                      children: [
                        const Text("Home", style: TextStyle(fontSize: 20)),
                        _tipsBox(context),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Random Link:"),
                        ),
                        _randomLink(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
        ]),
      ),
    );
  }

  Padding _tipsBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        child: SizedBox(
          height: 120,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color.fromARGB(255, 90, 90, 90)
                        : const Color.fromARGB(255, 233, 233, 233),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              height: _containerHeight,
              width: _containerWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Column(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 184,
                      child: Text(
                        Globals.tipList[_tipIndex],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Tap for next tip",
                      style: TextStyle(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color.fromARGB(255, 182, 181, 181)
                              : const Color.fromARGB(255, 88, 88, 88)),
                    )
                  ],
                )),
              )),
        ),
        onTap: () {
          int previousIndex = _tipIndex;
          while (previousIndex == _tipIndex) {
            setState(() {
              _tipIndex = Random().nextInt(Globals.tipList.length);
            });
          }
          setState(() {
            _containerHeight += 10;
            _containerWidth += 10;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _containerHeight -= 10;
              _containerWidth -= 10;
            });
          });
        },
      ),
    );
  }

  Widget _randomLink() {
    if (_links.isEmpty) {
      return const Text("No links saved");
    }
    final document = (_links..shuffle()).first;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ListTile(
          title: Text(
            document["title"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            document["url"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LinkDetailView(document: document)));
          },
          leading: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                if (await canLaunch(document["url"]!)) {
                  launch(document["url"], enableJavaScript: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Could not launch ${document["url"]}"),
                    action: SnackBarAction(
                      label: "Close",
                      onPressed: () {},
                    ),
                  ));
                }
              }),
        ),
      ),
    );
  }
}
