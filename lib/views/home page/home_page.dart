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
  DocumentSnapshot? randomLink;
  final int currentTime = DateTime.now().hour;

  final morningIndex = Random().nextInt(Globals.morningGreetings.length);
  final afternoonIndex = Random().nextInt(Globals.afternoonGreetings.length);
  final eveningIndex = Random().nextInt(Globals.eveningGreetings.length);

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
                IconButton(
                    onPressed: () {
                      _showWebWarning(context);
                    },
                    icon: const Icon(Icons.warning))
              ],
            ),
            floatingActionButton: SpeedDial(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 500
                        : 370,
                    child: Column(
                      children: [
                        Text(
                            currentTime > 22
                                ? "Don't stay up too later!"
                                : currentTime < 10
                                    ? "${Globals.morningGreetings[morningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}!"
                                    : currentTime < 16
                                        ? "${Globals.afternoonGreetings[afternoonIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}."
                                        : "${Globals.eveningGreetings[eveningIndex]}${FirebaseAuth.instance.currentUser?.displayName ?? "Set your display name in Account settings"}.",
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
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
    if (randomLink == null) {
      return Container(
        width: 250,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: const Center(
          child: Text("No links found"),
        ),
      );
    }

    return Container(
      width: 250,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ListTile(
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
          onTap: () {
            kIsWeb
                ? null
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LinkDetailView(document: randomLink!)));
          },
          leading: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                if (await canLaunch(randomLink!["url"]!)) {
                  launch(randomLink!["url"], enableJavaScript: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Could not launch ${randomLink!["url"]}"),
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
