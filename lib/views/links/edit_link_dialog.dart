// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/check_url_conventions.dart';

class EditLinkDialog extends StatelessWidget {
  EditLinkDialog({Key? key, required this.document}) : super(key: key);
  DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(text: document['title']);
    TextEditingController urlController =
        TextEditingController(text: document['url']);
    return Material(
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
                  "Edit Link",
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
                        FirebaseFirestore.instance
                            .collection("links")
                            .doc(document.id)
                            .update({
                          "title": titleController.text,
                          "url": checkUrlConventions(url: urlController.text),
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("SAVE AND CLOSE"))),
            )
          ],
        ),
      ),
    );
  }
}
