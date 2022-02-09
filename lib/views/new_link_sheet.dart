import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showNewLinkSheet(BuildContext context,
    {required String parentFolderId}) {
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
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
                            "url": urlController.text,
                            "userId": FirebaseAuth.instance.currentUser!.uid
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("SAVE"))),
              )
            ],
          ),
        ),
      );
    },
  );
}
