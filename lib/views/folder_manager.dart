import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/new_folder_sheet.dart';
import 'package:later_flutter/views/standard_drawer.dart';

class FolderManager extends StatefulWidget {
  const FolderManager({Key? key}) : super(key: key);

  @override
  State<FolderManager> createState() => _FolderManagerState();
}

class _FolderManagerState extends State<FolderManager> {
  DocumentSnapshot? _backupDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Manage Folders")),
        drawer: const Drawer(child: StandardDrawer()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showNewFolderSheet(context);
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.orange,
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("folders")
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
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                  return ListTile(
                    title: Text(document["name"]),
                    leading: const Icon(Icons.folder),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _backupDocument = document;
                        });
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
                                "dateCreated": _backupDocument!["dateCreated"]!,
                                "iconName": _backupDocument!["iconName"]!,
                                "name": _backupDocument!["name"]!,
                                "userId": FirebaseAuth.instance.currentUser!.uid
                              });
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(deleteSnackBar);
                      },
                    ),
                  );
                }).toList());
              }),
        ));
  }
}
