import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:later_flutter/views/link_detail_view.dart';
import 'package:later_flutter/views/new_link_sheet.dart';
import 'package:later_flutter/views/standard_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

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
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.orange,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.copy),
              label: 'Add from Clipboard',
              onTap: () => showNewLinkSheet(context,
                  parentFolderId: widget.parentFolderId, fromClipboard: true),
            ),
            SpeedDialChild(
              child: const Icon(Icons.add_link),
              label: 'Save Link',
              onTap: () => showNewLinkSheet(context,
                  parentFolderId: widget.parentFolderId),
            ),
          ],
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LinkDetailView(
                                            document: document)));
                              },
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
                              leading: IconButton(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () async {
                                    if (await canLaunch(document["url"]!)) {
                                      launch(document["url"],
                                          enableJavaScript: true);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            "Could not launch ${document["url"]}"),
                                        action: SnackBarAction(
                                          label: "Close",
                                          onPressed: () {},
                                        ),
                                      ));
                                    }
                                  }),
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
