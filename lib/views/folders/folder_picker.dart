import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/folders/new_folder_sheet.dart';

class FolderPicker extends StatelessWidget {
  const FolderPicker({Key? key, required this.title, required this.url})
      : super(key: key);

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Choose a Folder",
          style: TextStyle(fontSize: 20),
        ),
      ),
      Expanded(child: FolderPickerList(title: title, url: url)),
    ]);
  }
}

class FolderPickerList extends StatelessWidget {
  const FolderPickerList({Key? key, required this.title, required this.url})
      : super(key: key);
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("folders")
            .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Something went wrong :("),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            );
          }
          return Column(children: [
            TextButton(
                onPressed: () {
                  showNewFolderSheet(context,
                      useDialog: true,
                      prefillLinkName: title,
                      prefillLinkUrl: url);
                },
                child: const Text("New folder")),
            Expanded(
              child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                return ListTile(
                  title: Text(document["name"]),
                  leading: const Icon(Icons.folder),
                  onTap: () {
                    FirebaseFirestore.instance.collection("links").add({
                      "dateCreated": Timestamp.now(),
                      "isFavourite": false,
                      "parentFolderId": document.id,
                      "title": title,
                      "url": url,
                      "userId": FirebaseAuth.instance.currentUser!.uid
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Added!"),
                        action: SnackBarAction(
                          label: "Close",
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                );
              }).toList()),
            ),
          ]);
        });
  }
}
