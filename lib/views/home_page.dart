import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/services/share_service.dart';
import 'package:later_flutter/views/new_folder_sheet.dart';
import 'package:later_flutter/views/new_link_dialog.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: NewLinkDialog(initalUrl: _sharedText),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Later"),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.orange,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: "Add from Clipboard",
              onTap: () async {
                ClipboardData? data =
                    await Clipboard.getData(Clipboard.kTextPlain);
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: NewLinkDialog(initalUrl: data?.text),
                  ),
                );
              }),
          SpeedDialChild(
            child: const Icon(Icons.add_link),
            label: "Save Link",
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: NewLinkDialog(initalUrl: null),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder),
            label: "Create Folder",
            onTap: () {
              showNewFolderSheet(context);
            },
          ),
        ],
      ),
      drawer: const Drawer(child: StandardDrawer()),
      body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              children: [
                const Text("Home", style: TextStyle(fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          // Slightly darker in dark mode
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color.fromARGB(255, 228, 145, 21)
                              : const Color.fromARGB(255, 248, 174, 62),
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
                              const Text(
                                "Tap for next tip",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 94, 94, 94)),
                              )
                            ],
                          )),
                        )),
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
                ),
              ],
            ),
          )),
    );
  }
}
