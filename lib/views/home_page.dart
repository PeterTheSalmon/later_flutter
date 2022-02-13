import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    setState(() {
      _tipIndex = Random().nextInt(Globals.tipList.length);
    });
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
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
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 248, 174, 62),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        height: 100,
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Center(child: Text(Globals.tipList[_tipIndex])),
                        )),
                    onTap: () {
                      setState(() {
                        _tipIndex = Random().nextInt(Globals.tipList.length);
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
