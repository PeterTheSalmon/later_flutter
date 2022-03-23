import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/folder.dart';
import 'package:later_flutter/views/folders/folder_view.dart';
import 'package:later_flutter/views/styles/fade_route.dart';

void showAddedLinkSnackbar(BuildContext context, String parentFolderId) async {
  final nav = Navigator.maybeOf(context);

  final parentFolder = Folder.fromSnapshot(await FirebaseFirestore.instance
      .collection('folders')
      .doc(parentFolderId)
      .get());

  if (nav == null) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Added link!"),
      action: SnackBarAction(
          label: "Open Folder",
          onPressed: () {
            if (!nav.mounted) {
              return;
            }
            nav.push(FadeRoute(
              page: FolderView(
                parentFolderId: parentFolderId,
                parentFolderName: parentFolder.name,
              ),
            ));
          }),
    ),
  );
}
