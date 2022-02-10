import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showNewFolderSheet(BuildContext context) {
  TextEditingController titleController = TextEditingController();

  return showModalBottomSheet(
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "New Folder",
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
                        labelText: "Name",
                        enabledBorder: UnderlineInputBorder()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Center(
                        child: ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("folders")
                                  .add({
                                "dateCreated": DateTime.now(),
                                "iconName": "folder",
                                "name": titleController.text,
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
      });
}
