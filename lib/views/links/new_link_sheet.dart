import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_flutter/services/check_url_conventions.dart';

/// Shows a new link sheet
/// 
/// This sheet allows the user to create a new link, and not much else.
/// 
/// It can accept values from the clipboard when `fromClipboard` is true.
Future<void> showNewLinkSheet(BuildContext context,
    {required String parentFolderId, fromClipboard = false}) async {
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController(
      text: fromClipboard
          ? await Clipboard.getData('text/plain').then((value) => value?.text)
          : '');

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    const Text(
                      "Add New Link",
                      style: TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.title),
                      labelText: "Title",
                      enabledBorder: UnderlineInputBorder()),
                ),
                TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.link),
                        labelText: "URL",
                        enabledBorder: UnderlineInputBorder())),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                      child: ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection("links").add({
                              "dateCreated": Timestamp.now(),
                              "isFavourite": false,
                              "parentFolderId": parentFolderId,
                              "title": titleController.text,
                              "url":
                                  checkUrlConventions(url: urlController.text),
                              "userId": FirebaseAuth.instance.currentUser!.uid
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("SAVE"))),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
