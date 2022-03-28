import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/services/check_url_conventions.dart';
import 'package:later_flutter/views/new%20link%20and%20folder%20flows/folder_picker.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

/// Shows a new link sheet or dialog
///
/// Arguments:
/// - `fromClipboard`: whether the sheet should accept values from the clipboard
/// - `parentFolderId`: the folder to add the link to. If using the dialog, no parent folder is needed.
/// - `useDialog`: whether the sheet should be shown as a dialog. Used exclusively on the home page
Future<void> showNewLinkSheet(
  BuildContext context, {
  required String parentFolderId,
  bool fromClipboard = false,
  bool useDialog = false,
}) async {
  /// When copying from the clipboard, it takes a signifigant amount of time
  /// to fetch the page title from the metadata. As such, we add a loading
  /// overlay to indicate that something is actually happening.
  if (fromClipboard) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Get the clipboard
  final TextEditingController urlController = TextEditingController(
    text: fromClipboard
        ? await Clipboard.getData('text/plain').then((value) => value?.text)
        : null,
  );

  final data = await MetadataFetch.extract(urlController.text);
  final TextEditingController titleController =
      TextEditingController(text: data?.title ?? '');

  /// Remove the loading overlay
  if (fromClipboard) {
    Navigator.pop(context);
  }

  if (useDialog) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    const Text(
                      'Add New Link',
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
                    labelText: 'Title',
                    enabledBorder: UnderlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.link),
                    labelText: 'URL',
                    enabledBorder: UnderlineInputBorder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierLabel: 'Choose a Folder',
                          builder: (context) => Dialog(
                            child: FolderPicker(
                              title: titleController.text,
                              url: checkUrlConventions(
                                url: urlController.text,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('NEXT'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  } else {
    return showModalBottomSheet<void>(
      constraints: const BoxConstraints(maxWidth: 500),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      const Text(
                        'Add New Link',
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
                      labelText: 'Title',
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.link),
                      labelText: 'URL',
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('links').add({
                            'dateCreated': Timestamp.now(),
                            'isFavourite': false,
                            'parentFolderId': parentFolderId,
                            'title': titleController.text,
                            'url': checkUrlConventions(
                              url: urlController.text,
                            ),
                            'userId': FirebaseAuth.instance.currentUser!.uid,
                            'archived': false,
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
