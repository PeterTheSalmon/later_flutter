// ignore_for_file: no_logic_in_create_state, must_be_immutable

import 'package:flutter/material.dart';
import 'package:later_flutter/services/check_url_conventions.dart';
import 'package:later_flutter/views/folders/folder_picker.dart';

class NewLinkDialog extends StatefulWidget {
  NewLinkDialog({Key? key, this.initalUrl}) : super(key: key);

  String? initalUrl;

  @override
  State<NewLinkDialog> createState() => _NewLinkDialogState(initalUrl);
}

class _NewLinkDialogState extends State<NewLinkDialog> {
  String? initialUrl;
  _NewLinkDialogState(this.initialUrl);

  TextEditingController titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextEditingController urlController =
        TextEditingController(text: initialUrl ?? "");
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
