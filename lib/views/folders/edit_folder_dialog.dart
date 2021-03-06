import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditFolderDialog extends StatelessWidget {
  const EditFolderDialog({Key? key, required this.document}) : super(key: key);
  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: document['name'] as String);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Edit Folder',
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
                      FirebaseFirestore.instance
                          .collection('folders')
                          .doc(document.id)
                          .update({
                        'name': titleController.text,
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
  }
}
