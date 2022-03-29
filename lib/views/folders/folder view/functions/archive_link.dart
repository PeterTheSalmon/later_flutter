

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Archives or restores a link.
void archiveLink({
  required bool isArchiveTile,
  required DocumentSnapshot<Object?> linkDocument,
  required BuildContext context,
}) {
  if (isArchiveTile) {
    // Restore the link
    FirebaseFirestore.instance.collection('links').doc(linkDocument.id).update({
      'archived': false,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restored'),
      ),
    );
  } else {
    // Archive the link
    FirebaseFirestore.instance.collection('links').doc(linkDocument.id).update({
      'archived': true,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Archived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            FirebaseFirestore.instance
                .collection('links')
                .doc(linkDocument.id)
                .update({
              'archived': false,
            });
          },
        ),
      ),
    );
  }
}
