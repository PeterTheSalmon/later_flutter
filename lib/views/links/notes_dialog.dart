import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    final TextEditingController notesController =
        TextEditingController(text: initalText);
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              const Text(
                'Add a note',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                controller: notesController,
                minLines: 1,
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  // save button
                  ElevatedButton(
                    onPressed: () async {
                      if (notesController.text.isEmpty) {
                        FirebaseFirestore.instance
                            .collection('links')
                            .doc(document.id)
                            .update({'notes': FieldValue.delete()});
                      } else {
                        FirebaseFirestore.instance
                            .collection('links')
                            .doc(document.id)
                            .update({'notes': notesController.text});
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
