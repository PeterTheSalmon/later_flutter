// ignore_for_file: must_be_immutable

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/get_favicon.dart';
import 'package:later_flutter/views/folders/folder_view.dart';
import 'package:later_flutter/views/links/edit_link_dialog.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
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
          BottomAppBar(child: _bottomNavigationBar(document: widget.document)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _faviconPreview(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.document['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              // TODO: Add a shadow on the loading container
              _websitePreview(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faviconPreview(BuildContext context) {
    return (!kIsWeb)
        ? Padding(
            padding: const EdgeInsets.all(18.0),
            child: CachedNetworkImage(
              height: 80,
              width: 80,
              fit: BoxFit.fill,
              imageUrl: getFavicon(widget.document["url"]),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => Container(),
            ))
        : Container();
  }

  Widget _websitePreview(BuildContext context) {
    return (!kIsWeb)
        ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            child: AnyLinkPreview(
              link: widget.document['url'],
              bodyMaxLines: 3,
              showMultimedia: true,
              backgroundColor:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color.fromARGB(255, 71, 71, 71)
                      : const Color.fromARGB(255, 243, 243, 243),
              titleStyle: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black),
              placeholderWidget: Container(
                  decoration: BoxDecoration(
                    color: MediaQuery.of(context).platformBrightness ==
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
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? const Color.fromARGB(255, 71, 71, 71)
                        : const Color.fromARGB(255, 243, 243, 243),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("No Preview Available"))),
            ),
          )
        : Container();
  }

  Row _bottomNavigationBar({required DocumentSnapshot document}) {
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
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                        child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Column(
                        children: [
                          const Text("Move to folder",
                              style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("folders")
                                    .where("userId",
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Something went wrong :("),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  return Column(
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot folder) {
                                    return ListTile(
                                      title: Text(folder["name"]),
                                      leading: const Icon(Icons.folder),
                                      onTap: () {
                                        /// Moves the link to the tapped folder
                                        FirebaseFirestore.instance
                                            .collection("links")
                                            .doc(document.id)
                                            .update({
                                          "parentFolderId": folder.id,
                                        });
                                        Navigator.pop(
                                            context); // hide the dialog
                                        Navigator.pop(
                                            context); // hide the link detail view
                                        Navigator.pushReplacement(
                                            // open the folder it was moved to
                                            context,
                                            (FadeRoute(
                                                page: FolderView(
                                                    parentFolderId: folder.id,
                                                    parentFolderName:
                                                        folder["name"]))));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Moved to ${folder["name"]}"),
                                                action: SnackBarAction(
                                                  onPressed: () {},
                                                  label: "Close",
                                                )));
                                      },
                                    );
                                  }).toList());
                                }),
                          ),
                        ],
                      ),
                    )));
          },
          icon: const Icon(Icons.folder),
        ),
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
