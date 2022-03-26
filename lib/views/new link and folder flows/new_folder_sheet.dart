import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/added_link_snackbar.dart';
import 'package:uuid/uuid.dart';

/// Shows a sheet or dialog to add a new folder
///
/// Arguments:
///
///   `context`: the context to show the sheet in
///
///   `useDialog`: wether to use a dialog or a sheet. default is false
///
///   `prefillLinkName` and `prefillLinkUrl`: prefill the link name and url
///     and add them to the folder instantly. If null, skip this step.
///
///   __ONLY enabled when using the dialog__

Future<void> showNewFolderSheet(
  BuildContext context, {
  bool useDialog = false,
  String? prefillLinkName,
  String? prefillLinkUrl,
}) async {
  final TextEditingController titleController = TextEditingController();

  if (useDialog) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'New Folder',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.title),
                      labelText: 'Name',
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          /// As we need to use this id to set the link
                          /// `parentFolderId` value, we need to generate
                          /// it instead of letting it be random
                          const Uuid uuid = Uuid();
                          final String id = uuid.v4();
                          FirebaseFirestore.instance
                              .collection('folders')
                              .doc(id)
                              .set({
                            'dateCreated': DateTime.now(),
                            'iconName': 'folder',
                            'name': titleController.text,
                            'userId': FirebaseAuth.instance.currentUser!.uid
                          });
                          if (prefillLinkName != null &&
                              prefillLinkUrl != null) {
                            FirebaseFirestore.instance.collection('links').add({
                              'dateCreated': DateTime.now(),
                              'isFavourite': false,
                              'parentFolderId': id,
                              'title': prefillLinkName,
                              'url': prefillLinkUrl,
                              'userId': FirebaseAuth.instance.currentUser!.uid
                            });
                            Navigator.pop(context);
                            showAddedLinkSnackbar(context, id);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('SAVE'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  } else {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'New Folder',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.title),
                      labelText: 'Name',
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('folders').add({
                            'dateCreated': DateTime.now(),
                            'iconName': 'folder',
                            'name': titleController.text,
                            'userId': FirebaseAuth.instance.currentUser!.uid
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('SAVE'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
