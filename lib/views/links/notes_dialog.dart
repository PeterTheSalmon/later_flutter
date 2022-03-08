import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesDialog extends StatelessWidget {
  const NotesDialog({
    Key? key,
    required this.document,
    required this.initalText,
  }) : super(key: key);

  final DocumentSnapshot document;
  final String initalText;

  @override
  Widget build(BuildContext context) {
    TextEditingController notesController =
        TextEditingController(text: initalText);
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                "Add a note",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                controller: notesController,
                minLines: 1,
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  // save button
                  ElevatedButton(
                      onPressed: () async {
                        if (notesController.text.isEmpty) {
                          FirebaseFirestore.instance
                              .collection('links')
                              .doc(document.id)
                              .update({
                            'notes': FieldValue.delete()
                          }).whenComplete(() => print("done"));
                        } else {
                          FirebaseFirestore.instance
                              .collection("links")
                              .doc(document.id)
                              .update({'notes': notesController.text});
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Save"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
