import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/new_link_sheet.dart';
import 'package:later_flutter/views/standard_drawer.dart';

class FolderView extends StatefulWidget {
  const FolderView(
      {Key? key, required this.parentFolderId, required this.parentFolderName})
      : super(key: key);

  final String parentFolderId;
  final String parentFolderName;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  final editSnackBar = SnackBar(
    content: const Text('Editing is currently unimplemented'),
    action: SnackBarAction(label: "Close", onPressed: () {}),
  );

  DocumentSnapshot? _backupDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.parentFolderName),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showNewLinkSheet(context, parentFolderId: widget.parentFolderId);
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.orange,
        ),
        drawer: const Drawer(
          child: StandardDrawer(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("links")
                      .where("userId",
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .where("parentFolderId", isEqualTo: widget.parentFolderId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                        "Click the + to add a link!",
                        style: TextStyle(fontSize: 25),
                      ));
                    }
                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        return Column(
                          children: [
                            ListTile(
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("links")
                                            .doc(document.id)
                                            .update({
                                          "isFavourite":
                                              !document["isFavourite"]
                                        });
                                      },
                                      icon: const Icon(Icons.star),
                                      color: document["isFavourite"] == true
                                          ? Colors.orange
                                          : null),
                                  IconButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(editSnackBar);
                                      },
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _backupDocument = document;
                                        });
                                        FirebaseFirestore.instance
                                            .collection("links")
                                            .doc(document.id)
                                            .delete();
                                        final deleteSnackBar = SnackBar(
                                            content: const Text("Deleted"),
                                            action: SnackBarAction(
                                                label: "Undo",
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("links")
                                                      .doc(_backupDocument!.id)
                                                      .set({
                                                    "dateCreated":
                                                        _backupDocument![
                                                            "dateCreated"]!,
                                                    "isFavourite":
                                                        _backupDocument![
                                                            "isFavourite"]!,
                                                    "parentFolderId":
                                                        _backupDocument![
                                                            "parentFolderId"]!,
                                                    "title": _backupDocument![
                                                        "title"]!,
                                                    "url": _backupDocument![
                                                        "url"]!,
                                                    "userId": FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid
                                                  });
                                                }));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(deleteSnackBar);
                                      },
                                      icon: const Icon(Icons.delete))
                                ],
                              ),
                            ),
                            const Divider()
                          ],
                        );
                      }).toList(),
                    );
                  }),
            ),
          ],
        ));
  }
}
