import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/folder_icon_getter.dart';
import 'package:later_flutter/views/folders/folder%20view/folder_view.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

class FolderList extends StatelessWidget {
  const FolderList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .orderBy('name')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              'Something went wrong:\n\n${snapshot.error!.toString()}',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return ListTile(
              title: Text(document['name'] as String),
              leading: getFolderIcon(document['iconName'] as String),
              onTap: () async {
                if (displayMobileLayout) {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 50));
                }
                Navigator.push(
                  context,
                  displayMobileLayout
                      ? fadeThrough(
                          (context, animation, secondaryAnimation) =>
                              FolderView(
                            parentFolderId: document.id,
                            parentFolderName: document['name'] as String,
                          ),
                        )
                      : FadeRoute(
                          page: FolderView(
                            parentFolderId: document.id,
                            parentFolderName: document['name'] as String,
                          ),
                        ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
