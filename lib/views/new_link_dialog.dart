import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/check_url_conventions.dart';
import 'package:later_flutter/views/folder_picker.dart';

class NewLinkDialog extends StatefulWidget {
  NewLinkDialog({Key? key}) : super(key: key);

  @override
  State<NewLinkDialog> createState() => _NewLinkDialogState();
}

class _NewLinkDialogState extends State<NewLinkDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierLabel: "Choose a Folder",
                            builder: (context) => Dialog(
                              child: FolderPicker(
                                  title: titleController.text,
                                  url: checkUrlConventions(
                                      url: urlController.text)),
                            ),
                          );
                        },
                        child: const Text("NEXT"))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
