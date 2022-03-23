import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/added_link_snackbar.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/new_folder_sheet.dart';

/// A list of folders used to select a destination for new links
class FolderPicker extends StatelessWidget {
  const FolderPicker({Key? key, required this.title, required this.url})
      : super(key: key);

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.only(top: 18),
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
            .orderBy("name")
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              TextButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showNewFolderSheet(context,
                        useDialog: true,
                        prefillLinkName: title,
                        prefillLinkUrl: url);
                  },
                  label: const Text(
                    "New folder",
                    style: TextStyle(fontSize: 16),
                  )),
              const Divider(),
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                    return ListTile(
                      title: Text(
                        document["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                        showAddedLinkSnackbar(context, document.id);
                      },
                    );
                  }).toList()),
                ),
              ),
            ]),
          );
        });
  }
}
