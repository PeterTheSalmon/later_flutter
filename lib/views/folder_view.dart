import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/new_link_sheet.dart';
import 'package:later_flutter/views/standard_drawer.dart';

class FolderView extends StatelessWidget {
  const FolderView({Key? key, required this.parentFolderId}) : super(key: key);

  final String parentFolderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Later"),
          actions: [
            IconButton(
                onPressed: () {
                  // ! PARENT FOLDER ID
                  showNewLinkSheet(context, parentFolderId: parentFolderId);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        drawer: const Drawer(
          child: StandardDrawer(),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("links")
                .where("userId",
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where("parentFolderId", isEqualTo: parentFolderId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(document["title"]),
                        subtitle: Text(document["url"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection("links")
                                      .doc(document.id)
                                      .update({
                                    "isFavourite": !document["isFavourite"]
                                  });
                                },
                                icon: const Icon(Icons.star),
                                color: document["isFavourite"] == true
                                    ? Colors.orange
                                    : null),
                            IconButton(
                                onPressed: () {}, icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      ),
                      Divider()
                    ],
                  );
                }).toList(),
              );
            }));
  }
}
