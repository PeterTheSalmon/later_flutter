import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/get_favicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
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
                      content:
                          Text("Could not launch ${widget.document["url"]}"),
                      action: SnackBarAction(
                        label: "Close",
                        onPressed: () {},
                      ),
                    ));
                  }
                }),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
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
                            "parentFolderId":
                                _backupDocument!["parentFolderId"]!,
                            "title": _backupDocument!["title"]!,
                            "url": _backupDocument!["url"]!,
                            "userId": FirebaseAuth.instance.currentUser!.uid
                          });
                        }));
                ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: CachedNetworkImage(
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                    imageUrl: getFavicon(widget.document["url"]),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.web, size: 64),
                  )),
              Text(widget.document['url']),
            ],
          ),
        ),
      ),
    );
  }
}
