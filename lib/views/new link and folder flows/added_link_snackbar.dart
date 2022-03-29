import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/models/folder.dart';
import 'package:later_flutter/views/folders/folder%20view/folder_view.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

/// This function is an absolute disaster.
/// The `BuildContext` is stale. It is passed in from a dialog,
void showAddedLinkSnackbar(BuildContext context, String parentFolderId) async {
  final nav = Navigator.maybeOf(context);
  final sm = ScaffoldMessenger.maybeOf(context);
  final mq = MediaQuery.maybeOf(context);

  /// if we messed up any of the maybeOf()'s, we can't do anything
  if (nav == null || sm == null || mq == null) {
    return;
  }

  final displayMobileLayout = mq.size.width < 550;

  final parentFolder = Folder.fromSnapshot(
    await FirebaseFirestore.instance
        .collection('folders')
        .doc(parentFolderId)
        .get(),
  );

  sm.showSnackBar(
    SnackBar(
      content: const Text('Added link!'),
      action: SnackBarAction(
        label: 'Open Folder',
        onPressed: () {
          if (!nav.mounted) {
            return;
          }
          nav.push(
            displayMobileLayout
                ? fadeThrough(
                    (context, animation, secondaryAnimation) => FolderView(
                      parentFolderId: parentFolderId,
                      parentFolderName: parentFolder.name,
                    ),
                  )
                : FadeRoute(
                    page: FolderView(
                      parentFolderId: parentFolderId,
                      parentFolderName: parentFolder.name,
                    ),
                  ),
          );
        },
      ),
    ),
  );
}
