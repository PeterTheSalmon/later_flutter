// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/folder_icon_getter.dart';
import 'package:later_flutter/services/global_variables.dart';
import 'package:later_flutter/views/folders/edit_folder_dialog.dart';
import 'package:later_flutter/views/folders/folder_icon_chooser.dart';
import 'package:later_flutter/views/folders/folder_view.dart';
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
  DocumentSnapshot? _backupDocument;
  final List<QueryDocumentSnapshot> _backupLinks = [];

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;

    return Row(
      children: [
        if (!displayMobileLayout)
          const Drawer(
            child: StandardDrawer(),
          ),
        Expanded(
          child: Scaffold(
              appBar: AppBar(title: const Text("Manage Folders")),
              drawer: displayMobileLayout
                  ? const Drawer(child: StandardDrawer())
                  : null,
              floatingActionButton: FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                        return ListTile(
                          title: Text(
                            document["name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: getFolderIcon(document["iconName"]),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                displayMobileLayout
                                    ? fadeThrough((context, animation,
                                            secondaryAnimation) =>
                                        FolderView(
                                          parentFolderId: document.id,
                                          parentFolderName: document["name"],
                                        ))
                                    : FadeRoute(
                                        page: FolderView(
                                        parentFolderId: document.id,
                                        parentFolderName: document["name"],
                                      )));
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: "Edit Folder",
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        value: "icon",
                                        child: Text("Change Icon"),
                                      ),
                                      const PopupMenuItem(
                                        value: "name",
                                        child: Text("Change Name"),
                                      ),
                                    ];
                                  },
                                  onSelected: (value) {
                                    if (value == "icon") {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              FolderIconChooser(
                                                  folder: document));
                                    } else if (value == "name") {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              EditFolderDialog(
                                                  document: document));
                                    }
                                  }),
                              IconButton(
                                tooltip: "Delete Folder",
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  /// * First, we create a backup of the folder
                                  /// * And all links it contains
                                  setState(() {
                                    _backupDocument = document;
                                  });

                                  var links = FirebaseFirestore.instance
                                      .collection('links')
                                      .where("userId",
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .where("parentFolderId",
                                          isEqualTo: document.id);
                                  await links.get().then(
                                      (value) => value.docs.forEach((element) {
                                            _backupLinks.add(element);
                                            FirebaseFirestore.instance
                                                .collection('links')
                                                .doc(element.id)
                                                .delete();
                                          }));

                                  FirebaseFirestore.instance
                                      .collection("folders")
                                      .doc(document.id)
                                      .delete();
                                  final deleteSnackBar = SnackBar(
                                    content: const Text("Deleted"),
                                    action: SnackBarAction(
                                      label: "Undo",
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("folders")
                                            .doc(_backupDocument!.id)
                                            .set({
                                          "dateCreated":
                                              _backupDocument!["dateCreated"]!,
                                          "iconName":
                                              _backupDocument!["iconName"]!,
                                          "name": _backupDocument!["name"]!,
                                          "userId": FirebaseAuth
                                              .instance.currentUser!.uid
                                        });
                                        _backupLinks.forEach((element) {
                                          FirebaseFirestore.instance
                                              .collection('links')
                                              .doc(element.id)
                                              .set({
                                            "dateCreated":
                                                element["dateCreated"]!,
                                            "parentFolderId":
                                                element["parentFolderId"]!,
                                            "title": element["title"]!,
                                            "url": element["url"]!,
                                            "userId": FirebaseAuth
                                                .instance.currentUser!.uid,
                                            "isFavourite":
                                                element["isFavourite"]
                                          });
                                        });
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(deleteSnackBar);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList());
                    }),
              )),
        ),
      ],
    );
  }
}
