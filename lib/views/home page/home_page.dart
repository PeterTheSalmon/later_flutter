import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/services/share_service.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_folder_sheet.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/links/link_detail_view.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_link_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  DocumentSnapshot? randomLink;
  final int currentTime = DateTime.now().hour;

  bool _condition = false;

  final morningIndex = Random().nextInt(Globals.morningGreetings.length);
  final afternoonIndex = Random().nextInt(Globals.afternoonGreetings.length);
  final eveningIndex = Random().nextInt(Globals.eveningGreetings.length);

  @override
  void initState() {
    super.initState();
    setState(() {
      _tipIndex = Random().nextInt(Globals.tips.length);
    });
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
    countFolders();
    setRandomLink();
  }

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

  void setRandomLink() async {
    QuerySnapshot _myDocs = await FirebaseFirestore.instance
        .collection('links')
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<DocumentSnapshot> _links = _myDocs.docs;
    setState(() {
      randomLink = _links[Random().nextInt(_links.length)];
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
                actions: [
                  if (kIsWeb)
                    IconButton(
                        onPressed: () {
                          _showWebWarning(context);
                        },
                        icon: const Icon(Icons.warning))
                ],
              ),
              floatingActionButton: SpeedDial(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                currentTime > 22
                                    ? "Don't stay up too later!"
                                    : currentTime < 12
                                        ? "${Globals.morningGreetings[morningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}!"
                                        : currentTime < 17
                                            ? "${Globals.afternoonGreetings[afternoonIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}."
                                            : "${Globals.eveningGreetings[eveningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}.",
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center),
                            _tipsBox(context),
                            _randomLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<dynamic> _showWebWarning(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => Dialog(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Some features aren't available on the web.",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "The following are unavailable:",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("- Receiving shared links"),
                      Text("- Links previews and notes"),
                      Text("- Link sharing"),
                      Text("- Editing links"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: 250,
                    child: Text(
                      "Please use the native versions of Later for these features.",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"))
                ],
              ),
            )));
  }

  Widget _tipsBox(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        key: ValueKey<int>(_tipIndex),
        padding: const EdgeInsets.only(top: 20.0),
        child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.lightbulb),
                    onPressed: () {},
                  ),
                  title: Text(Globals.tips[_tipIndex].title),
                ),
                const Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Center(
                      child: Text(
                        Globals.tips[_tipIndex].content,
                        key: ValueKey<int>(_tipIndex),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
                ButtonBar(
                  children: [
                    if (Globals.tips[_tipIndex].buttonAction != null)
                      TextButton(
                        child: Text(Globals.tips[_tipIndex].buttonTitle!),
                        onPressed: () {
                          Globals.tips[_tipIndex].buttonAction!();
                        },
                      ),
                    TextButton(
                      child: const Text("Next Tip"),
                      onPressed: () {
                        int previousIndex = _tipIndex;
                        while (previousIndex == _tipIndex) {
                          setState(() {
                            _tipIndex = Random().nextInt(Globals.tips.length);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Widget _randomLink() {
    return AnimatedOpacity(
      opacity: randomLink == null ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      child: randomLink == null
          ? const Card()
          : Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: IconButton(
                        tooltip: "Open in browser",
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () async {
                          if (await canLaunch(randomLink!["url"]!)) {
                            launch(randomLink!["url"], enableJavaScript: true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Could not launch ${randomLink!["url"]}"),
                              action: SnackBarAction(
                                label: "Close",
                                onPressed: () {},
                              ),
                            ));
                          }
                        }),
                    title: Text(
                      randomLink!["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      randomLink!["url"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: AnyLinkPreview(
                      link: randomLink!["url"],
                      borderRadius: 0,
                      bodyMaxLines: 3,
                      boxShadow: const [],
                      backgroundColor:
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color.fromARGB(255, 71, 71, 71)
                              : const Color.fromARGB(255, 243, 243, 243),
                      titleStyle: TextStyle(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black),
                      placeholderWidget: Container(
                          decoration: BoxDecoration(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 71, 71, 71)
                                : const Color.fromARGB(255, 243, 243, 243),
                          ),
                          child: const Center(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                          ))),
                      errorWidget: Container(
                          decoration: BoxDecoration(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 71, 71, 71)
                                : const Color.fromARGB(255, 243, 243, 243),
                          ),
                          child: const Center(
                              child: Text("No Preview Available :("))),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
