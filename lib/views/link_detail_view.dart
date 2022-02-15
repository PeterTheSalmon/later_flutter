// ignore_for_file: must_be_immutable

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/check_url_conventions.dart';
import 'package:later_flutter/services/get_favicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LinkDetailView extends StatefulWidget {
  LinkDetailView({Key? key, required this.document}) : super(key: key);

  DocumentSnapshot document;

  @override
  State<LinkDetailView> createState() => _LinkDetailViewState();
}

class _LinkDetailViewState extends State<LinkDetailView> {
  DocumentSnapshot? _backupDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document['title']),
      ),
      bottomNavigationBar:
          BottomAppBar(child: _buildBottomNavBar(document: widget.document)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (!kIsWeb)
                  ? Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: CachedNetworkImage(
                        height: 80,
                        width: 80,
                        fit: BoxFit.fill,
                        imageUrl: getFavicon(widget.document["url"]),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Container(),
                      ))
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.document['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              (!kIsWeb)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: AnyLinkPreview(
                        link: widget.document['url'],
                        bodyMaxLines: 3,
                        showMultimedia: true,
                        backgroundColor:
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 71, 71, 71)
                                : const Color.fromARGB(255, 243, 243, 243),
                        titleStyle: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black),
                        placeholderWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 71, 71, 71)
                                  : const Color.fromARGB(255, 243, 243, 243),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ))),
                        errorWidget: Container(
                            decoration: BoxDecoration(
                              color: MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 71, 71, 71)
                                  : const Color.fromARGB(255, 243, 243, 243),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text("No Preview Available"))),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildBottomNavBar({required DocumentSnapshot document}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              if (await canLaunch(widget.document["url"]!)) {
                launch(widget.document["url"], enableJavaScript: true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Could not launch ${widget.document["url"]}"),
                  action: SnackBarAction(
                    label: "Close",
                    onPressed: () {},
                  ),
                ));
              }
            }),
        IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // show edit dialog
              showDialog(
                  context: context,
                  builder: (context) =>
                      Dialog(child: EditLinkDialog(document: document)));
            }),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _backupDocument = widget.document;
            });
            FirebaseFirestore.instance
                .collection("links")
                .doc(widget.document.id)
                .delete();
            final deleteSnackBar = SnackBar(
                content: const Text("Deleted"),
                action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("links")
                          .doc(_backupDocument!.id)
                          .set({
                        "dateCreated": _backupDocument!["dateCreated"]!,
                        "isFavourite": _backupDocument!["isFavourite"]!,
                        "parentFolderId": _backupDocument!["parentFolderId"]!,
                        "title": _backupDocument!["title"]!,
                        "url": _backupDocument!["url"]!,
                        "userId": FirebaseAuth.instance.currentUser!.uid
                      });
                    }));
            ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
          },
        ),
      ],
    );
  }
}

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
