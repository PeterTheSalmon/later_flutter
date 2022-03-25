// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/folders/folder_list_tile.dart';
import 'package:later_flutter/views/folders/search/folder_search.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_folder_sheet.dart';
import 'package:later_flutter/views/drawer/standard_drawer.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

class FolderManager extends StatefulWidget {
  const FolderManager({Key? key}) : super(key: key);

  @override
  State<FolderManager> createState() => _FolderManagerState();
}

class _FolderManagerState extends State<FolderManager> {

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;

    return Row(
      children: [
        if (!displayMobileLayout) const DesktopDrawer(),
        Expanded(
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Manage Folders"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(
                        context,
                        displayMobileLayout
                            ? fadeThrough(
                                (context, animation, secondaryAnimation) =>
                                    const FolderSearch(),
                              )
                            : FadeRoute(
                                page: const FolderSearch(),
                              ),
                      );
                    },
                  )
                ],
              ),
              drawer: displayMobileLayout
                  ? const Drawer(child: StandardDrawer())
                  : null,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  showNewFolderSheet(context);
                },
                label: const Text("New Folder"),
                icon: const Icon(Icons.add),
                backgroundColor: Globals.appColour,
              ),
              body: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("folders")
                        .orderBy("name")
                        .where("userId",
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Something went wrong :("),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Column(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                        return FolderListTile(document: document, showEditDelete: true,);
                        
                      }).toList());
                    }),
              )),
        ),
      ],
    );
  }
}
