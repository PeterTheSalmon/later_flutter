import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/views/folders/folder%20view/folder_view.dart';
import 'package:later_flutter/views/folders/folder%20view/functions/archive_link.dart';
import 'package:later_flutter/views/links/edit_link_dialog.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkDetailViewBottomNavBar extends StatefulWidget {
  const LinkDetailViewBottomNavBar({Key? key, required this.document})
      : super(key: key);

  final DocumentSnapshot document;

  @override
  State<LinkDetailViewBottomNavBar> createState() =>
      _LinkDetailViewBottomNavBarState();
}

class _LinkDetailViewBottomNavBarState
    extends State<LinkDetailViewBottomNavBar> {
  late bool isArchived;
  late DocumentSnapshot? _backupDocument;

  @override
  void initState() {
    super.initState();
    isArchived = widget.document['archived'] as bool;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          tooltip: 'Open in browser',
          icon: const Icon(Icons.open_in_new),
          onPressed: () async {
            if (await canLaunch(widget.document['url']! as String)) {
              launch(widget.document['url'] as String, enableJavaScript: true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Could not launch ${widget.document["url"]}"),
                  action: SnackBarAction(
                    label: 'Close',
                    onPressed: () {},
                  ),
                ),
              );
            }
          },
        ),
        IconButton(
          onPressed: () {
            archiveLink(
              isArchiveTile: isArchived,
              linkDocument: widget.document,
              context: context,
            );
            setState(() {
              isArchived = !isArchived;
            });
          },
          icon: Icon(
            isArchived == true ? Icons.restore : Icons.archive,
          ),
          tooltip: isArchived == true ? 'Restore' : 'Archive',
        ),
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit),
          onPressed: () {
            // show edit dialog
            showDialog(
              context: context,
              builder: (context) =>
                  Dialog(child: EditLinkDialog(document: widget.document)),
            );
          },
        ),
        IconButton(
          tooltip: 'Move to another folder',
          icon: const Icon(Icons.folder),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Container(
                  height: 500,
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Move to folder',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('folders')
                            .where(
                              'userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                            )
                            .snapshots(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Something went wrong :('),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Column(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot folder) {
                              return ListTile(
                                title: Text(folder['name'] as String),
                                leading: const Icon(Icons.folder),
                                onTap: () {
                                  /// Moves the link to the tapped folder
                                  FirebaseFirestore.instance
                                      .collection('links')
                                      .doc(widget.document.id)
                                      .update({
                                    'parentFolderId': folder.id,
                                  });
                                  Navigator.pop(context); // hide the dialog
                                  Navigator.pop(
                                    context,
                                  ); // hide the link detail view
                                  Navigator.pushReplacement(
                                    // open the folder it was moved to
                                    context,
                                    FadeRoute(
                                      page: FolderView(
                                        parentFolderId: folder.id,
                                        parentFolderName:
                                            folder['name'] as String,
                                      ),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Moved to ${folder["name"]}",
                                      ),
                                      action: SnackBarAction(
                                        onPressed: () {},
                                        label: 'Close',
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _backupDocument = widget.document;
            });
            FirebaseFirestore.instance
                .collection('links')
                .doc(widget.document.id)
                .delete();
            final deleteSnackBar = SnackBar(
              content: const Text('Deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('links')
                      .doc(_backupDocument!.id)
                      .set({
                    'dateCreated': _backupDocument!['dateCreated']!,
                    'isFavourite': _backupDocument!['isFavourite']!,
                    'parentFolderId': _backupDocument!['parentFolderId']!,
                    'title': _backupDocument!['title']!,
                    'url': _backupDocument!['url']!,
                    'userId': FirebaseAuth.instance.currentUser!.uid
                  });
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
          },
        ),
      ],
    );
  }
}
