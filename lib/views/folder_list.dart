import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/folder_view.dart';

class FolderList extends StatelessWidget {
  const FolderList({Key? key}) : super(key: key);

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
          return Column(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return ListTile(
              title: Text(document["name"]),
              leading: const Icon(Icons.folder),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FolderView(parentFolderId: document.id)));
              },
            );
          }).toList());
        });
  }
}
