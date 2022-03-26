// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:later_flutter/services/folder_icon_getter.dart';
import 'package:later_flutter/views/folders/edit_folder_dialog.dart';
import 'package:later_flutter/views/folders/folder_icon_chooser.dart';
import 'package:later_flutter/views/folders/folder_view.dart';
import 'package:later_flutter/views/styles/fade_route.dart';
import 'package:later_flutter/views/styles/fade_through_route.dart';

class FolderListTile extends StatefulWidget {
  const FolderListTile({
    Key? key,
    required this.document,
    required this.showEditDelete,
  }) : super(key: key);
  final DocumentSnapshot document;
  final bool showEditDelete;

  @override
  State<FolderListTile> createState() => _FolderListTileState();
}

class _FolderListTileState extends State<FolderListTile> {
  late DocumentSnapshot? _backupDocument;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _backupLinks = [];

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 550;

    return ListTile(
      title: Text(
        widget.document['name'] as String,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: getFolderIcon(widget.document['iconName'] as String),
      onTap: () {
        Navigator.push(
          context,
          displayMobileLayout
              ? fadeThrough(
                  (context, animation, secondaryAnimation) => FolderView(
                    parentFolderId: widget.document.id,
                    parentFolderName: widget.document['name'] as String,
                  ),
                )
              : FadeRoute(
                  page: FolderView(
                    parentFolderId: widget.document.id,
                    parentFolderName: widget.document['name'] as String,
                  ),
                ),
        );
      },
      trailing: widget.showEditDelete
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Folder',
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'icon',
                        child: Text('Change Icon'),
                      ),
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Change Name'),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'icon') {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            FolderIconChooser(folder: widget.document),
                      );
                    } else if (value == 'name') {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            EditFolderDialog(document: widget.document),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Delete Folder',
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    /// * First, we create a backup of the folder
                    /// * And all links it contains
                    setState(() {
                      _backupDocument = widget.document;
                    });

                    final links = FirebaseFirestore.instance
                        .collection('links')
                        .where(
                          'userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .where('parentFolderId', isEqualTo: widget.document.id);
                    await links.get().then(
                          (value) => value.docs.forEach((element) {
                            _backupLinks.add(element);
                            FirebaseFirestore.instance
                                .collection('links')
                                .doc(element.id)
                                .delete();
                          }),
                        );

                    FirebaseFirestore.instance
                        .collection('folders')
                        .doc(widget.document.id)
                        .delete();
                    final deleteSnackBar = SnackBar(
                      content: const Text('Deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('folders')
                              .doc(_backupDocument!.id)
                              .set({
                            'dateCreated': _backupDocument!['dateCreated']!,
                            'iconName': _backupDocument!['iconName']!,
                            'name': _backupDocument!['name']!,
                            'userId': FirebaseAuth.instance.currentUser!.uid
                          });
                          for (final element in _backupLinks) {
                            FirebaseFirestore.instance
                                .collection('links')
                                .doc(element.id)
                                .set({
                              'dateCreated': element['dateCreated']!,
                              'parentFolderId': element['parentFolderId']!,
                              'title': element['title']!,
                              'url': element['url']!,
                              'userId': FirebaseAuth.instance.currentUser!.uid,
                              'isFavourite': element['isFavourite']
                            });
                          }
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(deleteSnackBar);
                  },
                ),
              ],
            )
          : null,
    );
  }
}
